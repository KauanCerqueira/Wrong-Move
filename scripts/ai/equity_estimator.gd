class_name EquityEstimator
extends RefCounted

const Evaluator = preload("res://scripts/domain/hand_evaluator.gd")

## Uniform Monte Carlo from known cards only. Invalid input returns -1, not an
## estimate made from a partially valid hand. Exactly samples deals on success.
static func estimate(own: Array[int], board: Array[int], opponents: int, samples: int, rng: RandomNumberGenerator) -> float:
	if own.size() != 2 or board.size() > 5 or opponents < 0 or samples <= 0 or rng == null:
		return -1.0
	var seen: Dictionary = {}
	for card in own + board:
		if card < 0 or card >= 52 or seen.has(card):
			return -1.0
		seen[card] = true
	var available: Array[int] = []
	for card in range(52):
		if not seen.has(card):
			available.append(card)
	var needed := 5 - board.size() + 2 * opponents
	if needed > available.size():
		return -1.0
	if opponents == 0:
		return 1.0
	var total := 0.0
	var scores: Dictionary = {}
	for sample in range(samples):
		# Partial Fisher-Yates, reset each sample; no replacement within a deal.
		var pool: Array[int] = available.duplicate()
		for index in range(needed):
			var other := rng.randi_range(index, pool.size() - 1)
			var temporary := pool[index]
			pool[index] = pool[other]
			pool[other] = temporary
		var completed: Array[int] = board.duplicate()
		var missing := 5 - board.size()
		for index in range(missing):
			completed.append(pool[index])
		var hero: Array[int] = own.duplicate()
		hero.append_array(completed)
		var hero_score: Array[int] = _cached_score(hero, scores)
		var winners := 1
		var beaten := false
		for opponent in range(opponents):
			var offset := missing + 2 * opponent
			var hand: Array[int] = [pool[offset], pool[offset + 1]]
			hand.append_array(completed)
			var comparison := _compare_scores(hero_score, _cached_score(hand, scores))
			if comparison < 0:
				beaten = true
				# The entire deal was already sampled; early score comparison
				# never changes RNG consumption or the fixed sample count.
				break
			elif comparison == 0:
				winners += 1
		if not beaten:
			total += 1.0 / winners
	return total / samples

static func _cached_score(cards: Array[int], scores: Dictionary) -> Array[int]:
	var key: int = 0
	for card in cards:
		key |= 1 << card
	if not scores.has(key):
		scores[key] = Evaluator.evaluate(cards)
	return scores[key]

static func _compare_scores(first: Array[int], second: Array[int]) -> int:
	for index in range(6):
		if first[index] != second[index]:
			return 1 if first[index] > second[index] else -1
	return 0
