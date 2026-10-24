extends Control
## Home hero: a letterpress arch that frames the engraved card fan.
const ClubInk = preload("res://scripts/presentation/club_skin.gd")
var texture: Texture2D:
	set(value):
		texture = value
		queue_redraw()

func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)

func _draw() -> void:
	var arch := Rect2(Vector2.ZERO, size)
	var radius := int(size.x * 0.4)
	var outer := ClubInk.box(Color(0.03, 0.11, 0.08, 0.85), Color(ClubInk.COPPER, 0.32), radius, 0)
	outer.corner_radius_bottom_left = 12
	outer.corner_radius_bottom_right = 12
	draw_style_box(outer, arch)
	var inner := arch.grow(-7)
	var middle := ClubInk.box(Color(0.08, 0.2, 0.15, 0.55), Color(ClubInk.COPPER, 0.16), int(inner.size.x * 0.4), 0)
	middle.corner_radius_bottom_left = 8
	middle.corner_radius_bottom_right = 8
	draw_style_box(middle, inner)
	if texture != null:
		var art := texture.get_size()
		var fit := minf((size.x - 20) / art.x, (size.y - 18) / art.y)
		var target := Rect2(Vector2((size.x - art.x * fit) * 0.5, (size.y - art.y * fit) * 0.5), art * fit)
		draw_texture_rect(texture, Rect2(target.position + Vector2(0, 5), target.size), false, Color(0.02, 0.06, 0.04, 0.45))
		draw_texture_rect(texture, target, false, Color.WHITE)
