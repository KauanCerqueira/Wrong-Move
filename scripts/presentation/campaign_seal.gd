extends Button
## Campaign node. Won tables are embossed ivory seals, the next table is red wax,
## locked tables are pressed lead.
const ClubInk = preload("res://scripts/presentation/club_skin.gd")
var entry: Dictionary = {}
var selected := false

func _init() -> void:
	custom_minimum_size = Vector2(76, 76)
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	for state: String in ["normal", "hover", "pressed", "focus"]:
		add_theme_stylebox_override(state, StyleBoxEmpty.new())
	mouse_entered.connect(queue_redraw)
	mouse_exited.connect(queue_redraw)
	resized.connect(queue_redraw)

func refresh() -> void:
	queue_redraw()

func _draw() -> void:
	var center := size * 0.5
	var locked: bool = entry.get("locked", false)
	var won: bool = entry.get("won", false)
	var radius := minf(size.x, size.y) * 0.5 - 6
	var fill := ClubInk.PAPER if won else (ClubInk.RED if not locked else Color("122a21"))
	var ink := ClubInk.INK if won else (ClubInk.PAPER if not locked else Color("4a6650"))
	if selected:
		draw_circle(center, radius + 6.5, Color(ClubInk.COPPER, 0.16))
	ClubInk.seal(self, center, radius, fill, ink)
	draw_arc(center, radius - 5, 0, TAU, 48, Color(ink, 0.55), 1.0, true)
	if selected:
		draw_arc(center, radius + 3.5, 0, TAU, 56, ClubInk.COPPER, 1.6, true)
		ClubInk.diamond(self, center + Vector2(radius + 8, 0), 3.4, ClubInk.COPPER)
	if has_focus():
		draw_arc(center, radius + 8, 0, TAU, 56, ClubInk.PAPER, 1.2, true)
	if locked:
		var shackle := center + Vector2(0, -4)
		draw_arc(shackle, 6.5, PI, TAU, 18, ink, 2.0, true)
		draw_rect(Rect2(center + Vector2(-9, -2), Vector2(18, 14)), ink)
		draw_circle(center + Vector2(0, 4), 2.2, fill)
		return
	var number := str(entry.get("index", "1"))
	var shown := number.pad_zeros(2) if number.length() <= 3 else "…" + number.right(3)
	var font_size := 26 if shown.length() <= 2 else 20
	var width := ClubInk.serif(700).get_string_size(shown, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
	draw_string(ClubInk.serif(700), Vector2(center.x - width * 0.5, center.y + font_size * 0.36), shown, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, ink)
	if won:
		var check := center + Vector2(radius * 0.62, -radius * 0.62)
		draw_circle(check, 8, ClubInk.FELT)
		draw_polyline(PackedVector2Array([check + Vector2(-4, 0), check + Vector2(-1, 3), check + Vector2(4, -3)]), ClubInk.PAPER, 1.7, true)
