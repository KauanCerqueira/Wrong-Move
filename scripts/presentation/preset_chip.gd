extends Button
## Bet preset chip: percentage on top, resulting total below, copper seal when
## the slider lands on it.
const ClubInk = preload("res://scripts/presentation/club_skin.gd")
var caption := ""
var value_text := ""
var selected := false

func _init() -> void:
	custom_minimum_size = Vector2(52, 46)
	focus_mode = Control.FOCUS_ALL
	mouse_entered.connect(queue_redraw)
	mouse_exited.connect(queue_redraw)
	focus_entered.connect(queue_redraw)
	focus_exited.connect(queue_redraw)
	resized.connect(queue_redraw)

func set_values(new_caption: String, new_value: String) -> void:
	if caption == new_caption and value_text == new_value:
		return
	caption = new_caption
	value_text = new_value
	queue_redraw()

func set_selected(active: bool) -> void:
	if selected == active:
		return
	selected = active
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
	if selected:
		var ring := ClubInk.box(Color(0, 0, 0, 0), ClubInk.BRASS, 7, 0)
		ring.set_border_width_all(1)
		draw_style_box(ring, Rect2(Vector2.ZERO, size))
	if has_focus():
		var focus := ClubInk.box(Color(0, 0, 0, 0), ClubInk.PAPER, 8, 0)
		focus.set_border_width_all(2)
		draw_style_box(focus, Rect2(Vector2.ZERO, size))
	var caption_color := ClubInk.BRASS if selected else Color(ClubInk.MUTED, 0.85)
	if disabled:
		caption_color = Color(ClubInk.MUTED, 0.4)
	var value_color := ClubInk.PAPER if not disabled else Color(ClubInk.MUTED, 0.45)
	var caption_size := 9
	var value_size := 13
	var caption_font := ClubInk.sans(600, 1)
	var value_font := ClubInk.serif(600)
	var caption_width := caption_font.get_string_size(caption, HORIZONTAL_ALIGNMENT_LEFT, -1, caption_size).x
	var value_width := value_font.get_string_size(value_text, HORIZONTAL_ALIGNMENT_LEFT, -1, value_size).x
	draw_string(caption_font, Vector2((size.x - caption_width) * 0.5, size.y * 0.42), caption, HORIZONTAL_ALIGNMENT_LEFT, -1, caption_size, caption_color)
	draw_string(value_font, Vector2((size.x - value_width) * 0.5, size.y * 0.78), value_text, HORIZONTAL_ALIGNMENT_LEFT, -1, value_size, value_color)
