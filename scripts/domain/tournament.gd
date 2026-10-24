class_name PokerTournament
extends RefCounted

const Deck = preload("res://scripts/domain/deck.gd")
const Evaluator = preload("res://scripts/domain/hand_evaluator.gd")
const Rules = preload("res://scripts/domain/betting_rules.gd")
const Pots = preload("res://scripts/domain/pot_settlement.gd")
const State = preload("res://scripts/domain/game_state.gd")
const DEFAULT_BLINDS := [10, 15, 25, 40, 60, 100, 150, 250, 400, 600, 1000, 1500, 3000]

var state: Dictionary = {}
var _deck = Deck.new(1)
var _deck_rng := RandomNumberGenerator.new()

func start(count: int = 2, seed_value: int = 0, config: Dictionary = {}) -> void:
	assert(count >= 2 and count <= 6, "Tournament supports 2–6 participants")
	var positions := RandomNumberGenerator.new()
	if seed_value == 0:
		positions.randomize()
		seed_value = positions.randi_range(1, 2147483647)
	positions.seed = seed_value
	_deck_rng.seed = seed_value ^ 0x4D574445434B
	var stack := int(config.get("starting_stack", 1000))
	assert(stack > 0)
	state = {"seats": [], "board": [], "burns": [], "phase": "settled", "status": "active", "actor": -1, "hand_number": 0, "button": positions.randi_range(0, count - 1), "small_blind_seat": -1, "big_blind_seat": -1, "current_bet": 0, "last_full_raise": 20, "result": {}, "revision": 0, "config": config.duplicate(true), "last_dealt_seat_ring": [], "actions": [], "reveals": {}, "pots": [], "blind_level": 0, "initial_chips": count * stack}
	for id in range(count):
		state.seats.append({"id": id, "human": id == 0, "stack": stack, "hole_cards": [], "folded": false, "all_in": false, "street_contribution": 0, "hand_contribution": 0, "acted": false, "acted_at_bet_level": -1})
	_begin_hand(true)

func next_hand() -> void:
	if state.is_empty() or state.status != "active" or state.phase != "settled": return
	_begin_hand(false)

func _begin_hand(first: bool) -> void:
	var survivors: Array[int] = []
	for seat in state.seats:
		if seat.stack > 0: survivors.append(int(seat.id))
	if survivors.size() < 2: return
	var sb := -1
	var bb := -1
	if first:
		if survivors.size() == 2:
			sb = int(state.button)
			bb = _next_in(sb, survivors)
		else:
			sb = _next_in(int(state.button), survivors)
			bb = _next_in(sb, survivors)
	else:
		var old_bb := int(state.big_blind_seat)
		bb = _next_in(old_bb, survivors)
		if survivors.size() == 2:
			sb = _next_in(bb, survivors)
			state.button = sb
		else:
			var old_ring: Array = state.last_dealt_seat_ring
			var old_index := old_ring.find(old_bb)
			state.button = int(old_ring[(old_index + old_ring.size() - 1) % old_ring.size()])
			if survivors.has(old_bb): sb = old_bb
	state.small_blind_seat = sb
	state.big_blind_seat = bb
	state.last_dealt_seat_ring = survivors.duplicate()
	state.hand_number += 1
	state.revision += 1
	var config: Dictionary = state.config
	var frequency := maxi(1, int(config.get("hands_per_level", config.get("blind_frequency", 4 if state.seats.size() == 2 else 6))))
	var schedule: Array = config.get("small_blinds", config.get("blind_schedule", DEFAULT_BLINDS))
	if schedule.is_empty(): schedule = DEFAULT_BLINDS
	state.blind_level = mini(int((int(state.hand_number) - 1) / frequency), schedule.size() - 1)
	state.small_blind = int(config.get("small_blind", schedule[state.blind_level]))
	state.big_blind = int(config.get("big_blind", int(state.small_blind) * 2))
	assert(state.big_blind > 0 and state.small_blind >= 0)
	state.phase = "preflop"
	state.board = []
	state.burns = []
	state.actions = []
	state.reveals = {}
	state.pots = []
	state.result = {}
	state.current_bet = state.big_blind
	state.last_full_raise = state.big_blind
	for seat in state.seats:
		seat.hole_cards = []
		seat.folded = seat.stack == 0
		seat.all_in = seat.stack == 0
		seat.street_contribution = 0
		seat.hand_contribution = 0
		seat.acted = false
		seat.acted_at_bet_level = -1
		seat.starting_hand_stack = seat.stack
	if sb >= 0: _pay(sb, int(state.small_blind))
	_pay(bb, int(state.big_blind))
	var hand_seed := _deck_rng.randi_range(1, 2147483647)
	_deck = Deck.new(hand_seed)
	var first_card := _next_in(int(state.button), survivors)
	for round_index in range(2):
		var id := first_card
		for offset in range(survivors.size()):
			state.seats[id].hole_cards.append(_deck.draw())
			id = _next_in(id, survivors)
	state.actor = sb if survivors.size() == 2 else _next_in(bb, survivors)
	# Scan from the normal first actor; blind all-ins may have no action.
	_resolve((int(state.actor) + state.seats.size() - 1) % state.seats.size())

func legal_actions(seat_id: int) -> Dictionary:
	return Rules.legal_actions(state, seat_id)

## Use this boundary for untyped UI/agent/JSON commands. The typed method below
## cannot detect fractions after GDScript's automatic conversion to int.
func apply_command(command: Dictionary) -> Dictionary:
	var id: Variant = command.get("seat_id", -1)
	var amount: Variant = command.get("raise_to", 0)
	var revision: Variant = command.get("expected_revision", command.get("revision", -1))
	for value in [id, amount, revision]:
		if not (value is int or (value is float and is_finite(value) and value == floor(value))):
			return {"ok": false, "error": "Command numbers must be integers"}
	if not command.get("kind") is String:
		return {"ok": false, "error": "Command kind must be a string"}
	return apply_action(int(id), command.kind, int(amount), int(revision))

func apply_action(seat_id: int, kind: String, raise_to: int = 0, expected_revision: int = -1) -> Dictionary:
	if state.is_empty(): return {"ok": false, "error": "Tournament not started"}
	if expected_revision >= 0 and expected_revision != int(state.revision):
		return {"ok": false, "error": "Stale revision"}
	var error := Rules.validate(state, seat_id, kind, raise_to)
	if not error.is_empty(): return {"ok": false, "error": error}
	var seat: Dictionary = state.seats[seat_id]
	var old_bet := int(state.current_bet)
	match kind:
		"FOLD": seat.folded = true
		"CALL": _pay(seat_id, maxi(0, old_bet - int(seat.street_contribution)))
		"ALL_IN": _pay(seat_id, int(seat.stack))
		"BET_TO", "RAISE_TO": _pay(seat_id, raise_to - int(seat.street_contribution))
	if int(seat.street_contribution) > old_bet:
		var increase := int(seat.street_contribution) - old_bet
		if increase >= int(state.last_full_raise): state.last_full_raise = increase
		state.current_bet = int(seat.street_contribution)
	seat.acted = true
	seat.acted_at_bet_level = state.current_bet
	state.revision += 1
	state.actions.append({"seat_id": seat_id, "kind": kind, "raise_to": int(seat.street_contribution), "phase": state.phase, "revision": state.revision})
	_resolve(seat_id)
	return {"ok": true, "error": ""}

func _pay(id: int, requested: int) -> void:
	var seat: Dictionary = state.seats[id]
	var paid := mini(int(seat.stack), requested)
	assert(paid >= 0)
	seat.stack -= paid
	seat.street_contribution += paid
	seat.hand_contribution += paid
	seat.all_in = seat.stack == 0

func _resolve(after: int) -> void:
	var live: Array[int] = []
	var able: Array[int] = []
	for seat in state.seats:
		if not seat.folded:
			live.append(int(seat.id))
			if seat.stack > 0: able.append(int(seat.id))
	if live.size() == 1:
		_settle(false)
		return
	var pending: Array[int] = []
	for id in able:
		var seat: Dictionary = state.seats[id]
		var response_bet := int(state.current_bet)
		if able.size() == 1:
			# A nominal short BB cannot demand another decision from a player
			# who already covers every actual live all-in contribution.
			response_bet = 0
			for other_id in live:
				if other_id != id:
					response_bet = maxi(response_bet, int(state.seats[other_id].street_contribution))
		if seat.street_contribution < response_bet or (able.size() > 1 and not seat.acted): pending.append(id)
	if not pending.is_empty():
		state.actor = _next_in(after, pending)
		return
	state.actor = -1
	if able.size() <= 1:
		_reveal()
		while state.board.size() < 5: _deal_street()
		_settle(true)
	elif state.phase == "river":
		_settle(true)
	else:
		_deal_street()
		state.current_bet = 0
		state.last_full_raise = state.big_blind
		for seat in state.seats:
			seat.street_contribution = 0
			seat.acted = false
			seat.acted_at_bet_level = -1
		_resolve(int(state.button))

func _deal_street() -> void:
	state.burns.append(_deck.draw())
	var count := 1
	match state.phase:
		"preflop":
			state.phase = "flop"
			count = 3
		"flop": state.phase = "turn"
		"turn": state.phase = "river"
	for index in range(count): state.board.append(_deck.draw())

func _reveal() -> void:
	for seat in state.seats:
		if not seat.folded: state.reveals[int(seat.id)] = seat.hole_cards.duplicate()

func _settle(showdown: bool) -> void:
	var refunds := Pots.refund_uncalled(state.seats)
	var pots := Pots.build_pots(state.seats)
	var awards := {}
	var descriptions := {}
	var scores := {}
	if showdown:
		_reveal()
		for seat in state.seats:
			if not seat.folded:
				var cards: Array[int] = []
				cards.assign(seat.hole_cards)
				cards.append_array(state.board)
				scores[int(seat.id)] = Evaluator.evaluate(cards)
				descriptions[int(seat.id)] = Evaluator.describe(cards)
	for pot in pots:
		var winners: Array[int] = []
		for id in pot.eligible_ids:
			if winners.is_empty():
				winners.append(id)
			elif showdown:
				var comparison := _compare(scores[id], scores[winners[0]])
				if comparison > 0: winners = [id]
				elif comparison == 0: winners.append(id)
		var split := Pots.split_award(int(pot.amount), winners, int(state.button), state.seats.size())
		pot.awards = split
		for id in split: awards[id] = int(awards.get(id, 0)) + int(split[id])
	for id in awards: state.seats[int(id)].stack += int(awards[id])
	var winners: Array[int] = []
	for id in awards:
		if int(awards[id]) > 0: winners.append(int(id))
	winners.sort()
	state.pots = pots
	state.result = {"awards": awards, "refunds": refunds, "reason": "showdown" if showdown else "fold", "winners": winners, "descriptions": descriptions, "reveals": state.reveals.duplicate(true)}
	for seat in state.seats:
		seat.hand_contribution = 0
		seat.street_contribution = 0
		seat.all_in = seat.stack == 0
	state.phase = "settled"
	state.actor = -1
	if state.seats[0].stack == 0: state.status = "lost"
	elif state.seats[0].stack == state.initial_chips: state.status = "won"

static func _compare(a: Array, b: Array) -> int:
	for index in range(a.size()):
		if a[index] != b[index]: return 1 if a[index] > b[index] else -1
	return 0

func _next_in(after: int, ids: Array) -> int:
	for offset in range(1, state.seats.size() + 1):
		var id: int = (after + offset) % state.seats.size()
		if ids.has(id): return id
	return -1

func observation(seat_id: int) -> Dictionary:
	var own: Array = []
	if seat_id >= 0 and seat_id < state.seats.size(): own = state.seats[seat_id].hole_cards.duplicate()
	var pot := 0
	var stacks: Array[int] = []
	for seat in state.seats:
		pot += int(seat.hand_contribution)
		stacks.append(int(seat.stack))
	return {"own_cards": own, "public_board": state.board.duplicate(), "board": state.board.duplicate(), "public_stacks": stacks, "seats": State.public_seats(state.seats), "public_pot": pot, "legal_actions": legal_actions(seat_id), "actor": int(state.actor), "phase": state.phase, "button": int(state.button), "revision": int(state.revision), "reveals": state.reveals.duplicate(true), "public_actions": state.actions.duplicate(true)}

func snapshot() -> Dictionary:
	var data := state.duplicate(true)
	data.deck = _deck.snapshot()
	data.deck_rng_state = str(_deck_rng.state)
	data.deck_rng_seed = str(_deck_rng.seed)
	return data

func restore(data: Dictionary) -> void:
	if not State.valid_snapshot(data): return
	var restored: Dictionary = State.normalize(data)
	if not restored.has("seats") or not restored.has("deck"): return
	var deck_data: Dictionary = restored.deck
	var candidate = Deck.new(1)
	candidate.restore(deck_data)
	if candidate.snapshot() != deck_data: return
	_deck = candidate
	_deck_rng.seed = int(restored.get("deck_rng_seed", "1"))
	_deck_rng.state = int(restored.get("deck_rng_state", "1"))
	restored.erase("deck")
	restored.erase("deck_rng_state")
	restored.erase("deck_rng_seed")
	state = restored
