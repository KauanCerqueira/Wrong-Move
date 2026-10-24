extends RefCounted

const Evaluator = preload("res://scripts/domain/hand_evaluator.gd")
const Card = preload("res://scripts/domain/card.gd")

func _cards(ranks: Array[int], suits: Array[int]) -> Array[int]:
	var result: Array[int] = []
	for index in range(ranks.size()):
		result.append(suits[index] * 13 + ranks[index] - 2)
	return result

func run() -> Array[String]:
	var failures: Array[String] = []
	var fixtures: Array = [
		[[14, 11, 9, 5, 2], [0, 1, 2, 3, 0], [0, 14, 11, 9, 5, 2]],
		[[14, 14, 9, 5, 2], [0, 1, 2, 3, 0], [1, 14, 9, 5, 2, 0]],
		[[14, 14, 9, 9, 2], [0, 1, 2, 3, 0], [2, 14, 9, 2, 0, 0]],
		[[9, 9, 9, 14, 2], [0, 1, 2, 3, 0], [3, 9, 14, 2, 0, 0]],
		[[14, 2, 3, 4, 5], [0, 1, 2, 3, 0], [4, 5, 0, 0, 0, 0]],
		[[14, 11, 9, 5, 2], [2, 2, 2, 2, 2], [5, 14, 11, 9, 5, 2]],
		[[9, 9, 9, 2, 2], [0, 1, 2, 3, 0], [6, 9, 2, 0, 0, 0]],
		[[9, 9, 9, 9, 14], [0, 1, 2, 3, 0], [7, 9, 14, 0, 0, 0]],
		[[10, 11, 12, 13, 14], [3, 3, 3, 3, 3], [8, 14, 0, 0, 0, 0]],
		[[14, 14, 14, 13, 13, 13, 2], [0, 1, 2, 0, 1, 2, 0], [6, 14, 13, 0, 0, 0]],
		[[14, 14, 13, 13, 12, 12, 2], [0, 1, 0, 1, 0, 1, 0], [2, 14, 13, 12, 0, 0]],
		[[12, 13, 14, 2, 3], [0, 1, 2, 3, 0], [0, 14, 13, 12, 3, 2]],
		[[14, 13, 9, 5], [0, 0, 0, 0], [0, 14, 13, 9, 5, 0]],
		[[8, 8], [0, 1], [1, 8, 0, 0, 0, 0]],
		[[2, 5, 8, 11, 13, 14, 14], [1, 1, 1, 1, 1, 0, 2], [5, 13, 11, 8, 5, 2]],
		[[5, 6, 7, 8, 9, 14, 14], [2, 2, 2, 2, 2, 0, 1], [8, 9, 0, 0, 0, 0]],
		[[14, 2, 3, 4, 5, 6, 13], [0, 1, 2, 3, 0, 1, 2], [4, 6, 0, 0, 0, 0]],
		[[14, 14, 14, 14, 13, 13, 2], [0, 1, 2, 3, 0, 1, 0], [7, 14, 13, 0, 0, 0]],
		[[14, 14, 14, 13, 13, 12, 12], [0, 1, 2, 0, 1, 0, 1], [6, 14, 13, 0, 0, 0]],
		[[14, 2, 3, 4, 5, 13, 12], [2, 2, 2, 2, 2, 2, 2], [8, 5, 0, 0, 0, 0]],
		[[14, 13, 11, 9, 7, 5, 2], [1, 1, 1, 1, 1, 1, 1], [5, 14, 13, 11, 9, 7]],
		[[14, 14, 13, 13, 12, 12], [0, 1, 0, 1, 0, 1], [2, 14, 13, 12, 0, 0]],
	]
	for index in range(fixtures.size()):
		var fixture: Array = fixtures[index]
		var ranks: Array[int] = []
		var suits: Array[int] = []
		ranks.assign(fixture[0])
		suits.assign(fixture[1])
		if Evaluator.evaluate(_cards(ranks, suits)) != fixture[2]:
			failures.append("Ranking fixture %d failed" % index)
	var board: Array[int] = _cards([10, 11, 12, 13, 14], [0, 0, 0, 0, 0])
	var a: Array[int] = board + _cards([2, 3], [1, 1])
	var b: Array[int] = board + _cards([14, 14], [2, 3])
	if Evaluator.compare(a, b) != 0:
		failures.append("Board playing alone must tie")
	if Evaluator.compare(_cards([8, 8, 14], [0, 1, 2]), _cards([8, 8, 13], [0, 1, 2])) != 1:
		failures.append("Compare must evaluate cards and compare kickers")
	if Evaluator.describe(_cards([8, 8], [0, 1])) != "Par":
		failures.append("Descriptions must be in PT-BR")
	if not Evaluator.evaluate([0, 0]).is_empty() or not Evaluator.evaluate([-1, 51]).is_empty():
		failures.append("Duplicate or out-of-range cards must be rejected")
	if Evaluator.compare(_cards([8, 8, 13], [0, 1, 2]), _cards([8, 8, 14], [0, 1, 2])) != -1:
		failures.append("Lower kicker must lose")
	# Retain the original five-card scorer below as an independent oracle.
	var rng := RandomNumberGenerator.new()
	rng.seed = 20261024
	var deck: Array[int] = []
	for id in range(52):
		deck.append(id)
	for sample in range(2000):
		# A partial Fisher-Yates shuffle selects distinct cards uniformly.
		var hand: Array[int] = []
		for index in range(7):
			var other: int = rng.randi_range(index, 51)
			var temporary: int = deck[index]
			deck[index] = deck[other]
			deck[other] = temporary
			hand.append(deck[index])
		for size in range(2, 5):
			var partial: Array[int] = hand.slice(0, size)
			if Evaluator.evaluate(partial) != _original_five_score(partial):
				failures.append("Partial-hand score changed: %s" % [partial])
				return failures
		for size in range(5, 8):
			var cards: Array[int] = hand.slice(0, size)
			var expected: Array[int] = _exhaustive_score(cards)
			var actual: Array[int] = Evaluator.evaluate(cards)
			if actual != expected:
				failures.append("Oracle mismatch sample %d cards %s: got %s expected %s" % [sample, cards, actual, expected])
				return failures
	return failures

func _exhaustive_score(cards: Array[int]) -> Array[int]:
	var best: Array[int] = []
	for a in range(cards.size() - 4):
		for b in range(a + 1, cards.size() - 3):
			for c in range(b + 1, cards.size() - 2):
				for d in range(c + 1, cards.size() - 1):
					for e in range(d + 1, cards.size()):
						var subset: Array[int] = [cards[a], cards[b], cards[c], cards[d], cards[e]]
						var score: Array[int] = _original_five_score(subset)
						if best.is_empty() or _greater(score, best):
							best = score
	return best

func _greater(a: Array[int], b: Array[int]) -> bool:
	for index in range(6):
		if a[index] != b[index]:
			return a[index] > b[index]
	return false

# Frozen pre-optimization implementation: never call the production scorer here.
func _original_five_score(cards: Array[int]) -> Array[int]:
	var counts: Dictionary = {}
	var ranks: Array[int] = []
	var flush: bool = cards.size() == 5
	for id in cards:
		var value: int = Card.rank(id)
		counts[value] = int(counts.get(value, 0)) + 1
		ranks.append(value)
		if Card.suit(id) != Card.suit(cards[0]):
			flush = false
	ranks.sort()
	ranks.reverse()
	var straight: int = 0
	if cards.size() == 5 and counts.size() == 5:
		if ranks[0] - ranks[4] == 4:
			straight = ranks[0]
		elif ranks == [14, 5, 4, 3, 2]:
			straight = 5
	var quads: Array[int] = []
	var trips: Array[int] = []
	var pairs: Array[int] = []
	var singles: Array[int] = []
	for value in range(14, 1, -1):
		match int(counts.get(value, 0)):
			4: quads.append(value)
			3: trips.append(value)
			2: pairs.append(value)
			1: singles.append(value)
	var result: Array[int] = []
	if flush and straight > 0:
		result = [8, straight]
	elif not quads.is_empty():
		result = [7, quads[0]]
		result.append_array(singles)
	elif not trips.is_empty() and not pairs.is_empty():
		result = [6, trips[0], pairs[0]]
	elif flush:
		result = [5]
		result.append_array(ranks)
	elif straight > 0:
		result = [4, straight]
	elif not trips.is_empty():
		result = [3, trips[0]]
		result.append_array(singles)
	elif pairs.size() == 2:
		result = [2, pairs[0], pairs[1]]
		result.append_array(singles)
	elif pairs.size() == 1:
		result = [1, pairs[0]]
		result.append_array(singles)
	else:
		result = [0]
		result.append_array(ranks)
	while result.size() < 6:
		result.append(0)
	return result
