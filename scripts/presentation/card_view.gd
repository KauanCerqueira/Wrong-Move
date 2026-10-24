extends Button
## Native 52-face deck. Indices always come from the engine's card ID.
## Rank and suit are drawn twice (upright and inverted) around an engraved body,
## so the card reads at a glance on a phone and still looks printed up close.
const ClubInk = preload("res://scripts/presentation/club_skin.gd")
const RANKS := ["2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K", "A"]
const SUITS := ["♣", "♦", "♥", "♠"]
const SUIT_NAMES := ["paus", "ouros", "copas", "espadas"]
## Classic pip positions, normalised to the printable area. Lower half is inverted.
const PIP_LAYOUT := {
	0: [], 1: [],
	2: [Vector2(0.5, 0.16), Vector2(0.5, 0.84)],
	3: [Vector2(0.5, 0.16), Vector2(0.5, 0.5), Vector2(0.5, 0.84)],
	4: [Vector2(0.3, 0.16), Vector2(0.7, 0.16), Vector2(0.3, 0.84), Vector2(0.7, 0.84)],
	5: [Vector2(0.3, 0.16), Vector2(0.7, 0.16), Vector2(0.5, 0.5), Vector2(0.3, 0.84), Vector2(0.7, 0.84)],
	6: [Vector2(0.3, 0.14), Vector2(0.7, 0.14), Vector2(0.3, 0.5), Vector2(0.7, 0.5), Vector2(0.3, 0.86), Vector2(0.7, 0.86)],
	7: [Vector2(0.3, 0.14), Vector2(0.7, 0.14), Vector2(0.5, 0.32), Vector2(0.3, 0.5), Vector2(0.7, 0.5), Vector2(0.3, 0.86), Vector2(0.7, 0.86)],
	8: [Vector2(0.3, 0.14), Vector2(0.7, 0.14), Vector2(0.5, 0.32), Vector2(0.3, 0.5), Vector2(0.7, 0.5), Vector2(0.5, 0.68), Vector2(0.3, 0.86), Vector2(0.7, 0.86)],
	9: [Vector2(0.3, 0.14), Vector2(0.7, 0.14), Vector2(0.3, 0.38), Vector2(0.7, 0.38), Vector2(0.5, 0.5), Vector2(0.3, 0.62), Vector2(0.7, 0.62), Vector2(0.3, 0.86), Vector2(0.7, 0.86)],
	10: [Vector2(0.3, 0.14), Vector2(0.7, 0.14), Vector2(0.5, 0.26), Vector2(0.3, 0.38), Vector2(0.7, 0.38), Vector2(0.3, 0.62), Vector2(0.7, 0.62), Vector2(0.5, 0.74), Vector2(0.3, 0.86), Vector2(0.7, 0.86)],
}
var card_id: int = -1
var four_colors := false
var empty_slot := false
var reduced_motion := false
## Cards on the felt can be picked up and moved; only the stage enables this,
## because a container would fight the drag with its own layout.
var draggable := false
var _expanded := false
var _motion: Tween
var _press_local := Vector2.ZERO
var _pressed := false
var _dragging := false
var _moved := false
var _drag_tween: Tween
var _deal_tween: Tween
var _slot := Vector2.ZERO
var _dealing := false
var _deal_from := Vector2.ZERO
var rest_rotation := 0.0

func _init() -> void:
	custom_minimum_size = Vector2(48, 68)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	pressed.connect(_toggle_size)
	resized.connect(queue_redraw)

func _gui_input(event: InputEvent) -> void:
	if not draggable or card_id < 0:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		_pressed = event.pressed
		if event.pressed:
			_press_local = event.position
			_moved = false
		elif _dragging:
			_release()
	elif event is InputEventMouseMotion and _pressed:
		if not _dragging and event.position.distance_to(_press_local) > 6.0 and not reduced_motion:
			_lift()
		if _dragging:
			position = _clamp_to_parent(position + event.relative)

func _clamp_to_parent(value: Vector2) -> Vector2:
	var parent := get_parent() as Control
	if parent == null:
		return value
	var margin := 6.0
	return Vector2(
		clampf(value.x, margin - size.x * 0.5, parent.size.x - margin - size.x * 0.5),
		clampf(value.y, margin - size.y * 0.5, parent.size.y - margin - size.y * 0.5))

func _lift() -> void:
	_dragging = true
	_moved = true
	z_index = 20
	pivot_offset = size * 0.5
	if _deal_tween != null:
		_deal_tween.kill()
	if _drag_tween != null:
		_drag_tween.kill()
	_drag_tween = create_tween().set_parallel(true)
	_drag_tween.tween_property(self, "scale", Vector2(1.12, 1.12), 0.12).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	_drag_tween.tween_property(self, "rotation", deg_to_rad(-3.0), 0.12).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	queue_redraw()

func _release() -> void:
	_dragging = false
	z_index = 0
	if _drag_tween != null:
		_drag_tween.kill()
	_drag_tween = create_tween().set_parallel(true)
	_drag_tween.tween_property(self, "position", _slot, 0.34).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_drag_tween.tween_property(self, "scale", Vector2.ONE, 0.26).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	_drag_tween.tween_property(self, "rotation", rest_rotation, 0.26)
	queue_redraw()

## The stage owns the slot; a card that is being dealt keeps its slot updated
## so a resize mid-deal cannot strand it at a stale coordinate.
func set_slot(value: Vector2) -> void:
	_slot = value
	if not _dealing:
		position = value

func set_rest_rotation(value: float) -> void:
	rest_rotation = value
	if not _dealing and not _dragging:
		rotation = value

## Slide the card from a point on the felt into its slot. Used when a card is
## dealt so the table feels like a table and not a state change.
func play_deal(from: Vector2, delay: float = 0.0) -> void:
	if not is_inside_tree():
		return
	if reduced_motion:
		_dealing = false
		position = _slot
		modulate.a = 1.0
		return
	if _deal_tween != null:
		_deal_tween.kill()
	_dealing = true
	_deal_from = from
	position = from
	modulate.a = 0.0
	scale = Vector2(0.82, 0.82)
	rotation = deg_to_rad(-9.0)
	_deal_tween = create_tween().set_parallel(true)
	_deal_tween.tween_method(_on_deal_step, 0.0, 1.0, 0.34).set_delay(delay).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	_deal_tween.tween_property(self, "modulate:a", 1.0, 0.18).set_delay(delay)
	_deal_tween.tween_property(self, "scale", Vector2.ONE, 0.3).set_delay(delay).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_deal_tween.tween_property(self, "rotation", rest_rotation, 0.28).set_delay(delay).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	_deal_tween.finished.connect(_end_deal)

func _on_deal_step(progress: float) -> void:
	position = _deal_from.lerp(_slot, progress)

func _end_deal() -> void:
	_dealing = false
	position = _slot
	rotation = rest_rotation

func set_card(value: int, use_four_colors: bool = false, empty: bool = false) -> void:
	var changed := value != card_id
	card_id = value
	four_colors = use_four_colors
	empty_slot = empty
	text = ""
	var face := ClubInk.box(ClubInk.PAPER if value >= 0 else Color("0f2b21"), Color("c9b78e") if value >= 0 else Color("4d6a52"), 6, 0)
	if value >= 0:
		face.shadow_color = Color(0.01, 0.05, 0.035, 0.5)
		face.shadow_size = 5
		face.shadow_offset = Vector2(0, 3)
	for state: String in ["normal", "hover", "pressed", "disabled"]:
		add_theme_stylebox_override(state, face)
	var focus := ClubInk.box(Color(0, 0, 0, 0), ClubInk.COPPER, 6, 0)
	focus.set_border_width_all(2)
	add_theme_stylebox_override("focus", focus)
	if value >= 0 and value < 52:
		tooltip_text = RANKS[value % 13] + " de " + SUIT_NAMES[int(value / 13)]
	else:
		tooltip_text = "Carta da mesa ainda não aberta" if empty else "Carta fechada"
	if changed and value >= 0 and is_inside_tree() and not reduced_motion and not draggable:
		if _motion != null:
			_motion.kill()
		pivot_offset = size * 0.5
		modulate.a = 0.0
		scale = Vector2(0.9, 0.9)
		_motion = create_tween().set_parallel(true)
		_motion.tween_property(self, "modulate:a", 1.0, 0.17)
		_motion.tween_property(self, "scale", _resting_scale(), 0.24).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	queue_redraw()

func _draw() -> void:
	if _dragging:
		draw_style_box(ClubInk.box(Color(0.01, 0.04, 0.03, 0.5), Color(0, 0, 0, 0), 7, 0), Rect2(Vector2(2, 7), size))
	if card_id < 0 or card_id > 51:
		if empty_slot:
			_draw_socket()
		else:
			_draw_back()
		return
	var suit := int(card_id / 13)
	var rank_index := card_id % 13
	var ink := _ink(suit)
	var body := Rect2(Vector2(3, 3), size - Vector2(6, 6))
	ClubInk.hairline(self, body, Color(ClubInk.COPPER, 0.42))
	ClubInk.corner_marks(self, body.grow(-2.5), Color(ClubInk.COPPER, 0.34), minf(size.x * 0.1, 6.0))
	var rank: String = RANKS[rank_index]
	var glyph: String = SUITS[suit]
	var index_size := clampi(int(size.y * 0.2), 15, 26)
	var suit_size := clampi(int(size.y * 0.13), 11, 18)
	_draw_index(rank, glyph, ink, index_size, suit_size)
	_draw_index(rank, glyph, ink, index_size, suit_size, true)
	if rank_index == 0:
		# The ace is the deck's signature mark: a large, custom seal instead of
		# an oversized stock glyph.
		var center := Vector2(size.x * 0.5, size.y * 0.54)
		draw_circle(center, size.y * 0.16, Color(ink, 0.08))
		ClubInk.guilloche(self, center, size.y * 0.18, Color(ink, 0.52), 20)
		_centered(glyph, ClubInk.SANS, clampi(int(size.y * 0.28), 24, 42), center.y + size.y * 0.1, ink)
	elif rank_index in [9, 10, 11]:
		_draw_court(rank, glyph, ink)
	elif rank_index == 12:
		_centered(glyph, ClubInk.SANS, clampi(int(size.y * 0.32), 26, 44), size.y * 0.6, ink)
		ClubInk.guilloche(self, Vector2(size.x * 0.5, size.y * 0.44), size.y * 0.16, Color(ink, 0.16), 18)
	else:
		var pip_size := clampi(int(size.y * 0.135), 12, 19)
		for point: Vector2 in PIP_LAYOUT.get(rank_index + 1, []):
			var position := Vector2(size.x * point.x, size.y * point.y)
			var flipped := point.y > 0.52
			if flipped:
				draw_set_transform(position, PI, Vector2.ONE)
				_centered(glyph, ClubInk.SANS, pip_size, 0, ink, Vector2.ZERO)
				draw_set_transform(Vector2.ZERO, 0, Vector2.ONE)
			else:
				_centered(glyph, ClubInk.SANS, pip_size, 0, ink, position)

func _ink(suit: int) -> Color:
	if four_colors:
		match suit:
			0: return Color("1a5c3d")
			1: return Color("24589a")
			2: return Color("b02a33")
			_: return Color("14241d")
	return Color("14241d") if suit in [0, 3] else Color("a8232e")

func _draw_index(rank: String, glyph: String, ink: Color, index_size: int, suit_size: int, inverted: bool = false) -> void:
	var left := 6.0
	var top := 4.0
	var inset := 6.0
	if inverted:
		draw_set_transform(Vector2(size.x, size.y), PI, Vector2.ONE)
		left = inset
		top = 3.0
	draw_string(ClubInk.serif(600), Vector2(left, top + index_size), rank, HORIZONTAL_ALIGNMENT_LEFT, -1, index_size, ink)
	draw_string(ClubInk.SANS, Vector2(left + 0.5, top + index_size + suit_size * 0.92), glyph, HORIZONTAL_ALIGNMENT_LEFT, -1, suit_size, ink)
	if inverted:
		draw_set_transform(Vector2.ZERO, 0, Vector2.ONE)

## Engraved cartouche for J, Q and K: small original portrait language rather
## than a giant letter. The corner index still carries the fast card read.
func _draw_court(rank: String, glyph: String, ink: Color) -> void:
	var panel := Rect2(Vector2(size.x * 0.2, size.y * 0.17), Vector2(size.x * 0.6, size.y * 0.66))
	draw_rect(panel, Color(ink, 0.05))
	ClubInk.hairline(self, panel, Color(ink, 0.5))
	ClubInk.hairline(self, panel.grow(-2.5), Color(ink, 0.28))
	var center := panel.get_center() + Vector2(0, size.y * 0.02)
	draw_circle(center, size.y * 0.13, Color(ink, 0.12))
	draw_circle(center + Vector2(0, size.y * 0.02), size.y * 0.085, Color(ink, 0.2))
	# Hair and collar give the three courts a shared family with distinct
	# silhouettes: J low, Q rounded, K angular.
	var hair_color := Color(ink, 0.72)
	if rank == "Q":
		draw_arc(center + Vector2(0, -size.y * 0.04), size.y * 0.15, PI, TAU, 16, hair_color, size.y * 0.05, true)
	elif rank == "K":
		draw_line(center + Vector2(-size.y * 0.14, -size.y * 0.12), center + Vector2(0, -size.y * 0.2), hair_color, size.y * 0.06, true)
		draw_line(center + Vector2(0, -size.y * 0.2), center + Vector2(size.y * 0.14, -size.y * 0.12), hair_color, size.y * 0.06, true)
	else:
		draw_arc(center + Vector2(0, -size.y * 0.02), size.y * 0.14, PI, TAU, 16, hair_color, size.y * 0.07, true)
	draw_circle(center + Vector2(-size.y * 0.045, 0), size.y * 0.014, ink)
	draw_circle(center + Vector2(size.y * 0.045, 0), size.y * 0.014, ink)
	draw_line(center + Vector2(-size.y * 0.07, size.y * 0.11), center + Vector2(size.y * 0.07, size.y * 0.11), ink, 1.0, true)
	ClubInk.diamond(self, Vector2(size.x * 0.5, panel.end.y - size.y * 0.08), size.y * 0.025, Color(ink, 0.55))

func _draw_socket() -> void:
	var center := size * 0.5
	draw_style_box(ClubInk.box(Color(0.08, 0.20, 0.15, 0.55), Color("3d5a48"), 6, 0), Rect2(Vector2(3, 3), size - Vector2(6, 6)))
	ClubInk.diamond(self, center, minf(size.x, size.y) * 0.055, Color(ClubInk.COPPER, 0.3))

func _draw_back() -> void:
	var body := Rect2(Vector2(3, 3), size - Vector2(6, 6))
	ClubInk.hairline(self, body, Color(ClubInk.COPPER, 0.45))
	var inner := body.grow(-4)
	draw_rect(inner, Color("123a2a"))
	var step := maxf(9.0, size.x * 0.14)
	var lattice := Color(ClubInk.COPPER, 0.16)
	var y := inner.position.y
	while y < inner.end.y:
		draw_line(Vector2(inner.position.x, y), Vector2(inner.end.x, y), lattice, 0.8, true)
		y += step
	var x := inner.position.x
	while x < inner.end.x:
		draw_line(Vector2(x, inner.position.y), Vector2(x, inner.end.y), lattice, 0.8, true)
		x += step
	var center := size * 0.5
	var radius := minf(size.x, size.y) * 0.19
	draw_circle(center, radius, ClubInk.INK)
	draw_arc(center, radius, 0, TAU, 32, ClubInk.COPPER, 1.0, true)
	_centered("WM", ClubInk.serif(700), int(radius * 1.1), center.y + radius * 0.38, ClubInk.PAPER)

func _centered(value: String, font: Font, font_size: int, baseline: float, color: Color, center: Vector2 = Vector2(-1, -1)) -> void:
	var width := font.get_string_size(value, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
	var origin := center
	if origin.x < 0:
		origin = Vector2((size.x - width) * 0.5, baseline)
	else:
		origin.x -= width * 0.5
		origin.y += font_size * 0.36
	draw_string(font, origin, value, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)

func _resting_scale() -> Vector2:
	return Vector2.ONE * (1.16 if _expanded else 1.0)

func _toggle_size() -> void:
	if card_id < 0:
		return
	if _moved:
		_moved = false
		return
	_expanded = not _expanded
	pivot_offset = size * 0.5
	z_index = 4 if _expanded else 0
	if reduced_motion:
		scale = _resting_scale()
		return
	# Magnify visually without displacing the betting controls.
	create_tween().tween_property(self, "scale", _resting_scale(), 0.14).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
