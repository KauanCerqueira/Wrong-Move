class_name BettingRules
extends RefCounted

static func legal_actions(state: Dictionary, seat_id: int) -> Dictionary:
	var result := {"to_call": 0, "check_allowed": false, "fold_allowed": false, "raise_allowed": false, "all_in_allowed": false, "min_raise_to": 0, "max_raise_to": 0, "call_allowed": false}
	if state.get("phase", "settled") == "settled" or state.get("actor", -1) != seat_id:
		return result
	if seat_id < 0 or seat_id >= state.seats.size():
		return result
	var seat: Dictionary = state.seats[seat_id]
	if seat.folded or seat.all_in or seat.stack <= 0:
		return result
	var owed := maxi(0, int(state.current_bet) - int(seat.street_contribution))
	var maximum := int(seat.street_contribution) + int(seat.stack)
	var increment := int(state.last_full_raise)
	var minimum := int(state.current_bet) + increment if state.current_bet > 0 else int(state.big_blind)
	var reopened: bool = not seat.get("acted", false) or int(seat.get("acted_at_bet_level", -1)) == 0 or int(state.current_bet) - int(seat.get("acted_at_bet_level", -1)) >= increment
	var opponent_can_pay := false
	for other in state.seats:
		if other.id != seat_id and not other.folded and other.stack > 0:
			opponent_can_pay = true
	result.to_call = mini(int(seat.stack), owed)
	result.check_allowed = owed == 0
	result.fold_allowed = owed > 0
	result.call_allowed = owed > 0
	result.min_raise_to = minimum
	result.max_raise_to = maximum
	result.raise_allowed = reopened and opponent_can_pay and maximum > int(state.current_bet)
	result.all_in_allowed = maximum <= int(state.current_bet) or result.raise_allowed
	return result

static func validate(state: Dictionary, seat_id: int, kind: String, raise_to: int) -> String:
	var legal := legal_actions(state, seat_id)
	if state.get("actor", -1) != seat_id or state.get("phase", "settled") == "settled":
		return "Not this seat's turn"
	match kind:
		"FOLD":
			if not legal.fold_allowed: return "Fold unavailable"
		"CHECK":
			if not legal.check_allowed: return "Check faces a bet"
		"CALL":
			if not legal.call_allowed: return "Nothing to call"
		"ALL_IN":
			if not legal.all_in_allowed: return "Action has not reopened"
		"BET_TO", "RAISE_TO":
			if kind == "BET_TO" and state.current_bet != 0: return "Use RAISE_TO facing a bet"
			if kind == "RAISE_TO" and state.current_bet == 0: return "Use BET_TO to open"
			if not legal.raise_allowed: return "Raise unavailable"
			if raise_to > legal.max_raise_to or raise_to <= int(state.current_bet): return "Raise outside stack or bet"
			if raise_to < legal.min_raise_to and raise_to != legal.max_raise_to: return "Raise below full minimum"
		_:
			return "Unknown action"
	return ""
