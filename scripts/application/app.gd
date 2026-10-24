extends Control

const Session = preload("res://scripts/application/game_session.gd")
const View = preload("res://scripts/presentation/app_view.gd")
const Preferences = preload("res://scripts/persistence/preferences_store.gd")
const Decimal = preload("res://scripts/domain/unsigned_decimal.gd")
const Tutorial = preload("res://scripts/application/tutorial_controller.gd")
const History = preload("res://scripts/application/hand_history.gd")
const Feedback = preload("res://scripts/presentation/feedback.gd")

var session: RefCounted
var view: Control
var preferences := Preferences.new()
var _screen: String = "home"
var _busy: bool = false
var _last_tick: int = 0
var _hint_visible: bool = false
var _tutorial_step: int = 0
var _map_start: String = "1"
var _tutorial := Tutorial.new()
var _pending_hand_id: String = ""
var _feedback: Node
var _last_feedback_key: String = ""

func _ready() -> void:
	get_tree().auto_accept_quit = false
	session = Session.new()
	_tutorial_step = int(session.tutorial_progress.last_step)
	preferences.load_preferences()
	_feedback = Feedback.new()
	_feedback.apply_preferences(preferences.snapshot())
	add_child(_feedback)
	view = View.new()
	add_child(view)
	view.command.connect(_command)
	view.show_settings(_ui_preferences())
	_home()
	_last_tick = Time.get_ticks_msec()
	if not session.error.is_empty():
		view.show_message("Gravação preservada", "Não foi possível abrir o progresso: " + session.error + ". Nenhum arquivo foi apagado.")

func _process(_delta: float) -> void:
	var now := Time.get_ticks_msec()
	var elapsed := now - _last_tick
	_last_tick = now
	if session == null or _screen != "table" or _busy:
		return
	var acted: bool = session.tick(elapsed)
	if acted:
		_render_table()
		_drive_bots()
	elif session.mode == "hardcore":
		view.update_clock(session.clock.snapshot())
	if session.mode == "normal" and session.hint_elapsed_ms >= 8000 and not _hint_visible:
		_hint_visible = true
		view.update_hint_available(true)

func _notification(what: int) -> void:
	if session == null:
		return
	if what == NOTIFICATION_APPLICATION_PAUSED or what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		if _screen == "table":
			_flush_time()
			session.pause()
			_screen = "pause"
			view.show_pause()
	elif what == NOTIFICATION_WM_GO_BACK_REQUEST:
		_command("back", {})
	elif what == NOTIFICATION_WM_CLOSE_REQUEST:
		_flush_time()
		session.pause()
		get_tree().quit()

func _flush_time() -> void:
	var now := Time.get_ticks_msec()
	if _screen == "table" and not _busy:
		session.tick(now - _last_tick)
	_last_tick = now

func _command(kind: String, payload: Dictionary) -> void:
	if _busy and kind not in ["pause", "home"]:
		return
	_flush_time()
	if _screen == "tutorial_practice" and kind == "action":
		var trained: Dictionary = _tutorial.act(str(payload.get("kind", "CHECK")), int(payload.get("raise_to", 0)))
		if not trained.ok:
			view.show_message("Vamos praticar", str(trained.error))
		else:
			if _tutorial.finished:
				_check(session.complete_lesson(_tutorial.lesson))
			view.show_tutorial_practice(_tutorial.player_view())
		return
	if _screen == "tutorial_practice" and kind == "next_hand":
		_tutorial_step = mini(4, _tutorial.lesson + 1)
		_screen = "tutorial"
		view.show_tutorial(_tutorial_step)
		return
	match kind:
		"home":
			if session.active():
				session.pause()
			_home()
		"campaign":
			if session.active():
				session.pause()
			session.mode = str(payload.get("mode", "normal"))
			_map_start = "1"
			_show_campaign()
		"map_page":
			_map_start = str(payload.get("start", "1"))
			_show_campaign()
		"play":
			var index := str(payload.get("index", "1"))
			if session.active():
				view.show_message("Torneio salvo", "Continue ou abandone o torneio atual antes de começar outro.")
				return
			if not session.campaign().state.unlocked.has(index):
				_show_campaign()
				view.show_message("Mesa bloqueada", "Desbloqueie esta mesa no mapa primeiro.")
				return
			if _check(session.start(index)):
				_feedback.play("card")
				_screen = "table"
				_render_table()
				_drive_bots()
		"unlock":
			if _check(session.unlock(str(payload.get("index", "1")))):
				_show_campaign()
		"resume":
			if not session.active():
				for mode: String in ["normal", "hardcore"]:
					if not session.campaigns[mode].state.active_attempt.is_empty():
						session.mode = mode
						break
			if session.active():
				session.resume()
				_screen = "table"
				_render_table()
				_drive_bots()
		"pause":
			session.pause()
			_screen = "pause"
		"action":
			if session.active() and int(session.game().state.actor) == 0:
				if _check(session.act(str(payload.get("kind", "CHECK")), int(payload.get("raise_to", 0)), int(session.game().state.revision))):
					_play_action(str(payload.get("kind", "CHECK")))
					_hint_visible = false
					_render_table()
					_drive_bots()
		"next_hand":
			if _check(session.next_hand()):
				_feedback.play("card")
				_hint_visible = false
				_render_table()
				_drive_bots()
		"hint":
			var result: Dictionary = session.hint()
			if _check(result):
				_render_table()
				view.show_message("Uma ajuda para pensar", str(result.get("explanation", "")))
		"abandon_confirmed":
			if _check(session.abandon()):
				_show_campaign()
		"settings":
			_screen = "settings"
			view.show_settings(_ui_preferences())
		"set_setting":
			var key := str(payload.get("key", ""))
			key = {"music_volume": "music", "sfx_volume": "sfx", "four_colors": "four_color"}.get(key, key)
			var result: Error = preferences.set_value(key, payload.get("value"))
			if result != OK:
				view.show_message("Configurações", "Não foi possível salvar esta opção.")
			else:
				_feedback.apply_preferences(preferences.snapshot())
		"retry_save":
			if _check(session.retry_save()):
				view.show_message("Gravação disponível", "A última situação confirmada foi salva. Você pode continuar.")
		"tutorial":
			if session.active():
				session.pause()
			_screen = "tutorial"
			_tutorial_step = int(payload.get("step", _tutorial_step))
			view.show_tutorial(_tutorial_step)
			if payload.get("practice", false):
				_tutorial.start(_tutorial_step)
				_screen = "tutorial_practice"
				view.show_tutorial_practice(_tutorial.player_view())
		"review":
			session.pause()
			_screen = "pause"
			view.show_message("Última mão", History.describe(session.histories.get(session.mode, {})))
		"back":
			if _screen in ["table", "pause"] and session.active():
				session.pause()
				_screen = "pause"
				view.show_pause()
			else:
				_home()

func _home() -> void:
	_screen = "home"
	view.show_home({
		"has_active": not session.campaigns.normal.state.active_attempt.is_empty() or not session.campaigns.hardcore.state.active_attempt.is_empty(),
		"normal_wallet": str(session.campaigns.normal.state.wallet),
		"hardcore_wallet": str(session.campaigns.hardcore.state.wallet),
	})

func _ui_preferences() -> Dictionary:
	var values: Dictionary = preferences.snapshot()
	values.music_volume = values.music
	values.sfx_volume = values.sfx
	values.four_colors = values.four_color
	return values

func _show_campaign() -> void:
	_screen = "campaign"
	var campaign: RefCounted = session.campaign()
	var tables: Array = []
	var index := _map_start
	for offset in range(10):
		var config: Dictionary = campaign.config(index)
		var unlocked: bool = campaign.state.unlocked.has(index)
		var completed: bool = campaign.state.completed.has(index)
		var previous := Decimal.subtract(index, "1")
		var locked: bool = not unlocked and not campaign.state.completed.has(previous)
		tables.append({"index": index, "config": config, "unlocked": unlocked, "won": completed, "locked": locked})
		index = Decimal.add(index, "1")
	view.show_campaign(session.mode, str(campaign.state.wallet), tables, session.active())
	if view.has_method("show_map_navigation"):
		view.show_map_navigation(_map_start)

func _render_table() -> void:
	if session.last_results.has(session.mode) and not session.active():
		var result: Dictionary = session.last_results[session.mode].duplicate(true)
		result.mode = session.mode
		result.next_index = Decimal.add(str(result.get("index", "1")), "1")
		var config: Dictionary = session.campaign().config(str(result.get("index", "1")))
		result.reward = int(config.get("base_reward", 0)) if result.get("won", false) else 0
		result.bonus = int(config.get("first_win_bonus", 0)) if result.get("first_win", false) else 0
		var feedback_key := str(result.get("attempt_id", ""))
		if _last_feedback_key != feedback_key:
			_last_feedback_key = feedback_key
			_feedback.play("victory" if result.get("won", false) else "fold")
		_screen = "result"
		view.show_result(result)
		return
	if session.game() != null:
		_screen = "table"
		view.show_table(session.player_view())
		if session.game().state.phase == "settled" and session.active():
			var feedback_key: String = session.decision_id()
			if feedback_key != _last_feedback_key:
				_last_feedback_key = feedback_key
				_feedback.play("pot")
			_auto_next_hand()

func _play_action(kind: String) -> void:
	_feedback.play({"CHECK": "check", "CALL": "call", "FOLD": "fold", "ALL_IN": "raise", "BET_TO": "raise", "RAISE_TO": "raise"}.get(kind, "card"))

func _auto_next_hand() -> void:
	var key: String = session.decision_id()
	if _pending_hand_id == key:
		return
	_pending_hand_id = key
	await get_tree().create_timer(0.9).timeout
	if _pending_hand_id == key and _screen == "table" and session.active() and not session.paused and session.decision_id() == key:
		_pending_hand_id = ""
		_command("next_hand", {})

func _drive_bots() -> void:
	if _busy:
		return
	_busy = true
	while _screen == "table" and session.active() and not session.paused and int(session.game().state.actor) > 0:
		await get_tree().process_frame
		if _screen != "table" or session.paused:
			break
		var result: Dictionary = session.step_bot()
		_last_tick = Time.get_ticks_msec()
		if not _check(result):
			break
		_render_table()
	_busy = false
	_last_tick = Time.get_ticks_msec()

func _check(result: Dictionary) -> bool:
	if result.get("ok", false):
		return true
	var reason := str(result.get("error", "unknown_error"))
	var messages := {"insufficient_funds": "Seu saldo não cobre este custo. Você pode repetir mesas já liberadas para ganhar fichas.", "previous_table_not_completed": "Vença a mesa anterior primeiro.", "BOT_BUDGET_EXCEEDED": "O cálculo do adversário demorou além do limite. O torneio foi pausado e a jogada foi preservada."}
	if not session.error.is_empty() and view.has_method("show_storage_error"):
		view.show_storage_error(session.error)
	else:
		view.show_message("Não foi possível continuar", str(messages.get(reason, "Operação preservada: " + reason)))
	return false
