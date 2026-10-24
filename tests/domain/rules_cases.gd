extends RefCounted

static func seat(id: int, stack: int, paid: int = 0, folded: bool = false) -> Dictionary:
	return {"id": id, "stack": stack, "hole_cards": [], "folded": folded, "all_in": stack == 0, "street_contribution": paid, "hand_contribution": paid, "acted": false, "acted_at_bet_level": -1}

static func chips(state: Dictionary) -> int:
	var total := 0
	for s in state.seats:
		total += int(s.stack) + int(s.hand_contribution)
	return total
