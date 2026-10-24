class_name BasicAgent
extends RefCounted

const Estimator = preload("res://scripts/ai/equity_estimator.gd")
const SAMPLES: Array[int] = [64, 96, 128, 192, 256, 384, 512, 768, 1024]
const NOISE: Array[float] = [0.20, 0.18, 0.16, 0.14, 0.12, 0.10, 0.08, 0.06, 0.04]

static func choose_action(observation: Dictionary, rng: RandomNumberGenerator, strength: int = 0, style: String = "equilibrado") -> Dictionary:
	return choose_policy(observation, rng, strength, style, true)

## Shared policy permits hints to disable both noise and random bluffing.
## No references to deck, opponent cards, save state or wall-clock time.
static func choose_policy(observation: Dictionary, rng: RandomNumberGenerator, strength: int, style: String, randomize_decision: bool) -> Dictionary:
	if rng == null:
		return {"kind": "BOT_INVALID_OBSERVATION"}
	var legal: Dictionary = observation.get("legal_actions", {})
	var fallback := _passive(legal)
	if fallback.kind == "BOT_NO_LEGAL_ACTION":
		return fallback
	var own: Array[int] = []
	var board: Array[int] = []
	for card in observation.get("own_cards", []):
		own.append(int(card))
	for card in observation.get("public_board", []):
		board.append(int(card))
	var opponents := _opponents(observation)
	var level := clampi(strength, 0, 8)
	# One seed draw separates sampling from policy draws and deck randomness.
	var equity_rng := RandomNumberGenerator.new()
	equity_rng.seed = rng.randi()
	var equity := Estimator.estimate(own, board, opponents, SAMPLES[level], equity_rng)
	if equity < 0.0:
		return {"kind": "BOT_INVALID_OBSERVATION"}
	var margin := 0.0
	var tolerance := 0.02
	var bluff_rate := 0.05
	if style == "cauteloso":
		margin = -0.05
		tolerance = 0.04
		bluff_rate = 0.02
	elif style == "agressivo":
		margin = 0.05
		tolerance = 0.0
		bluff_rate = 0.10
	equity = clampf(equity + margin, 0.0, 1.0)
	if randomize_decision:
		equity += rng.randf_range(-NOISE[level], NOISE[level])
	var pot := maxi(0, int(observation.get("public_pot", 0)))
	var call := maxi(0, int(legal.get("to_call", 0)))
	if not legal.get("check_allowed", false) and call > 0:
		var price := float(call) / (pot + call)
		if equity < price + tolerance and legal.get("fold_allowed", false):
			return {"kind": "FOLD"}
	var candidates := raise_candidates(observation)
	if candidates.is_empty():
		return fallback
	var threshold := 1.0 / (opponents + 1) + 0.15
	var excess := equity - threshold
	if excess > 0.0:
		var target := _target(observation, 0.5 if excess < 0.10 else 1.0)
		if excess >= 0.25:
			target = int(legal.get("max_raise_to", 0))
		return _closest(candidates, target)
	# Only public, explicitly supplied fold opportunities can justify a bluff.
	var stats: Dictionary = observation.get("public_fold_stats", {})
	var opportunities := maxi(0, int(stats.get("opportunities", 0)))
	var folds := clampi(int(stats.get("folds", 0)), 0, opportunities)
	var can_fold := _opponent_can_fold(observation)
	if level >= 3 and opportunities >= 20:
		bluff_rate *= clampf(0.5 + float(folds) / opportunities, 0.5, 1.5)
	if randomize_decision and can_fold and rng.randf() < bluff_rate / maxi(1, opponents):
		return _closest(candidates, _target(observation, 0.5))
	return fallback

static func _passive(legal: Dictionary) -> Dictionary:
	if legal.get("check_allowed", false):
		return {"kind": "CHECK"}
	if legal.get("call_allowed", int(legal.get("to_call", 0)) > 0):
		return {"kind": "CALL"}
	if legal.get("fold_allowed", false):
		return {"kind": "FOLD"}
	if legal.get("all_in_allowed", false):
		return {"kind": "ALL_IN"}
	return {"kind": "BOT_NO_LEGAL_ACTION"}

static func _opponents(observation: Dictionary) -> int:
	var seats: Array = observation.get("seats", observation.get("public_seats", []))
	if not seats.is_empty():
		var count := 0
		for seat in seats:
			if int(seat.get("id", -1)) != int(observation.get("actor", -1)) and not seat.get("folded", false):
				count += 1
		return count
	return maxi(0, observation.get("public_stacks", [0, 0]).size() - 1)

static func _opponent_can_fold(observation: Dictionary) -> bool:
	for seat in observation.get("seats", observation.get("public_seats", [])):
		if int(seat.get("id", -1)) != int(observation.get("actor", -1)) and not seat.get("folded", false) and not seat.get("all_in", false) and int(seat.get("stack", 0)) > 0:
			return true
	return false

static func _current_bet(observation: Dictionary) -> int:
	if observation.has("public_current_bet") or observation.has("current_bet"):
		return maxi(0, int(observation.get("public_current_bet", observation.get("current_bet", 0))))
	var legal: Dictionary = observation.get("legal_actions", {})
	var actor := int(observation.get("actor", -1))
	var stack := -1
	for seat in observation.get("seats", observation.get("public_seats", [])):
		if int(seat.get("id", -1)) == actor:
			stack = int(seat.get("stack", -1))
	var stacks: Array = observation.get("public_stacks", [])
	if stack < 0 and actor >= 0 and actor < stacks.size():
		stack = int(stacks[actor])
	# max_raise_to is own street contribution + remaining stack. For a seat
	# allowed to raise, to_call is not capped, so this recovers current bet.
	if stack >= 0:
		return maxi(0, int(legal.get("max_raise_to", stack)) - stack + int(legal.get("to_call", 0)))
	return maxi(0, int(legal.get("to_call", 0)))

static func _target(observation: Dictionary, fraction: float) -> int:
	var legal: Dictionary = observation.get("legal_actions", {})
	return _current_bet(observation) + int(ceil(fraction * (maxi(0, int(observation.get("public_pot", 0))) + maxi(0, int(legal.get("to_call", 0))))))

## At most four deduplicated legal targets. A short shove uses ALL_IN even
## when a full raise is unavailable; the caller's legal mask is authoritative.
static func raise_candidates(observation: Dictionary) -> Array[Dictionary]:
	var legal: Dictionary = observation.get("legal_actions", {})
	var result: Array[Dictionary] = []
	var maximum := int(legal.get("max_raise_to", 0))
	var minimum := int(legal.get("min_raise_to", 0))
	var current := _current_bet(observation)
	var seen: Dictionary = {}
	if legal.get("raise_allowed", false) and maximum >= minimum and maximum > current:
		for raw_target in [minimum, _target(observation, 0.5), _target(observation, 1.0), maximum]:
			var target := clampi(int(raw_target), minimum, maximum)
			if target <= current or seen.has(target):
				continue
			seen[target] = true
			if target == maximum and legal.get("all_in_allowed", false):
				result.append({"kind": "ALL_IN", "raise_to": target})
			else:
				result.append({"kind": "RAISE_TO" if current > 0 else "BET_TO", "raise_to": target})
	if legal.get("all_in_allowed", false) and maximum > current and not seen.has(maximum):
		result.append({"kind": "ALL_IN", "raise_to": maximum})
	return result

static func _closest(candidates: Array[Dictionary], target: int) -> Dictionary:
	var best: Dictionary = candidates[0]
	for candidate in candidates:
		var distance := absi(int(candidate.raise_to) - target)
		var best_distance := absi(int(best.raise_to) - target)
		if distance < best_distance or (distance == best_distance and int(candidate.raise_to) < int(best.raise_to)):
			best = candidate
	return best.duplicate()
