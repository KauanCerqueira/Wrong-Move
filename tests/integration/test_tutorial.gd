extends RefCounted
const Tutorial = preload("res://scripts/application/tutorial_controller.gd")

func run() -> Array[String]:
	var errors: Array[String] = []
	for lesson in range(5):
		var tutorial := Tutorial.new()
		tutorial.start(lesson)
		if tutorial.act("FOLD").ok:
			errors.append("wrong action passed lesson " + str(lesson))
		var result: Dictionary
		match lesson:
			1:
				tutorial.act("CHECK")
				if tutorial.player_view().legal_actions.to_call != 20:
					errors.append("call amount not taught")
				result = tutorial.act("CALL")
			2: result = tutorial.act("RAISE_TO", 60)
			4: result = tutorial.act("CALL")
			_: result = tutorial.act("CHECK")
		if not result.ok or not tutorial.finished:
			errors.append("lesson cannot complete " + str(lesson))
		if tutorial.player_view().result == null:
			errors.append("missing lesson result")
	return errors
