class_name PokerDeck
extends RefCounted

var cards: Array[int] = []
var cursor: int = 0

func _init(seed_value: int = 0) -> void:
	init(seed_value)

## Zero requests fresh randomness; nonzero seeds reproduce the same deck.
func init(seed_value: int = 0) -> void:
	var rng := RandomNumberGenerator.new()
	if seed_value == 0:
		rng.randomize()
	else:
		rng.seed = seed_value
	cards.clear()
	cursor = 0
	for id in range(52):
		cards.append(id)
	for index in range(51, 0, -1):
		var other: int = rng.randi_range(0, index)
		var temporary: int = cards[index]
		cards[index] = cards[other]
		cards[other] = temporary

func draw() -> int:
	if cursor >= cards.size():
		return -1
	var id: int = cards[cursor]
	cursor += 1
	return id

func snapshot() -> Dictionary:
	return {"cards": cards.duplicate(), "cursor": cursor}

## Accept native and JSON-decoded snapshots atomically; ignore malformed data.
func restore(data: Dictionary) -> void:
	var raw_cards: Variant = data.get("cards")
	var raw_cursor: Variant = data.get("cursor")
	if not raw_cards is Array or raw_cards.size() != 52:
		return
	if not _is_integer(raw_cursor) or raw_cursor < 0 or raw_cursor > 52:
		return
	var restored: Array[int] = []
	var seen: Dictionary = {}
	for value: Variant in raw_cards:
		if not _is_integer(value) or value < 0 or value > 51:
			return
		var id := int(value)
		if seen.has(id):
			return
		seen[id] = true
		restored.append(id)
	cards = restored
	cursor = int(raw_cursor)

static func _is_integer(value: Variant) -> bool:
	return value is int or (value is float and is_finite(value) and value == floor(value))
