extends Control
## Pot chips: a visible pile, not an icon. Denominations decay so the pile reads
## "bigger" as the pot grows without ever overflowing the felt.
const ClubInk = preload("res://scripts/presentation/club_skin.gd")
const DENOMINATIONS := [
	{"value": 1000, "face": Color("e2c58e")},
	{"value": 100, "face": Color("1c3f31")},
	{"value": 25, "face": Color("a82f33")},
	{"value": 5, "face": Color("4c7a58")},
]
var amount: int = 0:
	set(value):
		var changed := maxi(0, value) != amount
		amount = maxi(0, value)
		queue_redraw()
		if changed and is_inside_tree():
			_pulse()
var _tween: Tween

func _init() -> void:
	custom_minimum_size = Vector2(60, 30)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)

func _draw() -> void:
	if amount <= 0:
		return
	var remaining := amount
	var column := 0
	for denomination: Dictionary in DENOMINATIONS:
		var unit: int = denomination.value
		if remaining < unit:
			continue
		var count := mini(int(remaining / unit), 2)
		remaining -= count * unit
		if count <= 0:
			continue
		var x := size.x * 0.5 + (column - 1) * size.x * 0.24
		for index in range(count):
			_ellipse_chip(Vector2(x + index * 1.5, size.y - 7 - index * 5), 9.0, denomination.face)
		column += 1
		if column >= 3:
			break

func _ellipse_chip(center: Vector2, radius: float, face: Color) -> void:
	draw_set_transform(center + Vector2(0, 2), 0, Vector2(1, 0.58))
	draw_circle(Vector2.ZERO, radius, Color(0.01, 0.04, 0.03, 0.55))
	draw_circle(Vector2.ZERO, radius, ClubInk.INK)
	draw_circle(Vector2.ZERO, radius - 1.4, face)
	for index in range(6):
		var angle := TAU * float(index) / 6.0 + 0.3
		draw_line(Vector2.from_angle(angle) * (radius * 0.62), Vector2.from_angle(angle) * (radius - 1.8), Color(ClubInk.PAPER, 0.7), 1.6, true)
	draw_arc(Vector2.ZERO, radius - 1.4, 0, TAU, 28, Color(ClubInk.PAPER, 0.35), 0.8, true)
	draw_set_transform(Vector2.ZERO, 0, Vector2.ONE)

func _pulse() -> void:
	if _tween != null:
		_tween.kill()
	pivot_offset = size * 0.5
	modulate = Color(1, 1, 1, 1)
	_tween = create_tween()
	_tween.tween_property(self, "scale", Vector2(1.06, 1.06), 0.09)
	_tween.tween_property(self, "scale", Vector2.ONE, 0.16).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
