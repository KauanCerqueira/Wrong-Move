extends RefCounted
const Rules = preload("res://scripts/domain/betting_rules.gd")
const Cases = preload("res://tests/domain/rules_cases.gd")
const Tournament = preload("res://scripts/domain/tournament.gd")

func run() -> Array[String]:
	var failures: Array[String] = []
	var a := Cases.seat(0, 900, 100)
	a.acted = true
	a.acted_at_bet_level = 100
	var s := {"seats": [a, Cases.seat(1, 800, 200)], "actor": 0, "phase": "turn", "current_bet": 200, "last_full_raise": 100, "big_blind": 20}
	var legal := Rules.legal_actions(s, 0)
	if not legal.raise_allowed or legal.min_raise_to != 300:
		failures.append("Cumulative short raises must reopen at 100 faced")
	a.acted_at_bet_level = 150
	if Rules.legal_actions(s, 0).raise_allowed:
		failures.append("Only 50 faced must not reopen")
	a.acted_at_bet_level = 0
	s.current_bet = 5
	s.last_full_raise = 20
	a.street_contribution = 0
	legal = Rules.legal_actions(s, 0)
	if not legal.raise_allowed or legal.min_raise_to != 25:
		failures.append("Check then opening all-in5 must permit raise25")
	var t := Tournament.new()
	t.start(3, 7, {"button": 0})
	var actor: int = t.state.actor
	if not t.apply_action(actor, "RAISE_TO", 60).ok or t.legal_actions(t.state.actor).min_raise_to != 100:
		failures.append("Raise60 over BB20 must make next minimum100")
	var unchanged := JSON.stringify(t.snapshot())
	if t.apply_action(t.state.actor, "RAISE_TO", 99).ok or JSON.stringify(t.snapshot()) != unchanged:
		failures.append("Under-minimum non-all-in raise must fail atomically")
	if t.apply_command({"seat_id": t.state.actor, "kind": "RAISE_TO", "raise_to": 100.5}).ok or JSON.stringify(t.snapshot()) != unchanged:
		failures.append("Fractional command must fail before integer coercion")
	# Force a short BB, retaining the nominal bet and raise increment.
	t.start(3, 12)
	var bb: int = t.state.big_blind_seat
	t.state.seats[bb].stack += int(t.state.seats[bb].street_contribution)
	t.state.seats[bb].hand_contribution = 7
	t.state.seats[bb].street_contribution = 7
	t.state.seats[bb].stack = 0
	t.state.seats[bb].all_in = true
	legal = t.legal_actions(t.state.actor)
	if legal.min_raise_to != 40 or legal.to_call != 20:
		failures.append("Short BB7 must leave nominal call20/minimum40")
	# Every limper acts; BB retains its option and flop checks visit all players.
	t.start(4, 4)
	for index in range(3):
		if not t.apply_action(t.state.actor, "CALL").ok: failures.append("Limp rejected")
	if t.state.actor != t.state.big_blind_seat or not t.legal_actions(t.state.actor).check_allowed:
		failures.append("BB lost its option after limps")
	t.apply_action(t.state.actor, "CHECK")
	for index in range(3):
		t.apply_action(t.state.actor, "CHECK")
		if t.state.phase != "flop": failures.append("Street closed before all four checked")
	t.apply_action(t.state.actor, "CHECK")
	if t.state.phase != "turn" or t.state.burns.size() != 2:
		failures.append("Street/burn progression invalid")
	# A bet100; B short150; C call150; D short200; A call200.
	t.start(4, 9)
	t.state.phase = "turn"
	t.state.current_bet = 100
	t.state.last_full_raise = 100
	t.state.actor = 1
	t.state.seats = [Cases.seat(0, 1000, 100), Cases.seat(1, 50, 100), Cases.seat(2, 1000, 100), Cases.seat(3, 100, 100)]
	t.state.seats[0].acted = true
	t.state.seats[0].acted_at_bet_level = 100
	t.apply_action(1, "ALL_IN")
	t.apply_action(2, "CALL")
	t.apply_action(3, "ALL_IN")
	if t.state.actor != 0 or not t.legal_actions(0).raise_allowed or t.legal_actions(0).min_raise_to != 300:
		failures.append("Two actual short raises must reopen A")
	t.apply_action(0, "CALL")
	if t.state.actor != 2 or t.legal_actions(2).raise_allowed or t.legal_actions(2).all_in_allowed:
		failures.append("C facing only50 must have no raise or raising all-in")
	# Heads-up, posted SB10 already covers the all-in BB7: no phantom call.
	t.start(2, 6)
	var sb: int = t.state.small_blind_seat
	bb = t.state.big_blind_seat
	t.state.seats[bb].stack = 0
	t.state.seats[bb].hand_contribution = 7
	t.state.seats[bb].street_contribution = 7
	t.state.seats[bb].all_in = true
	t._resolve(bb)
	if t.state.phase != "settled" or t.state.board.size() != 5 or t.state.result.refunds.get(sb, 0) != 3:
		failures.append("Covered short heads-up BB must run out without phantom call")
	return failures
