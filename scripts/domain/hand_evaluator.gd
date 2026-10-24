class_name HandEvaluator
extends RefCounted

const Card = preload("res://scripts/domain/card.gd")

## Invalid card sets return an empty score. Valid scores always have six entries.
static func evaluate(cards: Array[int]) -> Array[int]:
	if cards.size() < 2 or cards.size() > 7:
		return []
	var seen: int = 0
	for id in cards:
		if id < 0 or id > 51:
			return []
		var bit: int = 1 << id
		if seen & bit:
			return []
		seen |= bit
	return _score(cards)

static func compare(a: Array[int], b: Array[int]) -> int:
	return _compare_scores(evaluate(a), evaluate(b))

static func describe(cards: Array[int]) -> String:
	var score: Array[int] = evaluate(cards)
	if score.is_empty():
		return "Mão inválida"
	var names: Array[String] = ["Carta alta", "Par", "Dois pares", "Trinca", "Sequência", "Flush", "Full house", "Quadra", "Straight flush"]
	return names[score[0]]

static func _compare_scores(a: Array[int], b: Array[int]) -> int:
	for index in range(mini(a.size(), b.size())):
		if a[index] != b[index]:
			return 1 if a[index] > b[index] else -1
	if a.size() == b.size():
		return 0
	return 1 if a.size() > b.size() else -1

static func _score(cards: Array[int]) -> Array[int]:
	var counts: Array[int] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
	var suit_counts: Array[int] = [0, 0, 0, 0]
	var suit_masks: Array[int] = [0, 0, 0, 0]
	var rank_mask: int = 0
	for id in cards:
		var value: int = Card.rank(id)
		var suit: int = Card.suit(id)
		counts[value] += 1
		suit_counts[suit] += 1
		var bit: int = 1 << value
		# Ace also occupies rank one exclusively for the wheel.
		if value == 14:
			bit |= 2
		rank_mask |= bit
		suit_masks[suit] |= bit
	var flush_mask: int = 0
	for suit in range(4):
		if suit_counts[suit] >= 5:
			flush_mask = suit_masks[suit]
			var suited_straight: int = _straight_high(flush_mask)
			if suited_straight > 0:
				return [8, suited_straight, 0, 0, 0, 0]
			break

	# Descending unique ranks serve every kicker selection; a second trip can
	# supply the pair of a full house, and a third pair can supply a kicker.
	var ranks: Array[int] = []
	var quad: int = 0
	var trip: int = 0
	var pairs: Array[int] = []
	for value in range(14, 1, -1):
		var count: int = counts[value]
		if count == 0:
			continue
		ranks.append(value)
		if count == 4:
			quad = value
		if count >= 3 and trip == 0:
			trip = value
		if count >= 2:
			pairs.append(value)

	var result: Array[int] = []
	var excluded_a: int = 0
	var excluded_b: int = 0
	var kicker_count: int = 0
	if quad > 0:
		for value in ranks:
			if value != quad:
				return [7, quad, value, 0, 0, 0]
		return [7, quad, 0, 0, 0, 0]
	elif trip > 0 and pairs.size() >= 2:
		var pair: int = pairs[0] if pairs[0] != trip else pairs[1]
		return [6, trip, pair, 0, 0, 0]
	elif flush_mask != 0:
		result = [5]
		for value in range(14, 1, -1):
			if flush_mask & (1 << value):
				result.append(value)
				if result.size() == 6:
					return result
	else:
		var straight: int = _straight_high(rank_mask) if cards.size() >= 5 else 0
		if straight > 0:
			return [4, straight, 0, 0, 0, 0]
	if trip > 0:
		result = [3, trip]
		excluded_a = trip
		kicker_count = 2
	elif pairs.size() >= 2:
		result = [2, pairs[0], pairs[1]]
		excluded_a = pairs[0]
		excluded_b = pairs[1]
		kicker_count = 1
	elif pairs.size() == 1:
		result = [1, pairs[0]]
		excluded_a = pairs[0]
		kicker_count = 3
	else:
		result = [0]
		kicker_count = 5
	for value in ranks:
		if value == excluded_a or value == excluded_b:
			continue
		result.append(value)
		kicker_count -= 1
		if kicker_count == 0:
			break
	while result.size() < 6:
		result.append(0)
	return result

static func _straight_high(mask: int) -> int:
	# A surviving bit marks the low rank of a five-rank run.
	var runs: int = mask & (mask >> 1) & (mask >> 2) & (mask >> 3) & (mask >> 4)
	if runs == 0:
		return 0
	for low in range(10, 0, -1):
		if runs & (1 << low):
			return low + 4
	return 0
