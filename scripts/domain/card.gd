class_name PokerCard
extends RefCounted

static func rank(id: int) -> int:
	return id % 13 + 2

static func suit(id: int) -> int:
	return int(id / 13)

static func text(id: int) -> String:
	if id < 0 or id > 51:
		return ""
	var ranks: Array[String] = ["2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K", "A"]
	var suits: Array[String] = ["♣", "♦", "♥", "♠"]
	return ranks[id % 13] + suits[suit(id)]
