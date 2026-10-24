class_name PotSettlement
extends RefCounted

static func refund_uncalled(seats: Array) -> Dictionary:
	var highest := 0
	var second := 0
	var leader := -1
	for seat in seats:
		var amount := int(seat.hand_contribution)
		if amount > highest:
			second = highest
			highest = amount
			leader = int(seat.id)
		else:
			second = maxi(second, amount)
	var refunds := {}
	if highest > second and leader >= 0:
		var excess := highest - second
		var seat: Dictionary = seats[leader]
		seat.stack += excess
		seat.hand_contribution -= excess
		seat.street_contribution = maxi(0, int(seat.street_contribution) - excess)
		seat.all_in = seat.stack == 0
		refunds[leader] = excess
	return refunds

static func build_pots(seats: Array) -> Array:
	var levels: Array[int] = []
	for seat in seats:
		var amount := int(seat.hand_contribution)
		if amount > 0 and not levels.has(amount): levels.append(amount)
	levels.sort()
	var previous := 0
	var pots: Array = []
	for level in levels:
		var contributors: Array[int] = []
		var eligible: Array[int] = []
		for seat in seats:
			if seat.hand_contribution >= level:
				contributors.append(int(seat.id))
				if not seat.folded: eligible.append(int(seat.id))
		assert(not eligible.is_empty(), "Pot without an eligible player")
		pots.append({"amount": (level - previous) * contributors.size(), "contributor_ids": contributors, "eligible_ids": eligible})
		previous = level
	return pots

static func split_award(amount: int, winners: Array, button: int, seat_count: int) -> Dictionary:
	assert(not winners.is_empty())
	var awards := {}
	var share := int(amount / winners.size())
	var remainder := amount % winners.size()
	for id in winners: awards[int(id)] = share
	for offset in range(1, seat_count + 1):
		var id := (button + offset) % seat_count
		if winners.has(id) and remainder > 0:
			awards[id] += 1
			remainder -= 1
	return awards
