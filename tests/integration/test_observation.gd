extends RefCounted

const Basic = preload("res://scripts/ai/basic_agent.gd")
const Hint = preload("res://scripts/ai/hint_advisor.gd")
const Estimator = preload("res://scripts/ai/equity_estimator.gd")

func run() -> Array[String]:
	var failures: Array[String] = []
	var observation := fixture()
	var before := observation.duplicate(true)
	var changed := observation.duplicate(true)
	changed["deck"] = [51, 50, 49]
	changed["seed"] = 9999
	changed["opponent_cards"] = [[1, 2]]
	changed["save"] = {"private_future": [20, 21]}
	changed.seats[1]["cards"] = [3, 4]
	var first := _rng(123)
	var second := _rng(123)
	var action := Basic.choose_action(observation, first)
	if action != Basic.choose_action(changed, second) or first.state != second.state:
		failures.append("Hidden data must not change action or RNG consumption")
	if observation != before:
		failures.append("AI must not mutate observation")
	var hint := Hint.recommend(observation)
	if hint != Hint.recommend(changed) or hint != Hint.recommend(observation):
		failures.append("Hints must be deterministic and isolated from hidden information")
	if hint.has("equity") or not hint.explanation.ends_with("É uma estimativa, não uma garantia."):
		failures.append("Hint must explain uncertainty without exposing numeric equity")
	var own: Array[int] = [0, 1]
	var royal: Array[int] = [8, 9, 10, 11, 12]
	if not is_equal_approx(Estimator.estimate(own, royal, 3, 8, _rng(4)), 0.25):
		failures.append("Board royal flush must split equity among all four players")
	var invalid: Array[int] = [0, 0]
	if Estimator.estimate(invalid, royal, 1, 8, _rng(4)) != -1.0:
		failures.append("Estimator must reject duplicate known cards")
	var nuts: Array[int] = [11, 12]
	var nut_board: Array[int] = [8, 9, 10, 26, 40]
	if Estimator.estimate(nuts, nut_board, 5, 8, _rng(4)) != 1.0:
		failures.append("Own royal flush must win every sample against five opponents")
	if Estimator.estimate(own, royal, 1, 0, _rng(4)) != -1.0 or Estimator.estimate(own, royal, 23, 8, _rng(4)) != -1.0:
		failures.append("Invalid sampling counts and impossible opponent counts must be rejected")
	var board: Array[int] = [2, 16, 30]
	var a := _rng(52)
	var b := _rng(52)
	if Estimator.estimate(own, board, 2, 8, a) != Estimator.estimate(own, board, 2, 8, b) or a.state != b.state:
		failures.append("Equity samples must reproduce exactly with fixed seeds")
	return failures

static func fixture() -> Dictionary:
	return {"own_cards": [12, 25], "public_board": [0, 14, 28, 42, 7], "public_pot": 100, "public_stacks": [900, 900], "seats": [{"id": 0, "stack": 900, "folded": false, "all_in": false}, {"id": 1, "stack": 900, "folded": false, "all_in": false}], "actor": 0, "button": 1, "phase": "river", "public_current_bet": 20, "legal_actions": {"check_allowed": false, "fold_allowed": true, "call_allowed": true, "raise_allowed": true, "all_in_allowed": true, "to_call": 20, "min_raise_to": 40, "max_raise_to": 900}}

static func _rng(seed_value: int) -> RandomNumberGenerator:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	return rng
