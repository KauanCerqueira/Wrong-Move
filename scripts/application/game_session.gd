class_name GameSession
extends RefCounted

const Campaign = preload("res://scripts/campaign/campaign_service.gd")
const Tournament = preload("res://scripts/domain/tournament.gd")
const Store = preload("res://scripts/persistence/save_store.gd")
const ClockStorage = preload("res://scripts/persistence/clock_store.gd")
const Clock = preload("res://scripts/application/hardcore_clock.gd")
const Agent = preload("res://scripts/ai/basic_agent.gd")
const Advisor = preload("res://scripts/ai/hint_advisor.gd")
const Evaluator = preload("res://scripts/domain/hand_evaluator.gd")
const Decimal = preload("res://scripts/domain/unsigned_decimal.gd")
const History = preload("res://scripts/application/hand_history.gd")

var campaigns: Dictionary = {}
var games: Dictionary = {}
var last_results: Dictionary = {}
var histories: Dictionary = {}
var public_tendencies: Dictionary = {"normal": {}, "hardcore": {}}
var tutorial_progress: Dictionary = {"last_step": 0, "completed": {}}
var mode: String = "normal"
var paused: bool = true
var error: String = ""
var clock = Clock.new()
var clock_decision_id: String = ""
var hint_elapsed_ms: int = 0
var _hint_decision_id: String = ""
var _window_remaining_ms: int = 0
var _store: RefCounted
var _clock_store: RefCounted
var _epoch: String = "0"
var _bot_rng := RandomNumberGenerator.new()
var _command_receipts: Dictionary = {}

func _init(directory: String = "user://save") -> void:
	_store = Store.new(directory)
	_clock_store = ClockStorage.new(directory.path_join("clock"))
	_bot_rng.randomize()
	for campaign_mode: String in ["normal", "hardcore"]:
		campaigns[campaign_mode] = Campaign.new(campaign_mode, Crypto.new().generate_random_bytes(16).hex_encode())
	var loaded: Dictionary = _store.load_state()
	if loaded.ok and not loaded.data.is_empty():
		_restore(loaded.data)
		var durable: Dictionary = _clock_store.latest()
		if durable.get("epoch", "") == _epoch and durable.get("decision_id", "") == clock_decision_id:
			clock.restore(durable.get("clock", {}))
	elif not loaded.ok:
		error = str(loaded.error)
	paused = true
	clock.pause()

func campaign() -> RefCounted:
	return campaigns[mode]

func game() -> RefCounted:
	return games.get(mode)

func active() -> bool:
	return not campaign().state.active_attempt.is_empty() and game() != null

func decision_id() -> String:
	if not active():
		return ""
	return str(campaign().state.active_attempt.attempt_id) + ":" + str(game().state.hand_number) + ":" + str(game().state.revision)

func unlock(index: String) -> Dictionary:
	var before := snapshot()
	var result: Dictionary = campaign().unlock(index)
	if not result.ok:
		return result
	return _persist(before, result)

func start(index: String) -> Dictionary:
	if not error.is_empty():
		return _failure(error)
	var before := snapshot()
	var result: Dictionary = campaign().start_attempt(index)
	if not result.ok:
		return result
	var tournament := Tournament.new()
	tournament.start(int(result.config.participants), 0, result.config)
	games[mode] = tournament
	last_results.erase(mode)
	public_tendencies[mode] = {}
	_command_receipts.clear()
	if mode == "hardcore":
		clock.new_attempt()
		clock_decision_id = ""
	paused = false
	_prepare_decision()
	_finish_if_terminal()
	var saved := _persist(before, result)
	if saved.ok:
		resume()
	return saved

func act(kind: String, raise_to: int = 0, expected_revision: int = -1, command_id: String = "") -> Dictionary:
	if not command_id.is_empty() and _command_receipts.has(command_id):
		return _command_receipts[command_id].duplicate(true)
	if not active() or paused:
		return _failure("paused_or_no_attempt")
	if expected_revision >= 0 and expected_revision != int(game().state.revision):
		return _failure("stale_revision")
	var before := snapshot()
	var acting_id := int(game().state.actor)
	var facing: bool = int(game().legal_actions(acting_id).get("to_call", 0)) > 0
	var result: Dictionary = game().apply_action(int(game().state.actor), kind, raise_to)
	if not result.ok:
		return result
	if facing:
		var key := str(acting_id)
		var tracker: Dictionary = public_tendencies[mode].get(key, {"opportunities": 0, "folds": 0})
		tracker.opportunities += 1
		if kind == "FOLD":
			tracker.folds += 1
		public_tendencies[mode][key] = tracker
	_prepare_decision()
	_finish_if_terminal()
	_capture_hand()
	if not command_id.is_empty():
		_command_receipts[command_id] = result.duplicate(true)
	result = _persist(before, result)
	if result.ok and mode == "hardcore" and active():
		_open_window()
	return result

func step_bot() -> Dictionary:
	if not active() or paused or int(game().state.actor) <= 0:
		return _failure("no_bot_turn")
	var actor := int(game().state.actor)
	var config: Dictionary = campaign().state.active_attempt.config
	var styles: Array = config.get("styles", [])
	var style := str(styles[(actor - 1) % styles.size()]) if not styles.is_empty() else "equilibrado"
	var before_rng := str(_bot_rng.state)
	var started := Time.get_ticks_msec()
	var observed: Dictionary = game().observation(actor)
	observed.public_fold_stats = _public_stats(actor)
	var choice: Dictionary = Agent.choose_action(observed, _bot_rng, int(config.get("strength", 0)), style)
	if Time.get_ticks_msec() - started > 500:
		_bot_rng.state = int(before_rng)
		pause()
		return _failure("BOT_BUDGET_EXCEEDED")
	var result := act(str(choice.get("kind", "CHECK")), int(choice.get("raise_to", 0)))
	if not result.ok:
		_bot_rng.state = int(before_rng)
	return result

func _public_stats(viewer_id: int) -> Dictionary:
	var total := {"opportunities": 0, "folds": 0}
	for key: String in public_tendencies.get(mode, {}):
		if int(key) != viewer_id:
			total.opportunities += int(public_tendencies[mode][key].opportunities)
			total.folds += int(public_tendencies[mode][key].folds)
	return total

func next_hand() -> Dictionary:
	if not active() or game().state.phase != "settled":
		return _failure("hand_not_finished")
	var before := snapshot()
	game().next_hand()
	_prepare_decision()
	_finish_if_terminal()
	_capture_hand()
	var result := _persist(before, {"ok": true})
	if result.ok:
		resume()
	return result

func hint() -> Dictionary:
	if mode != "normal" or not active() or paused or int(game().state.actor) != 0:
		return _failure("hints_unavailable")
	var key := decision_id()
	if campaign().state.receipts.hints.has(key):
		return campaign().state.receipts.hints[key].get("context", {}).duplicate(true)
	if hint_elapsed_ms < 8000:
		return _failure("hint_not_ready")
	var advice: Dictionary = Advisor.recommend(game().observation(0))
	advice.ok = true
	var before := snapshot()
	var debit: Dictionary = campaign().debit_hint(key, advice)
	if not debit.ok:
		return debit
	return _persist(before, advice)

func abandon() -> Dictionary:
	if not active():
		return _failure("no_attempt")
	var before := snapshot()
	var id := str(campaign().state.active_attempt.attempt_id)
	var result: Dictionary = campaign().finish_attempt(id, false)
	games.erase(mode)
	paused = true
	clock.pause()
	return _persist(before, result)

func complete_lesson(step: int) -> Dictionary:
	if step < 0 or step > 4:
		return _failure("invalid_lesson")
	var before := snapshot()
	tutorial_progress.completed[str(step)] = true
	tutorial_progress.last_step = mini(4, step + 1)
	return _persist(before, {"ok": true})

func retry_save() -> Dictionary:
	var before := snapshot()
	return _persist(before, {"ok": true})

func pause() -> Dictionary:
	paused = true
	clock.pause()
	_window_remaining_ms = 0
	return _persist(snapshot(), {"ok": true})

func resume() -> void:
	if not error.is_empty() or not active():
		return
	paused = false
	_prepare_decision()
	if mode == "hardcore":
		_open_window()

func tick(elapsed_ms: int) -> bool:
	if paused or not active() or int(game().state.actor) != 0:
		return false
	hint_elapsed_ms += maxi(0, elapsed_ms)
	if mode != "hardcore":
		return false
	var remaining := maxi(0, elapsed_ms)
	while remaining > 0 and not paused:
		if _window_remaining_ms <= 0 and not _open_window():
			return false
		var step := mini(remaining, _window_remaining_ms)
		var expired: bool = clock.advance(step)
		_window_remaining_ms -= step
		remaining -= step
		if expired:
			var legal: Dictionary = game().legal_actions(0)
			act("CHECK" if legal.get("check_allowed", false) else "FOLD")
			return true
	return false

func _prepare_decision() -> void:
	if not active():
		return
	var key := decision_id()
	if key != _hint_decision_id:
		_hint_decision_id = key
		hint_elapsed_ms = 0
	if mode == "hardcore" and int(game().state.actor) == 0 and key != clock_decision_id:
		clock.new_decision()
		clock_decision_id = key
		_window_remaining_ms = 0
	if mode == "hardcore" and int(game().state.actor) != 0:
		clock.pause()

func _open_window() -> bool:
	if mode != "hardcore" or not active() or int(game().state.actor) != 0 or paused:
		return true
	var budget: int = mini(1000, clock.decision_remaining_ms + clock.reserve_remaining_ms)
	if not _clock_store.commit({"epoch": _epoch, "decision_id": clock_decision_id, "clock": clock.durable_snapshot(budget)}):
		error = "clock_save_failed"
		paused = true
		clock.pause()
		return false
	_window_remaining_ms = budget
	clock.resume()
	return true

func _finish_if_terminal() -> void:
	if game() == null or game().state.status == "active" or campaign().state.active_attempt.is_empty():
		return
	var attempt: Dictionary = campaign().state.active_attempt.duplicate(true)
	var result: Dictionary = campaign().finish_attempt(str(attempt.attempt_id), game().state.status == "won")
	result.index = str(attempt.index)
	result.wallet = str(campaign().state.wallet)
	last_results[mode] = result
	clock.pause()

func _capture_hand() -> void:
	if game() != null and game().state.phase == "settled":
		histories[mode] = History.capture(game())

func snapshot() -> Dictionary:
	var game_data := {}
	for key: String in games:
		game_data[key] = games[key].snapshot()
	return {"normal": campaigns.normal.snapshot(), "hardcore": campaigns.hardcore.snapshot(), "games": game_data, "tutorial_progress": tutorial_progress.duplicate(true),
		"mode": mode, "epoch": _epoch, "clock": clock.snapshot(), "clock_decision_id": clock_decision_id,
		"hint_elapsed_ms": hint_elapsed_ms, "hint_decision_id": _hint_decision_id, "last_results": last_results.duplicate(true), "histories": histories.duplicate(true),
		"bot_rng_seed": str(_bot_rng.seed), "bot_rng_state": str(_bot_rng.state), "command_receipts": _command_receipts.duplicate(true), "public_tendencies": public_tendencies.duplicate(true)}

func _restore(data: Dictionary) -> void:
	for key: String in ["normal", "hardcore"]:
		if data.has(key):
			campaigns[key].restore(data[key])
	games.clear()
	for key: String in data.get("games", {}):
		var tournament := Tournament.new()
		tournament.restore(data.games[key])
		games[key] = tournament
	mode = str(data.get("mode", "normal"))
	_epoch = str(data.get("epoch", "0"))
	clock.restore(data.get("clock", {}))
	clock_decision_id = str(data.get("clock_decision_id", ""))
	_hint_decision_id = str(data.get("hint_decision_id", ""))
	hint_elapsed_ms = int(data.get("hint_elapsed_ms", 0))
	last_results = data.get("last_results", {}).duplicate(true)
	histories = data.get("histories", {}).duplicate(true)
	_command_receipts = data.get("command_receipts", {}).duplicate(true)
	public_tendencies = data.get("public_tendencies", {"normal": {}, "hardcore": {}}).duplicate(true)
	tutorial_progress = data.get("tutorial_progress", {"last_step": 0, "completed": {}}).duplicate(true)
	_bot_rng.seed = int(data.get("bot_rng_seed", "1"))
	_bot_rng.state = int(data.get("bot_rng_state", "1"))
	_window_remaining_ms = 0

func _persist(before: Dictionary, result: Dictionary) -> Dictionary:
	_epoch = Decimal.add(_epoch, "1")
	var candidate := snapshot()
	var saved: Dictionary = _store.commit(candidate)
	if saved.ok:
		error = ""
		return result
	# Death after rename may have committed even if feedback failed.
	var durable: Dictionary = _store.load_state()
	if durable.ok and durable.data.get("epoch", "") == _epoch:
		_restore(durable.data)
		return result
	_restore(before)
	paused = true
	clock.pause()
	error = str(saved.error)
	return _failure(error)

func player_view() -> Dictionary:
	if game() == null:
		return {}
	var view: Dictionary = game().observation(0)
	var state: Dictionary = game().state
	var config: Dictionary = state.config
	view.mode = mode
	view.table_index = str(config.get("index", "1"))
	view.board = state.board.duplicate()
	view.pot = int(view.public_pot)
	view.hand_number = int(state.hand_number)
	view.small_blind = int(state.small_blind)
	view.big_blind = int(state.big_blind)
	view.player_stack = int(state.seats[0].stack)
	view.result = state.result.duplicate(true) if state.phase == "settled" else null
	if view.result != null:
		var awards: Dictionary = view.result.get("awards", {})
		var descriptions: Dictionary = view.result.get("descriptions", {})
		var summaries: PackedStringArray = []
		view.pot = 0
		for id: Variant in awards:
			var amount := int(awards[id])
			view.pot += amount
			var who := "Você" if str(id) == "0" else "Bot " + str(id)
			var description := str(descriptions.get(id, descriptions.get(str(id), "")))
			summaries.append(who + " levou " + str(amount) + (" com " + description if not description.is_empty() else ""))
		view.result.summary = ". ".join(summaries)
	view.clock = clock.snapshot() if mode == "hardcore" else {}
	view.hint_price = int(config.get("hint_price", 0))
	view.wallet = str(campaign().state.wallet)
	view.legal_actions.opening_bet = int(state.current_bet) == 0
	view.legal_actions.street_contribution = int(state.seats[0].street_contribution)
	view.hint_available = mode == "normal" and hint_elapsed_ms >= 8000 and int(state.actor) == 0
	var cards: Array[int] = []
	for card: Variant in view.own_cards + view.board:
		cards.append(int(card))
	view.current_combination = Evaluator.describe(cards)
	for seat: Dictionary in view.seats:
		seat.last_action = ""
		for action: Dictionary in view.public_actions:
			if int(action.seat_id) == int(seat.id):
				seat.last_action = {"FOLD": "Desistiu", "CHECK": "Passou", "CALL": "Pagou", "RAISE_TO": "Aumentou", "BET_TO": "Apostou", "ALL_IN": "All-in"}.get(str(action.kind), str(action.kind))
		if int(seat.id) > 0:
			var styles: Array = config.get("styles", [])
			seat.style = str(styles[(int(seat.id) - 1) % styles.size()]) if not styles.is_empty() else "equilibrado"
		var id := str(seat.id)
		if view.reveals.has(id) or view.reveals.has(int(seat.id)):
			seat.hole_cards = view.reveals.get(id, view.reveals.get(int(seat.id), []))
	return view

static func _failure(reason: String) -> Dictionary:
	return {"ok": false, "error": reason}
