extends RefCounted
const Controls = preload("res://scripts/presentation/bet_controls.gd")

func run() -> Array[String]:
	var errors: Array[String] = []
	var controls := Controls.new()
	controls._ready()
	var commands: Array = []
	controls.action.connect(func(kind: String, amount: int): commands.append({"kind": kind, "amount": amount}))
	var legal := {"check_allowed": true, "fold_allowed": false, "raise_allowed": true, "all_in_allowed": true, "to_call": 0,
		"min_raise_to": 40, "max_raise_to": 1000, "street_contribution": 20, "opening_bet": false}
	controls.configure(legal, 40, true)
	controls.all_in.pressed.emit()
	if not commands.is_empty() or controls.slider.value != 1000:
		errors.append("all-in preset executed without confirmation")
	controls.raise_button.pressed.emit()
	if commands.size() != 1 or commands[0].kind != "RAISE_TO" or commands[0].amount != 1000:
		errors.append("BB check option must still emit a raise, not bet")
	legal.to_call = 20
	legal.street_contribution = 10
	legal.check_allowed = false
	controls.configure(legal, 100, true)
	controls.presets[0].pressed.emit()
	if int(controls.slider.value) != 60:
		errors.append("25% preset must include prior contribution and call")
	if controls.preset_target(1) != 90:
		errors.append("50% preset must scale with the pot after calling")
	legal.max_raise_to = 35
	controls.configure(legal, 100, true)
	if int(controls.slider.value) != 35 or controls.slider.max_value != 35:
		errors.append("short all-in cannot exceed available stack")
	controls.free()
	return errors
