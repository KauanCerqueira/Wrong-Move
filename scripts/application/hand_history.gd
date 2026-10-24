class_name HandHistory
extends RefCounted

const Cards = preload("res://scripts/domain/card.gd")

static func capture(tournament: RefCounted) -> Dictionary:
	if tournament.state.phase != "settled":
		return {}
	var observation: Dictionary = tournament.observation(0)
	return {"hand_number": int(tournament.state.hand_number), "board": observation.public_board.duplicate(),
		"own_cards": observation.own_cards.duplicate(), "actions": observation.public_actions.duplicate(true),
		"reveals": observation.reveals.duplicate(true), "result": tournament.state.result.duplicate(true)}

static func describe(history: Dictionary) -> String:
	if history.is_empty():
		return "Conclua uma mão para consultar a revisão."
	var output := "Mão " + str(history.hand_number) + "\nSuas cartas: " + _cards(history.own_cards)
	output += "\nMesa: " + _cards(history.board) + "\n"
	for action: Dictionary in history.actions:
		var who := "Você" if int(action.seat_id) == 0 else "Bot " + str(action.seat_id)
		var kind := str(action.kind)
		var label: String = {"CHECK": "passou (check)", "CALL": "pagou (call)", "FOLD": "desistiu (fold)", "BET_TO": "apostou (bet)", "RAISE_TO": "aumentou (raise)", "ALL_IN": "foi com tudo (all-in)", "POST_SB": "pagou o small blind", "POST_BB": "pagou o big blind"}.get(kind, kind)
		output += "\n" + who + ": " + label
		if kind in ["BET_TO", "RAISE_TO", "ALL_IN", "CALL"]:
			output += " · total da rodada " + str(action.raise_to)
	for id: Variant in history.reveals:
		if str(id) != "0":
			output += "\nBot " + str(id) + " mostrou: " + _cards(history.reveals[id])
	output += "\n\n" + ("Os outros desistiram." if history.result.reason == "fold" else "As mãos foram comparadas no showdown.")
	for id: Variant in history.result.get("awards", {}):
		var who := "Você" if str(id) == "0" else "Bot " + str(id)
		output += "\n" + who + " recebeu " + str(history.result.awards[id]) + " fichas."
	return output

static func _cards(values: Array) -> String:
	var words: PackedStringArray = []
	for value: Variant in values:
		words.append(Cards.text(int(value)))
	return " ".join(words)
