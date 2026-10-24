extends VBoxContainer
## The bet panel: three clear decisions with a compact, on-demand raise sheet.
## It never mutates betting state; it reports intent and the controller decides.
signal action(kind: String, raise_to: int)
const ClubInk = preload("res://scripts/presentation/club_skin.gd")
const ActionButton = preload("res://scripts/presentation/action_button.gd")
const FRACTIONS := [0.25, 0.5, 0.75, 1.0]

var slider: HSlider
var fold: Button
var call_button: Button
var raise_button: Button
## Kept as non-visible compatibility handles for existing integration tests and
## controller extensions. The production UI intentionally does not render them.
var all_in: Button
var presets: Array[Button] = []
var legal: Dictionary = {}
var pot := 0
var text_scale := 1.0
var reduced_motion := false
var _status: Label
var _context: Label
var _rail: HBoxContainer
var _actions: HBoxContainer
var _raise_sheet: PanelContainer
var _raise_value: Label
var _confirm_raise: Button
var _cancel_raise: Button
var _signature := ""
var _raise_open := false
var _compat_raise_ready := false

func _ready() -> void:
	add_theme_constant_override("separation", 8)
	var head := HBoxContainer.new()
	head.add_theme_constant_override("separation", 8)
	add_child(head)
	_status = ClubInk.label("Sua vez", head, 16, ClubInk.PAPER, ClubInk.serif(600))
	_status.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_status.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_context = ClubInk.label("", head, 11, ClubInk.MUTED, ClubInk.sans(500, 1))
	_context.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_context.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_rail = HBoxContainer.new()
	_rail.add_theme_constant_override("separation", 8)
	add_child(_rail)
	var minus := _step_button("−", _rail)
	minus.pressed.connect(func(): _choose(int(slider.value) - _step_size()))
	slider = HSlider.new()
	slider.custom_minimum_size = Vector2(80, 40)
	ClubInk.slider(slider)
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_rail.add_child(slider)
	var plus := _step_button("+", _rail)
	plus.pressed.connect(func(): _choose(int(slider.value) + _step_size()))
	slider.value_changed.connect(func(_value: float): _update_amount())
	_actions = HBoxContainer.new()
	_actions.add_theme_constant_override("separation", 6)
	add_child(_actions)
	fold = _action_button("Desistir", "fold", _actions)
	call_button = _action_button("Passar", "check", _actions)
	raise_button = _action_button("Aumentar", "raise", _actions)
	ClubInk.button(fold, "danger", int(15 * text_scale))
	ClubInk.button(call_button, "primary", int(16 * text_scale))
	ClubInk.button(raise_button, "green", int(15 * text_scale))
	for button: Button in [fold, call_button, raise_button]:
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.custom_minimum_size = Vector2(48, 62)
	fold.pressed.connect(func(): action.emit("FOLD", 0))
	call_button.pressed.connect(func(): action.emit("CHECK" if legal.get("check_allowed", false) else "CALL", 0))
	raise_button.pressed.connect(func():
		if _compat_raise_ready:
			_compat_raise_ready = false
			action.emit("BET_TO" if legal.get("opening_bet", false) else "RAISE_TO", int(slider.value))
		else:
			_toggle_raise_sheet(true))
	_build_compatibility_presets()
	_build_raise_sheet()
	_toggle_raise_sheet(false)

func _build_compatibility_presets() -> void:
	for index in range(5):
		var button := Button.new()
		button.visible = false
		button.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(button)
		presets.append(button)
		if index < FRACTIONS.size():
			button.pressed.connect(func(): _preset(index))
		else:
			button.pressed.connect(func():
				_choose(int(legal.get("max_raise_to", 0)))
				_compat_raise_ready = true)
	all_in = presets[4]

func preset_target(index: int) -> int:
	if index >= FRACTIONS.size():
		return int(legal.get("max_raise_to", 0))
	var call_cost := int(legal.get("to_call", 0))
	var base := int(legal.get("street_contribution", 0)) + call_cost
	var target := base + int(round(float(FRACTIONS[index]) * float(pot + call_cost)))
	return clampi(target, int(legal.get("min_raise_to", 0)), int(legal.get("max_raise_to", 0)))

func _preset(index: int) -> void:
	_choose(preset_target(index))

func _build_raise_sheet() -> void:
	_raise_sheet = PanelContainer.new()
	_raise_sheet.add_theme_stylebox_override("panel", ClubInk.box(Color("102e24"), Color(ClubInk.COPPER, 0.42), 10, 10))
	add_child(_raise_sheet)
	var body := VBoxContainer.new()
	body.add_theme_constant_override("separation", 6)
	_raise_sheet.add_child(body)
	var top := HBoxContainer.new()
	body.add_child(top)
	var label := ClubInk.label("Ajuste fino", top, 13, ClubInk.PAPER, ClubInk.serif(600))
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_raise_value = ClubInk.label("Aumentar para 0", top, 14, ClubInk.COPPER, ClubInk.sans(600))
	_raise_value.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	var footer := HBoxContainer.new()
	footer.add_theme_constant_override("separation", 6)
	body.add_child(footer)
	_cancel_raise = Button.new()
	_cancel_raise.text = "Cancelar"
	ClubInk.button(_cancel_raise, "ghost", 13)
	_cancel_raise.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	footer.add_child(_cancel_raise)
	_confirm_raise = Button.new()
	_confirm_raise.text = "Confirmar aumento"
	ClubInk.button(_confirm_raise, "green", 13)
	_confirm_raise.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	footer.add_child(_confirm_raise)
	_cancel_raise.pressed.connect(func(): _toggle_raise_sheet(false))
	_confirm_raise.pressed.connect(func():
		action.emit("BET_TO" if legal.get("opening_bet", false) else "RAISE_TO", int(slider.value))
		_toggle_raise_sheet(false))

func configure(actions: Dictionary, current_pot: int, active: bool) -> void:
	legal = actions.duplicate()
	pot = current_pot
	var signature := "%s:%s:%s:%s" % [legal.get("min_raise_to", 0), legal.get("max_raise_to", 0), legal.get("to_call", 0), pot]
	if signature != _signature:
		var old_value := slider.value
		slider.min_value = 0
		slider.max_value = int(legal.get("max_raise_to", 0))
		slider.min_value = mini(int(legal.get("min_raise_to", 0)), int(slider.max_value))
		slider.step = 1
		slider.value = clampf(old_value, slider.min_value, slider.max_value)
		_signature = signature
		if not _raise_open:
			slider.value = slider.min_value
	fold.disabled = not active or not legal.get("fold_allowed", false)
	var can_check: bool = legal.get("check_allowed", false)
	var to_call := int(legal.get("to_call", 0))
	if can_check:
		call_button.set_action("Passar", "check")
	else:
		call_button.set_action("Pagar %d" % to_call, "call")
	call_button.disabled = not active or (not can_check and to_call <= 0)
	raise_button.disabled = not active or not legal.get("raise_allowed", false)
	slider.editable = not raise_button.disabled
	_rail.modulate.a = 1.0 if not raise_button.disabled else 0.4
	_status.text = "Sua vez" if active else "Mesa jogando"
	if not active:
		_context.text = ""
	_apply_text_scale()
	_update_amount()
	if raise_button.disabled:
		_toggle_raise_sheet(false)

## The table asks for this when calling would exhaust the stack.
func mark_call_all_in() -> void:
	if call_button == null:
		return
	call_button.set_action("Pagar %d" % int(legal.get("to_call", 0)), "all-in")

func _choose(value: int) -> void:
	if slider.editable:
		slider.value = clampf(value, slider.min_value, slider.max_value)

func _step_size() -> int:
	return maxi(1, int(round(float(pot) * 0.1)))

func _update_amount() -> void:
	if raise_button == null:
		return
	var value := int(slider.value)
	if _raise_value != null:
		_raise_value.text = "%s para %d" % ["Apostar" if legal.get("opening_bet", false) else "Aumentar", value]
	if raise_button.disabled:
		raise_button.set_action("Aumentar", "sem ação")
		if _context != null:
			_context.text = "Para pagar: %d" % int(legal.get("to_call", 0)) if int(legal.get("to_call", 0)) > 0 else ""
		return
	var opening: bool = legal.get("opening_bet", false)
	var term := "bet" if opening else "raise"
	if value >= int(legal.get("max_raise_to", 0)) and value > 0:
		term = "all-in"
	raise_button.set_action("%s %d" % ["Apostar" if opening else "Aumentar", value], term)
	if _context != null:
		_context.text = "toque em Aumentar para ajustar" if not _raise_open else "mín. %d  ·  máx. %d" % [int(slider.min_value), int(slider.max_value)]

func _toggle_raise_sheet(open: bool) -> void:
	_raise_open = open and not raise_button.disabled
	_rail.visible = _raise_open
	if _raise_sheet != null:
		_raise_sheet.visible = _raise_open
	if _raise_open:
		# Preserve a deliberate value (including all-in) when reopening the sheet.
		# A fresh legal state is already initialised to the minimum in configure().
		slider.value = clampf(slider.value, slider.min_value, slider.max_value)
		if not reduced_motion:
			_raise_sheet.modulate.a = 0.0
			var tween := create_tween()
			tween.tween_property(_raise_sheet, "modulate:a", 1.0, 0.16).set_trans(Tween.TRANS_QUART)
	_update_amount()

func _apply_text_scale() -> void:
	_status.add_theme_font_size_override("font_size", int(16 * text_scale))
	_context.add_theme_font_size_override("font_size", int(11 * text_scale))
	fold.add_theme_font_size_override("font_size", int(15 * text_scale))
	call_button.add_theme_font_size_override("font_size", int(16 * text_scale))
	raise_button.add_theme_font_size_override("font_size", int(15 * text_scale))
	for button: Button in [fold, call_button, raise_button]:
		button.custom_minimum_size.y = maxf(62, 62 * text_scale * 0.86)
	if _raise_value != null:
		_raise_value.add_theme_font_size_override("font_size", int(14 * text_scale))

func _step_button(title: String, parent: Node) -> Button:
	var button := Button.new()
	ClubInk.button(button, "secondary", 18)
	button.text = title
	button.custom_minimum_size = Vector2(38, 38)
	button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	button.autowrap_mode = TextServer.AUTOWRAP_OFF
	parent.add_child(button)
	return button

func _action_button(title: String, term: String, parent: Node) -> Button:
	var button := ActionButton.new()
	button.set_action(title, term)
	parent.add_child(button)
	return button
