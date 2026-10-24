extends Button
## Small square button whose glyph is drawn, not a font character, so it renders
## identically on every device.
const ClubInk = preload("res://scripts/presentation/club_skin.gd")
var kind := "menu"
var badge := ""
var drawn_size := 16.0

func _init() -> void:
	custom_minimum_size = Vector2(40, 40)
	text = ""
	focus_mode = Control.FOCUS_ALL
	mouse_entered.connect(queue_redraw)
	mouse_exited.connect(queue_redraw)
	button_down.connect(queue_redraw)
	button_up.connect(queue_redraw)
	focus_entered.connect(queue_redraw)
	focus_exited.connect(queue_redraw)
	resized.connect(queue_redraw)

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
	var ink := ClubInk.PAPER if not disabled else Color(ClubInk.MUTED, 0.45)
	if is_hovered() and not disabled:
		ink = ClubInk.BRASS
	var center := size * 0.5
	match kind:
		"menu":
			for offset in [-5.0, 0.0, 5.0]:
				draw_line(center + Vector2(-7, offset), center + Vector2(7, offset), ink, 1.6, true)
		"pause":
			draw_line(center + Vector2(-4, -6), center + Vector2(-4, 6), ink, 2.4, true)
			draw_line(center + Vector2(4, -6), center + Vector2(4, 6), ink, 2.4, true)
		"shield":
			var points := PackedVector2Array([
				center + Vector2(0, -8), center + Vector2(7, -5), center + Vector2(6, 3),
				center + Vector2(0, 8), center + Vector2(-6, 3), center + Vector2(-7, -5)])
			draw_polyline(points + PackedVector2Array([points[0]]), ink, 1.5, true)
		"star":
			var star := PackedVector2Array()
			for index in range(10):
				var angle := -PI * 0.5 + TAU * float(index) / 10.0
				var radius := 8.0 if index % 2 == 0 else 3.4
				star.append(center + Vector2.from_angle(angle) * radius)
			star.append(star[0])
			draw_colored_polygon(star, ink)
	if not badge.is_empty():
		var font := ClubInk.sans(700, 0)
		var width := font.get_string_size(badge, HORIZONTAL_ALIGNMENT_LEFT, -1, 10).x
		draw_string(font, Vector2(size.x - width - 4, size.y - 4), badge, HORIZONTAL_ALIGNMENT_LEFT, -1, 10, ClubInk.BRASS)
	if has_focus():
		var focus := ClubInk.box(Color(0, 0, 0, 0), ClubInk.PAPER, 8, 0)
		focus.set_border_width_all(2)
		draw_style_box(focus, Rect2(Vector2.ZERO, size))
