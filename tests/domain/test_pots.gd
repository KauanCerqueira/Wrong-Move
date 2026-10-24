extends RefCounted
const Pots = preload("res://scripts/domain/pot_settlement.gd")
const Cases = preload("res://tests/domain/rules_cases.gd")
const Tournament = preload("res://scripts/domain/tournament.gd")

func run() -> Array[String]:
	var failures: Array[String] = []
	var seats := [Cases.seat(0, 0, 100), Cases.seat(1, 0, 250), Cases.seat(2, 0, 400)]
	var refund := Pots.refund_uncalled(seats)
	var pots := Pots.build_pots(seats)
	if refund.get(2, 0) != 150 or pots.size() != 2 or pots[0].amount != 300 or pots[1].amount != 300:
		failures.append("100/250/400 must refund150 and form 300/300 pots")
	seats = [Cases.seat(0, 0, 100), Cases.seat(1, 0, 250), Cases.seat(2, 0, 400), Cases.seat(3, 0, 400, true)]
	pots = Pots.build_pots(seats)
	if pots.size() != 3 or pots[0].amount != 400 or pots[1].amount != 450 or pots[2].amount != 300 or pots[2].eligible_ids != [2]:
		failures.append("Folded contributions must remain in side pots")
	var awards := Pots.split_award(5, [0, 2], 0, 3)
	if awards.get(2) != 3 or awards.get(0) != 2:
		failures.append("Odd chip must go clockwise left of button")
	var t := Tournament.new()
	t.start(4, 1)
	t.state.seats = [Cases.seat(0, 0, 100), Cases.seat(1, 0, 250), Cases.seat(2, 0, 400), Cases.seat(3, 0, 400, true)]
	t.state.seats[0].hole_cards = [12, 25] # AA
	t.state.seats[1].hole_cards = [11, 24] # KK
	t.state.seats[2].hole_cards = [10, 23] # QQ
	t.state.seats[3].hole_cards = [5, 18]
	t.state.board = [0, 16, 32, 48, 8]
	t.state.initial_chips = 1150
	t.state.button = 0
	t._settle(true)
	if t.state.result.awards != {0: 400, 1: 450, 2: 300} or t.state.reveals.has(3):
		failures.append("Showdown must independently resolve main and both side pots")
	# The board plays: tie every contested pot, distribute its odd chips separately.
	t.state.seats = [Cases.seat(0, 0, 100), Cases.seat(1, 0, 250), Cases.seat(2, 0, 400), Cases.seat(3, 0, 400, true)]
	for id in range(4): t.state.seats[id].hole_cards = [13 + id * 2, 14 + id * 2]
	t.state.board = [8, 9, 10, 11, 12]
	t.state.reveals = {}
	t._settle(true)
	if t.state.result.awards != {0: 133, 1: 359, 2: 658}:
		failures.append("Board tie must split main/side pots with independent odd chips")
	return failures
