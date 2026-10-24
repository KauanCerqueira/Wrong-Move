extends RefCounted
const Tournament = preload("res://scripts/domain/tournament.gd")
const Cases = preload("res://tests/domain/rules_cases.gd")

func run() -> Array[String]:
	var failures: Array[String] = []
	var t := Tournament.new()
	t.start(3, 42, {"decision_noise": 0.2})
	if Cases.chips(t.state) != 3000 or t.state.board.size() != 0:
		failures.append("Initial chips/board invalid")
	var view := t.observation(0)
	for seat in view.seats:
		if seat.has("hole_cards"):
			failures.append("Observation leaks private cards")
	view.own_cards.clear()
	if t.state.seats[0].hole_cards.size() != 2:
		failures.append("Observation aliases private state")
	var restored := Tournament.new()
	restored.restore(JSON.parse_string(JSON.stringify(t.snapshot())))
	if JSON.stringify(restored.snapshot()) != JSON.stringify(t.snapshot()):
		failures.append("JSON snapshot does not roundtrip")
	var before := JSON.stringify(t.snapshot())
	if t.apply_action((t.state.actor + 1) % 3, "FOLD").ok or JSON.stringify(t.snapshot()) != before:
		failures.append("Out-of-turn action mutated state")
	if t.apply_action(t.state.actor, "CALL", 0, int(t.state.revision) - 1).ok or JSON.stringify(t.snapshot()) != before:
		failures.append("Stale revision accepted")
	var corrupt := t.snapshot()
	corrupt.seats[0].stack = -1
	t.restore(corrupt)
	corrupt = t.snapshot()
	corrupt.seats[0].stack = 999.5
	t.restore(corrupt)
	corrupt = t.snapshot()
	corrupt.seats[0].hole_cards[1] = corrupt.seats[0].hole_cards[0]
	t.restore(corrupt)
	if JSON.stringify(t.snapshot()) != before:
		failures.append("Invalid snapshot was not rejected atomically")
	# A saved decision must produce the same action, deck runout and next deck.
	for index in range(40):
		if t.state.phase == "settled":
			if t.state.status != "active": break
			t.next_hand()
			restored.next_hand()
		else:
			var legal := t.legal_actions(t.state.actor)
			var kind := "ALL_IN" if legal.all_in_allowed else ("CHECK" if legal.check_allowed else "CALL")
			t.apply_action(t.state.actor, kind)
			restored.apply_action(restored.state.actor, kind)
		if JSON.stringify(t.snapshot()) != JSON.stringify(restored.snapshot()):
			failures.append("Restored game diverged from original")
			break
	# Folding human0 must leave the other players' decision running.
	t.start(3, 42)
	while t.state.actor != 0 and t.state.phase != "settled":
		t.apply_action(t.state.actor, "CALL")
	t.apply_action(0, "FOLD")
	if t.state.status != "active" or t.state.phase == "settled" or not t.state.reveals.is_empty():
		failures.append("Human fold incorrectly terminates/reveals hand")
	for count in range(2, 7):
		var ids: Array[int] = []
		for id in range(count): ids.append(id)
		for order in _orders(ids):
			t.start(count, 1)
			for eliminated in order:
				var old_bb: int = t.state.big_blind_seat
				var old_ring: Array = t.state.last_dealt_seat_ring.duplicate()
				# Settle the fixture without altering physical seat identities.
				for seat in t.state.seats:
					seat.stack += seat.hand_contribution
					seat.hand_contribution = 0
					seat.street_contribution = 0
				var survivors: Array[int] = []
				for seat in t.state.seats:
					if seat.stack > 0 and seat.id != eliminated: survivors.append(int(seat.id))
				if survivors.size() < 2: break
				t.state.seats[survivors[0]].stack += t.state.seats[eliminated].stack
				t.state.seats[eliminated].stack = 0
				t.state.phase = "settled"
				t.state.status = "active"
				var expected_bb := -1
				for offset in range(1, count + 1):
					var id := (old_bb + offset) % count
					if survivors.has(id):
						expected_bb = id
						break
				var expected_button: int = old_ring[(old_ring.find(old_bb) + old_ring.size() - 1) % old_ring.size()]
				if survivors.size() == 2:
					expected_button = survivors[0] if survivors[1] == expected_bb else survivors[1]
				t.next_hand()
				if t.state.big_blind_seat != expected_bb or t.state.button != expected_button:
					failures.append("Dead-button rotation count%d order%s" % [count, str(order)])
					return failures
	return failures

func _orders(ids: Array[int]) -> Array:
	if ids.size() == 1: return [ids.duplicate()]
	var result: Array = []
	for id in ids:
		var remaining: Array[int] = ids.duplicate()
		remaining.erase(id)
		for tail in _orders(remaining):
			var order: Array = [id]
			order.append_array(tail)
			result.append(order)
	return result
