extends Control
## Round player avatar: monogram on a felt disc with a copper rim.
const ClubInk = preload("res://scripts/presentation/club_skin.gd")
var glyph := "V"
var open_ring := false

func _init() -> void:
	custom_minimum_size = Vector2(30, 30)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)

func _draw() -> void:
	var center := size * 0.5
	var radius := minf(size.x, size.y) * 0.5 - 1.0
	draw_circle(center + Vector2(0, 1.5), radius, Color(0.01, 0.04, 0.03, 0.5))
	draw_circle(center, radius, ClubInk.SURFACE_HI)
	ClubInk.guilloche(self, center, radius - 4.0, Color(ClubInk.COPPER, 0.16), 16)
	draw_arc(center, radius, 0, TAU, 40, Color(ClubInk.COPPER, 0.8 if open_ring else 0.45), 1.2, true)
	var font := ClubInk.serif(700)
	var width := font.get_string_size(glyph, HORIZONTAL_ALIGNMENT_LEFT, -1, 13).x
	draw_string(font, Vector2(center.x - width * 0.5, center.y + 5), glyph, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, ClubInk.PAPER)
