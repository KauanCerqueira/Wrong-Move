extends RefCounted

const Deck = preload("res://scripts/domain/deck.gd")
const Card = preload("res://scripts/domain/card.gd")

func run() -> Array[String]:
	var failures: Array[String] = []
	var first := Deck.new(12345)
	var second := Deck.new(12345)
	if first.cards != second.cards:
		failures.append("Equal seeds must reproduce the shuffle")
	if first.cards == Deck.new(54321).cards:
		failures.append("Different seeds should produce different shuffles")
	var seen: Dictionary = {}
	for index in range(52):
		var id: int = first.draw()
		if id < 0 or id > 51 or seen.has(id):
			failures.append("Deck must contain each card exactly once")
		seen[id] = true
	if first.draw() != -1 or first.cursor != 52:
		failures.append("Exhausted deck must return -1 without advancing")
	var saved: Dictionary = second.snapshot()
	var expected: int = second.draw()
	second.restore(saved)
	if second.draw() != expected:
		failures.append("Snapshot must restore the next card")
	saved["cards"][0] = -1
	if second.cards[0] == -1:
		failures.append("Snapshots must not alias deck storage")
	var before: Dictionary = second.snapshot()
	second.restore({"cards": [0, 0], "cursor": 0})
	if second.snapshot() != before:
		failures.append("Malformed snapshot must leave deck intact")
	var restored := Deck.new(987)
	var decoded: Dictionary = JSON.parse_string(JSON.stringify(before))
	restored.restore(decoded)
	if restored.snapshot() != before or restored.draw() != second.draw():
		failures.append("JSON snapshot must preserve deck and cursor")
	var duplicate_cards: Dictionary = before.duplicate(true)
	duplicate_cards["cards"][0] = duplicate_cards["cards"][1]
	var restored_before: Dictionary = restored.snapshot()
	restored.restore(duplicate_cards)
	if restored.snapshot() != restored_before:
		failures.append("A full-sized snapshot with duplicate cards must be rejected")
	for id in range(52):
		if Card.rank(id) != id % 13 + 2 or Card.suit(id) != int(id / 13):
			failures.append("Card rank/suit mapping is incorrect")
	if Card.text(12) != "A♣" or Card.text(51) != "A♠":
		failures.append("Card text must identify rank and suit")
	return failures
