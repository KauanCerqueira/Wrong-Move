extends Button
## Two-line decision button: the action in player language, the poker term below.
## Text is drawn here so a long value can never break the row into three lines.
const ClubInk = preload("res://scripts/presentation/club_skin.gd")
var title_text := ""
var term_text := ""
var align_left := true

func _init() -> void:
	text = ""
	clip_text = true
	focus_mode = Control.FOCUS_ALL
	mouse_entered.connect(queue_redraw)
	mouse_exited.connect(queue_redraw)
	button_down.connect(queue_redraw)
	button_up.connect(queue_redraw)
	focus_entered.connect(queue_redraw)
	focus_exited.connect(queue_redraw)
	resized.connect(queue_redraw)

func set_action(title: String, term: String) -> void:
	if title_text == title and term_text == term:
		return
	title_text = title
	term_text = term
	queue_redraw()

func _state_name() -> String:
	if disabled:
		return "disabled"
	if is_hovered():
		return "hover"
	return "normal"

func _draw() -> void:
	var style := get_theme_stylebox(_state_name())
	if style != null:
		draw_style_box(style, Rect2(Vector2.ZERO, size))
	if has_focus():
		var focus := get_theme_stylebox("focus")
		if focus != null:
			draw_style_box(focus, Rect2(Vector2.ZERO, size))
	var title_color := get_theme_color("font_color")
	if disabled:
		title_color = get_theme_color("font_disabled_color")
	var title_size := get_theme_font_size("font_size")
	var title_font := get_theme_font("font")
	var term_size := maxi(11, int(title_size * 0.68))
	var term_font := ClubInk.sans(600, 2)
	var available := size.x - 12
	var title_width := title_font.get_string_size(title_text, HORIZONTAL_ALIGNMENT_LEFT, -1, title_size).x
	while title_width > available and title_size > 10:
		title_size -= 1
		title_width = title_font.get_string_size(title_text, HORIZONTAL_ALIGNMENT_LEFT, -1, title_size).x
	if title_width > available:
		title_text = _ellipsize(title_font, title_text, title_size, available)
		title_width = title_font.get_string_size(title_text, HORIZONTAL_ALIGNMENT_LEFT, -1, title_size).x
	var term_width := term_font.get_string_size(term_text, HORIZONTAL_ALIGNMENT_LEFT, -1, term_size).x
	var center_x := size.x * 0.5
	var title_baseline := size.y * 0.5 - 1
	draw_string(title_font, Vector2(center_x - title_width * 0.5, title_baseline), title_text, HORIZONTAL_ALIGNMENT_LEFT, -1, title_size, title_color)
	if not term_text.is_empty():
		var term_color := Color(get_theme_color("font_color"), 0.72)
		if disabled:
			term_color = Color(get_theme_color("font_disabled_color"), 0.85)
		if term_width > available:
			term_size = maxi(9, term_size - 2)
			term_width = term_font.get_string_size(term_text, HORIZONTAL_ALIGNMENT_LEFT, -1, term_size).x
		draw_string(term_font, Vector2(center_x - term_width * 0.5, title_baseline + term_size + 5), term_text, HORIZONTAL_ALIGNMENT_LEFT, -1, term_size, term_color)

func _ellipsize(font: Font, value: String, font_size: int, width: float) -> String:
	var trimmed := value
	while trimmed.length() > 1 and font.get_string_size(trimmed + "…", HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x > width:
		trimmed = trimmed.left(trimmed.length() - 1)
	return trimmed + "…"
