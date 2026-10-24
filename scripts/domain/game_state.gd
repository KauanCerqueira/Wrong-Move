class_name PokerGameState
extends RefCounted

## JSON numbers become floats; recursively normalize domain integers and ID keys.
static func normalize(value: Variant) -> Variant:
	if value is Dictionary:
		var result := {}
		for key in value:
			var normalized_key: Variant = key
			if key is String and key.is_valid_int(): normalized_key = int(key)
			result[normalized_key] = normalize(value[key])
		return result
	if value is Array:
		var result: Array = []
		for item in value: result.append(normalize(item))
		return result
	if value is float and is_finite(value) and value == floor(value): return int(value)
	return value

static func public_seats(seats: Array) -> Array:
	var result: Array = []
	for seat in seats:
		result.append({"id": int(seat.id), "stack": int(seat.stack), "folded": bool(seat.folded), "all_in": bool(seat.all_in)})
	return result

## Validate before normalization so fractional/corrupt saves cannot be truncated.
static func valid_snapshot(data: Dictionary) -> bool:
	for key in ["seats", "board", "burns", "last_dealt_seat_ring", "actions", "pots"]:
		if not data.get(key) is Array: return false
	for key in ["config", "result", "reveals", "deck"]:
		if not data.get(key) is Dictionary: return false
	for key in ["hand_number", "revision", "button", "actor", "current_bet", "last_full_raise", "big_blind", "small_blind", "initial_chips", "small_blind_seat", "big_blind_seat", "blind_level"]:
		if not _integer(data.get(key)): return false
	if data.seats.size() < 2 or data.seats.size() > 6: return false
	if data.get("phase") not in ["preflop", "flop", "turn", "river", "settled"] or data.get("status") not in ["active", "won", "lost"]: return false
	if data.hand_number < 1 or data.revision < 1 or data.current_bet < 0 or data.big_blind < 1 or data.last_full_raise < 1 or data.small_blind < 0: return false
	if data.button < 0 or data.button >= data.seats.size(): return false
	if data.big_blind_seat < 0 or data.big_blind_seat >= data.seats.size(): return false
	if data.small_blind_seat < -1 or data.small_blind_seat >= data.seats.size(): return false
	if data.phase == "settled":
		if data.actor != -1: return false
	elif data.actor < 0 or data.actor >= data.seats.size() or data.status != "active": return false
	var expected_board: Dictionary = {"preflop": 0, "flop": 3, "turn": 4, "river": 5}
	if data.phase != "settled" and data.board.size() != expected_board[data.phase]: return false
	if data.board.size() not in [0, 3, 4, 5]: return false
	var expected_burns := maxi(0, data.board.size() - 2)
	if data.burns.size() != expected_burns: return false
	var chips := 0
	var seen := {}
	for id in range(data.seats.size()):
		var seat: Variant = data.seats[id]
		if not seat is Dictionary or not seat.get("hole_cards") is Array: return false
		for key in ["id", "stack", "street_contribution", "hand_contribution", "acted_at_bet_level"]:
			if not _integer(seat.get(key)): return false
		for key in ["folded", "all_in", "acted"]:
			if not seat.get(key) is bool: return false
		if seat.id != id or seat.stack < 0 or seat.street_contribution < 0 or seat.hand_contribution < seat.street_contribution: return false
		if seat.all_in != (seat.stack == 0): return false
		if seat.hole_cards.size() not in [0, 2]: return false
		chips += int(seat.stack) + int(seat.hand_contribution)
		for card in seat.hole_cards:
			if not _add_card(card, seen): return false
	for card in data.board:
		if not _add_card(card, seen): return false
	for card in data.burns:
		if not _add_card(card, seen): return false
	if chips != data.initial_chips or chips <= 0: return false
	var deck: Dictionary = data.deck
	if not deck.get("cards") is Array or deck.cards.size() != 52 or not _integer(deck.get("cursor")): return false
	if int(deck.cursor) != seen.size(): return false
	var deck_seen := {}
	for index in range(52):
		var card: Variant = deck.cards[index]
		if not _add_card(card, deck_seen): return false
		if index < deck.cursor and not seen.has(int(card)): return false
	for key in ["deck_rng_seed", "deck_rng_state"]:
		if not data.get(key) is String or not data[key].is_valid_int(): return false
	return true

static func _integer(value: Variant) -> bool:
	return value is int or (value is float and is_finite(value) and value == floor(value))

static func _add_card(card: Variant, seen: Dictionary) -> bool:
	if not _integer(card) or card < 0 or card > 51 or seen.has(int(card)): return false
	seen[int(card)] = true
	return true
