extends Control
## Section divider: hairline, centre diamond and two bead finials.
const ClubInk = preload("res://scripts/presentation/club_skin.gd")

func _init() -> void:
	custom_minimum_size.y = 16
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)

func _draw() -> void:
	var center := size * 0.5
	var color := Color(ClubInk.COPPER, 0.75)
	draw_line(Vector2(4, center.y), center - Vector2(20, 0), color, 1, true)
	draw_line(center + Vector2(20, 0), Vector2(size.x - 4, center.y), color, 1, true)
	ClubInk.diamond(self, center, 4.5, Color(ClubInk.COPPER, 0.9))
	ClubInk.diamond(self, center, 2.6, ClubInk.RED)
	for direction in [-1, 1]:
		var bead := center + Vector2(direction * 13, 0)
		draw_circle(bead, 2.0, color, false, 1, true)
