extends RefCounted
const Tournament = preload("res://scripts/domain/tournament.gd")
const Cases = preload("res://tests/domain/rules_cases.gd")

func run() -> Array[String]:
	var failures: Array[String] = []
	for count in range(2, 7):
		for seed_value in range(1, 25):
			var t := Tournament.new()
			t.start(count, seed_value, {"starting_stack": 100, "hands_per_level": 2})
			var rng := RandomNumberGenerator.new()
			rng.seed = seed_value * 701 + count
			var decisions := 0
			while t.state.status == "active" and decisions < 12000:
				if t.state.phase == "settled":
					t.next_hand()
				else:
					var legal := t.legal_actions(t.state.actor)
					var kind := "CHECK" if legal.check_allowed else "CALL"
					var target := 0
					if legal.all_in_allowed and rng.randf() < 0.3:
						kind = "ALL_IN"
					elif legal.raise_allowed and legal.max_raise_to >= legal.min_raise_to and rng.randf() < 0.25:
						kind = "BET_TO" if t.state.current_bet == 0 else "RAISE_TO"
						target = rng.randi_range(int(legal.min_raise_to), int(legal.max_raise_to))
					elif legal.fold_allowed and rng.randf() < 0.12:
						kind = "FOLD"
					if not t.apply_action(t.state.actor, kind, target).ok:
						failures.append("Illegal generated action count=%d seed=%d" % [count, seed_value])
						break
				if decisions % 7 == 0:
					var saved := JSON.stringify(t.snapshot())
					var resumed := Tournament.new()
					resumed.restore(JSON.parse_string(saved))
					if resumed.state.is_empty() or JSON.stringify(resumed.snapshot()) != saved:
						failures.append("JSON restore during simulation count%d seed%d" % [count, seed_value])
						break
					t = resumed
				if Cases.chips(t.state) != count * 100:
					failures.append("Chip conservation count=%d seed=%d" % [count, seed_value])
					break
				decisions += 1
			if decisions >= 12000:
				failures.append("Tournament failed to terminate")
	return failures
