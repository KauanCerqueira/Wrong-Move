extends VBoxContainer
## Match screen: compact header, the felt, the player's strip and one panel that
## is either the bet controls or the hand summary.
signal command(kind: String, payload: Dictionary)
const ClubInk = preload("res://scripts/presentation/club_skin.gd")
const CardView = preload("res://scripts/presentation/card_view.gd")
const BetControls = preload("res://scripts/presentation/bet_controls.gd")
const Stage = preload("res://scripts/presentation/table_stage.gd")
const IconButton = preload("res://scripts/presentation/icon_button.gd")
const Avatar = preload("res://scripts/presentation/avatar_disc.gd")
const RANKS := ["2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K", "A"]
const SUITS := ["♣", "♦", "♥", "♠"]

var heading: Label
var meta: Label
var bots: Array[Button] = []
var board_cards: Array[Button] = []
var own: Array[Button] = []
var pot_label: Label
var stack_label: Label
var clock_label: Label
var hint: Button
var next_button: Button
var controls: VBoxContainer
var four_colors := false
var text_scale := 1.0
var reduced_motion := false
var _hint_price: Variant = 0
var _hint_eligible := false
var _stage: Control
var _panel: PanelContainer
var _summary: VBoxContainer
var _summary_title: Label
var _summary_cards: HBoxContainer
var _summary_rows: VBoxContainer
var _summary_message: Label
var _clock_row: HBoxContainer
var _reserve: ProgressBar
var _ready_built := false

func _ready() -> void:
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_theme_constant_override("separation", 6)
	_build_header()
	_stage = Stage.new()
	add_child(_stage)
	_stage.seat_selected.connect(func(body: String): command.emit("seat_details", {"body": body}))
	bots = _stage.bots
	board_cards = _stage.board_cards
	own = _stage.own_cards
	pot_label = _stage.pot_label
	_build_player_bar()
	_build_panel()
	_ready_built = true

func _build_header() -> void:
	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 8)
	add_child(header)
	var menu := IconButton.new()
	menu.kind = "menu"
	ClubInk.button(menu, "ghost", 16)
	menu.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	menu.tooltip_text = "Pausar torneio"
	header.add_child(menu)
	menu.pressed.connect(func(): command.emit("pause", {}))
	var center := VBoxContainer.new()
	center.add_theme_constant_override("separation", 0)
	center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(center)
	heading = ClubInk.label("Mesa 01", center, 18, ClubInk.PAPER, ClubInk.serif(600))
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	heading.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	meta = ClubInk.label("", center, 10, ClubInk.MUTED, ClubInk.sans(500, 1))
	meta.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var pause := IconButton.new()
	pause.kind = "pause"
	ClubInk.button(pause, "ghost", 16)
	pause.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	pause.tooltip_text = "Pausar torneio"
	header.add_child(pause)
	pause.pressed.connect(func(): command.emit("pause", {}))
	_clock_row = HBoxContainer.new()
	_clock_row.add_theme_constant_override("separation", 8)
	add_child(_clock_row)
	clock_label = ClubInk.label("", _clock_row, 11, ClubInk.COPPER, ClubInk.sans(600, 1))
	clock_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_reserve = ProgressBar.new()
	_reserve.custom_minimum_size = Vector2(96, 6)
	_reserve.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_reserve.show_percentage = false
	_reserve.max_value = 30000
	_reserve.add_theme_stylebox_override("background", ClubInk.box(ClubInk.INK, ClubInk.LINE, 3, 0))
	_reserve.add_theme_stylebox_override("fill", ClubInk.box(ClubInk.COPPER, ClubInk.COPPER, 3, 0))
	_clock_row.add_child(_reserve)
	_clock_row.visible = false

func _build_player_bar() -> void:
	var bar := HBoxContainer.new()
	bar.add_theme_constant_override("separation", 8)
	add_child(bar)
	var shield := IconButton.new()
	shield.kind = "shield"
	ClubInk.button(shield, "ghost", 16)
	shield.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	shield.tooltip_text = "Regras e ranking"
	bar.add_child(shield)
	shield.pressed.connect(func(): command.emit("rules", {}))
	var avatar := Avatar.new()
	avatar.glyph = "V"
	avatar.custom_minimum_size = Vector2(32, 32)
	avatar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	bar.add_child(avatar)
	var info := VBoxContainer.new()
	info.add_theme_constant_override("separation", 0)
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	bar.add_child(info)
	ClubInk.label("Você", info, 10, ClubInk.MUTED, ClubInk.sans(600, 1))
	stack_label = ClubInk.label("0", info, 16, ClubInk.PAPER, ClubInk.serif(700))
	hint = IconButton.new()
	hint.kind = "star"
	ClubInk.button(hint, "ghost", 16)
	hint.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	hint.tooltip_text = "Dica paga"
	bar.add_child(hint)
	hint.pressed.connect(func(): command.emit("confirm_hint", {"price": _hint_price}))

func _build_panel() -> void:
	_panel = PanelContainer.new()
	_panel.add_theme_stylebox_override("panel", ClubInk.plaque(Color("0e241d"), Color("234036"), 14, 12))
	add_child(_panel)
	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation", 8)
	_panel.add_child(stack)
	controls = BetControls.new()
	stack.add_child(controls)
	controls.action.connect(func(kind: String, raise_to: int): command.emit("action", {"kind": kind, "raise_to": raise_to}))
	_summary = VBoxContainer.new()
	_summary.add_theme_constant_override("separation", 6)
	_summary.visible = false
	stack.add_child(_summary)
	var head := HBoxContainer.new()
	head.add_theme_constant_override("separation", 8)
	_summary.add_child(head)
	_summary_title = ClubInk.label("", head, 20, ClubInk.PAPER, ClubInk.serif(700))
	_summary_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_summary_message = ClubInk.label("", head, 10, ClubInk.MUTED, ClubInk.sans(500, 1))
	_summary_message.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_summary_message.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_summary_cards = HBoxContainer.new()
	_summary_cards.add_theme_constant_override("separation", 3)
	_summary.add_child(_summary_cards)
	_summary_rows = VBoxContainer.new()
	_summary_rows.add_theme_constant_override("separation", 2)
	_summary.add_child(_summary_rows)
	next_button = Button.new()
	ClubInk.button(next_button, "primary", 16)
	next_button.text = "Próxima mão  →"
	next_button.custom_minimum_size.y = 48
	_summary.add_child(next_button)
	next_button.pressed.connect(func(): command.emit("next_hand", {}))

func render(view: Dictionary) -> void:
	if not _ready_built:
		_ready()
	var tutorial: bool = view.get("mode", "normal") == "tutorial"
	var hardcore: bool = view.get("mode", "normal") == "hardcore"
	heading.text = "Treino guiado" if tutorial else "Mesa " + str(view.get("table_index", "1")).pad_zeros(2)
	heading.add_theme_font_size_override("font_size", int(18 * text_scale))
	var blinds := "Blinds %s/%s" % [view.get("small_blind", 0), view.get("big_blind", 0)]
	meta.text = "%s  ·  Mão %s" % [blinds, view.get("hand_number", 1)]
	meta.add_theme_font_size_override("font_size", int(10 * text_scale))
	_stage.render(view, four_colors, text_scale, reduced_motion)
	var active := str(view.get("actor", -1)) == "0"
	var result: Variant = view.get("result")
	var has_result := result != null
	if result is Dictionary or result is Array or result is String:
		has_result = not result.is_empty()
	stack_label.text = str(view.get("player_stack", 0)) + ("  ·  D" if str(view.get("button", -1)) == "0" else "")
	stack_label.add_theme_font_size_override("font_size", int(16 * text_scale))
	_hint_price = view.get("hint_price", 0)
	hint.badge = str(_hint_price) if int(_hint_price) > 0 else ""
	hint.tooltip_text = "Dica por %s fichas" % _hint_price
	_hint_eligible = view.get("mode", "normal") == "normal" and active and not has_result
	update_hint_available(bool(view.get("hint_available", false)))
	controls.visible = not has_result
	_summary.visible = has_result
	if has_result:
		_render_summary(view, result)
		_summary_title.add_theme_font_size_override("font_size", int(20 * text_scale))
		_summary_message.add_theme_font_size_override("font_size", int(10 * text_scale))
		next_button.add_theme_font_size_override("font_size", int(16 * text_scale))
	else:
		controls.text_scale = text_scale
		controls.reduced_motion = reduced_motion
		controls.configure(view.get("legal_actions", {}), int(view.get("pot", 0)), active)
		var legal: Dictionary = view.get("legal_actions", {})
		if not legal.get("check_allowed", false) and int(legal.get("to_call", 0)) >= int(view.get("player_stack", 0)) and int(view.get("player_stack", 0)) > 0:
			controls.mark_call_all_in()
	_clock_row.visible = hardcore
	update_clock(view.get("clock", {}))

func _render_summary(view: Dictionary, result: Variant) -> void:
	var combination := str(view.get("current_combination", ""))
	_summary_title.text = combination if not combination.is_empty() else "Mão encerrada"
	var message := ""
	if result is Dictionary:
		message = str(result.get("summary", result.get("message", "")))
	elif result != null:
		message = str(result)
	_summary_message.text = message
	for child: Node in _summary_cards.get_children():
		_summary_cards.remove_child(child)
		child.queue_free()
	var cards: Array = []
	for value: Variant in view.get("own_cards", []):
		cards.append(int(value))
	for value: Variant in view.get("board", []):
		cards.append(int(value))
	for value: int in cards:
		if value < 0 or value > 51:
			continue
		var suit := int(value / 13)
		var ink := Color("b8353c") if suit in [1, 2] else ClubInk.PAPER
		if four_colors and suit == 0:
			ink = Color("5f9a72")
		elif four_colors and suit == 1:
			ink = Color("6f9ed0")
		var token := ClubInk.label(RANKS[value % 13] + SUITS[suit], _summary_cards, int(14 * text_scale), ink, ClubInk.serif(600))
		token.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	for child: Node in _summary_rows.get_children():
		_summary_rows.remove_child(child)
		child.queue_free()
	var rows := [["Pote", str(view.get("pot", 0))], ["Suas fichas", str(view.get("player_stack", 0))]]
	for row: Array in rows:
		var line := HBoxContainer.new()
		_summary_rows.add_child(line)
		var caption := ClubInk.label(str(row[0]), line, int(11 * text_scale), ClubInk.MUTED)
		caption.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		ClubInk.label(str(row[1]), line, int(13 * text_scale), ClubInk.PAPER, ClubInk.serif(600))

func update_clock(value: Dictionary) -> void:
	var seconds := maxf(0, float(value.get("decision_remaining_ms", 0))) / 1000.0
	var reserve := maxf(0, float(value.get("reserve_remaining_ms", 0))) / 1000.0
	clock_label.text = "%.1f s  ·  reserva %.1f s" % [seconds, reserve]
	clock_label.add_theme_color_override("font_color", ClubInk.PAPER if seconds > 3 else Color("ffb59f"))
	_reserve.value = float(value.get("reserve_remaining_ms", 0))
	_reserve.tooltip_text = "Reserva do torneio: %.1f segundos" % reserve

func update_hint_available(available: bool) -> void:
	hint.visible = available and _hint_eligible
	hint.disabled = not hint.visible
