extends RefCounted

const Basic = preload("res://scripts/ai/basic_agent.gd")
const Strategic = preload("res://scripts/ai/strategic_agent.gd")
const Observations = preload("res://tests/integration/test_observation.gd")
const Tournament = preload("res://scripts/domain/tournament.gd")

## Lightweight smoke suite. Full 10,000-observation acceptance is opt-in.
func run() -> Array[String]:
	var failures := run_legality_benchmark(16)
	var observation := Observations.fixture()
	var first := Observations._rng(22)
	var second := Observations._rng(22)
	if Basic.choose_action(observation, first) != Strategic.choose_action(observation, second):
		failures.append("StrategicAgent must preserve BasicAgent API")
	# Validate against the actual domain validator using only its public API.
	for participants in [2, 6]:
		var tournament := Tournament.new()
		tournament.start(participants, 4091, {"starting_stack": 100})
		var stream := Observations._rng(801)
		for decision in range(8):
			if tournament.state.status != "active":
				break
			if tournament.state.phase == "settled":
				tournament.next_hand()
			var actor := int(tournament.state.actor)
			if actor < 0:
				continue
			var action := Basic.choose_action(tournament.observation(actor), stream)
			if not tournament.apply_action(actor, action.kind, int(action.get("raise_to", 0))).ok:
				failures.append("Domain rejected AI action with %d participants: %s" % [participants, action])
				break
	var profiles: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/balance/bot_profiles.json"))
	for level in range(9):
		if int(profiles.equity_samples_by_strength[level]) != Basic.SAMPLES[level] or not is_equal_approx(float(profiles.decision_noise_by_strength[level]), Basic.NOISE[level]):
			failures.append("Executable policy must match balance data at strength %d" % level)
	# Explicit command-line opt-ins; the regular suite stays inexpensive.
	var args := OS.get_cmdline_user_args()
	if "--agents-compute-benchmark" in args:
		print("AGENTS_COMPUTE ", JSON.stringify(benchmark_compute()))
	if "--agents-legality-benchmark" in args:
		failures.append_array(run_legality_benchmark())
	if "--agents-paired-benchmark" in args:
		for levels in [[5, 0], [8, 5]]:
			var report := run_paired_benchmark(2000, levels[0], levels[1])
			print("AGENTS_PAIRED ", JSON.stringify(report))
			if not report.get("passed", false):
				failures.append("Paired strength gate failed: %s" % report)
	return failures

func run_legality_benchmark(count: int = 10000) -> Array[String]:
	var failures: Array[String] = []
	var rng := Observations._rng(4419)
	for index in range(count):
		var observation := Observations.fixture()
		if count > 16:
			# Full acceptance crosses streets, live/folded/all-in opponents,
			# card holdings and public stack representations.
			var cards: Array[int] = []
			while cards.size() < 7:
				var card := rng.randi_range(0, 51)
				if not cards.has(card):
					cards.append(card)
			observation.own_cards = cards.slice(0, 2)
			var board_size: int = [0, 3, 4, 5][index % 4]
			observation.public_board = cards.slice(2, 2 + board_size)
			for seat_id in range(2, rng.randi_range(2, 6)):
				observation.seats.append({"id": seat_id, "stack": 100, "folded": rng.randf() < 0.25, "all_in": rng.randf() < 0.25})
				observation.public_stacks.append(100)
		var current := rng.randi_range(0, 100)
		var contribution := rng.randi_range(0, current)
		var stack := rng.randi_range(1, 1000)
		var increment := rng.randi_range(1, 100)
		var call := mini(stack, current - contribution)
		var maximum := contribution + stack
		var reopened := rng.randf() > 0.2
		observation.public_pot = rng.randi_range(current, 2000)
		observation.public_current_bet = current
		observation.seats[0].stack = stack
		observation.public_stacks[0] = stack
		observation.legal_actions = {"check_allowed": call == 0, "fold_allowed": call > 0, "call_allowed": call > 0, "raise_allowed": reopened and maximum > current, "all_in_allowed": maximum <= current or reopened, "to_call": call, "min_raise_to": current + increment, "max_raise_to": maximum}
		var input := observation.duplicate(true)
		# Exercise the contracted minimal API, including the big-blind check.
		if index % 2 == 0:
			input.erase("public_current_bet")
		var action := Basic.choose_action(input, Observations._rng(index + 71), index % 9, ["cauteloso", "equilibrado", "agressivo"][index % 3])
		if not _legal(action, observation):
			failures.append("Illegal action at observation %d: %s" % [index, action])
			break
		for candidate in Basic.raise_candidates(input):
			if not _legal(candidate, observation):
				failures.append("Illegal raise candidate at observation %d" % index)
	return failures

## Development timing only; never branches the strategy on elapsed time.
func benchmark_compute(iterations: int = 1) -> Array[Dictionary]:
	var results: Array[Dictionary] = []
	for strength in [0, 5, 8]:
		for board_size in [0, 3, 5]:
			for participants in [2, 6]:
				var observation := Observations.fixture()
				observation.public_board = observation.public_board.slice(0, board_size)
				for seat_id in range(2, participants):
					observation.seats.append({"id": seat_id, "stack": 900, "folded": false, "all_in": false})
					observation.public_stacks.append(900)
				var started := Time.get_ticks_usec()
				for index in range(iterations):
					Basic.choose_action(observation, Observations._rng(index + 42), strength)
				var elapsed := Time.get_ticks_usec() - started
				results.append({"strength": strength, "board_size": board_size, "participants": participants, "iterations": iterations, "elapsed_us": elapsed, "within_500ms_average": elapsed <= 500000 * iterations})
	return results

## Expensive release gate: two tournaments per seed, swapping stronger seat.
## Deck seed and policy seed streams are independent and repeat by seat.
func run_paired_benchmark(pairs: int = 2000, stronger: int = 5, weaker: int = 0) -> Dictionary:
	var wins := 0
	var games := 0
	for pair_index in range(pairs):
		for strong_seat in range(2):
			var tournament := Tournament.new()
			tournament.start(2, pair_index + 8101)
			var streams: Array[RandomNumberGenerator] = [Observations._rng(pair_index * 2 + 99001), Observations._rng(pair_index * 2 + 99002)]
			var decisions := 0
			while tournament.state.status == "active" and decisions < 20000:
				if tournament.state.phase == "settled":
					tournament.next_hand()
					continue
				var actor := int(tournament.state.actor)
				var action := Basic.choose_action(tournament.observation(actor), streams[actor], stronger if actor == strong_seat else weaker)
				var applied := tournament.apply_action(actor, action.kind, int(action.get("raise_to", 0)))
				if not applied.ok:
					return {"passed": false, "error": "Illegal benchmark action", "action": action, "seed": pair_index + 8101}
				decisions += 1
			if tournament.state.status == "active":
				return {"passed": false, "error": "Tournament decision cap reached"}
			games += 1
			if tournament.state.seats[strong_seat].stack > 0:
				wins += 1
	var win_rate := float(wins) / maxi(1, games)
	var threshold := 0.55 if stronger == 5 and weaker == 0 else 0.52
	return {"passed": games > 0 and win_rate >= threshold, "pairs": pairs, "games": games, "stronger": stronger, "weaker": weaker, "wins": wins, "win_rate": win_rate, "threshold": threshold}

static func _legal(action: Dictionary, observation: Dictionary) -> bool:
	var legal: Dictionary = observation.legal_actions
	match action.kind:
		"CHECK": return legal.check_allowed
		"FOLD": return legal.fold_allowed
		"CALL": return legal.call_allowed
		"ALL_IN": return legal.all_in_allowed
		"BET_TO", "RAISE_TO":
			return legal.raise_allowed and int(action.get("raise_to", 0)) >= legal.min_raise_to and int(action.raise_to) <= legal.max_raise_to and int(action.raise_to) > int(observation.public_current_bet) and (action.kind == "BET_TO") == (observation.public_current_bet == 0)
	return false
