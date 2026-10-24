extends Control
## Static, resolution-independent letterpress atmosphere; no per-frame processing.
## A deep green wash, paper grain, a double keyline and corner fleurons.
const ClubInk = preload("res://scripts/presentation/club_skin.gd")
var _grain: TextureRect
var _wash: GradientTexture2D

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var gradient := Gradient.new()
	gradient.offsets = PackedFloat32Array([0, 0.6, 1])
	gradient.colors = PackedColorArray([Color("1a4633"), Color("0e2a21"), Color("071913")])
	_wash = GradientTexture2D.new()
	_wash.gradient = gradient
	_wash.width = 192
	_wash.height = 384
	_wash.fill = GradientTexture2D.FILL_RADIAL
	_wash.fill_from = Vector2(0.5, 0.3)
	_wash.fill_to = Vector2(1.05, 1)
	var noise := FastNoiseLite.new()
	noise.seed = 217
	noise.frequency = 0.55
	var texture := NoiseTexture2D.new()
	texture.width = 192
	texture.height = 384
	texture.noise = noise
	_grain = TextureRect.new()
	_grain.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_grain.texture = texture
	_grain.modulate = Color(0.34, 0.5, 0.38, 0.05)
	_grain.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_grain.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	add_child(_grain)
	resized.connect(queue_redraw)
	queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), ClubInk.INK)
	if _wash != null:
		draw_texture_rect(_wash, Rect2(Vector2.ZERO, size), false)
	var outer := Rect2(Vector2(5, 5), size - Vector2(10, 10))
	draw_rect(outer, Color(ClubInk.COPPER, 0.5), false, 1.0)
	draw_rect(outer.grow(-3), Color(ClubInk.COPPER, 0.18), false, 1.0)
	var inner := outer.grow(-7)
	for corner: Vector2 in [inner.position, Vector2(inner.end.x, inner.position.y), Vector2(inner.position.x, inner.end.y), inner.end]:
		_fleuron(corner)
	# Faint vertical guilloche in the margins, like a printed ledger.
	for column in [11.0, size.x - 11.0]:
		for step in range(0, int(size.y), 9):
			draw_line(Vector2(column, step), Vector2(column, step + 4), Color(ClubInk.COPPER, 0.12), 1, true)

func _fleuron(corner: Vector2) -> void:
	var horizontal := 1.0 if corner.x < size.x * 0.5 else -1.0
	var vertical := 1.0 if corner.y < size.y * 0.5 else -1.0
	var color := Color(ClubInk.COPPER, 0.65)
	for step in range(3):
		var length := 10.0 - step * 3.0
		var start := corner + Vector2(horizontal * step * 4.0, vertical * step * 4.0)
		draw_line(start, start + Vector2(horizontal * length, 0), color, 1, true)
		draw_line(start, start + Vector2(0, vertical * length), color, 1, true)
	ClubInk.diamond(self, corner + Vector2(horizontal * 7.0, vertical * 7.0), 2.2, Color(ClubInk.RED, 0.8))
