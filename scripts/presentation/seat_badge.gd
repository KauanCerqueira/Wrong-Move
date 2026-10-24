extends Button
## Opponent pod on the rail: avatar disc, angled hole cards, name and stack.
const ClubInk = preload("res://scripts/presentation/club_skin.gd")
const PROFILES := [
	{"name": "Nico", "tag": "IMPULSIVO", "glyph": "N", "skin": Color("b9785d"), "accent": Color("d6ac62")},
	{"name": "Mara", "tag": "ESTRATEGISTA", "glyph": "M", "skin": Color("8f6d80"), "accent": Color("b7d0b7")},
	{"name": "Otto", "tag": "VETERANO", "glyph": "O", "skin": Color("9c7658"), "accent": Color("c7b18a")},
	{"name": "Dante", "tag": "ESPECIALISTA", "glyph": "D", "skin": Color("6e7c92"), "accent": Color("d68a76")},
]
var seat: Dictionary = {}
var acting := false
var dealer := false
var text_scale := 1.0
var reduced_motion := false
var compact := false
var _pulse: Tween
var _ring: Tween
var _glow := 0.0

func _init() -> void:
	custom_minimum_size = Vector2(92, 62)
	flat = true
	for state: String in ["normal", "hover", "pressed", "focus"]:
		add_theme_stylebox_override(state, StyleBoxEmpty.new())
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	resized.connect(queue_redraw)

func configure(value: Dictionary, is_acting: bool, is_dealer: bool, scale_value: float, is_compact: bool = false) -> void:
	var was_acting := acting
	seat = value
	acting = is_acting
	dealer = is_dealer
	text_scale = scale_value
	compact = is_compact
	text = ""
	var profile: Dictionary = _profile()
	var status := ""
	if seat.get("folded", false):
		status = "\nDesistiu (fold)"
	elif seat.get("all_in", false):
		status = "\nApostou tudo (all-in)"
	var active := " · sua vez" if acting else ""
	tooltip_text = "%s · %s fichas%s\n%s%s" % [profile.name, seat.get("stack", 0), active, profile.tag, status]
	queue_redraw()
	if acting and not was_acting and is_inside_tree():
		_animate_turn()
	_set_ring_loop(acting)

## A slow breathing ring marks whose decision the table is waiting for.
func _set_ring_loop(active: bool) -> void:
	if not active or reduced_motion:
		if _ring != null:
			_ring.kill()
			_ring = null
		_glow = 0.0
		queue_redraw()
		return
	if _ring != null and _ring.is_running():
		return
	_ring = create_tween().set_loops()
	_ring.tween_method(_on_ring_step, 0.0, 1.0, 1.15).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_ring.tween_method(_on_ring_step, 1.0, 0.0, 1.15).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _on_ring_step(value: float) -> void:
	_glow = value
	queue_redraw()

func _draw() -> void:
	var folded: bool = seat.get("folded", false)
	var all_in: bool = seat.get("all_in", false)
	var profile: Dictionary = _profile()
	var radius := 17.0 if compact else 21.0
	var group := radius * 2.0 + 26.0
	var center := Vector2((size.x - group) * 0.5 + radius, radius + 3)
	if acting:
		for ring in range(2):
			var alpha := (0.34 - ring * 0.12) * (0.55 + 0.45 * _glow)
			draw_arc(center, radius + 4 + ring * 4 + _glow * 1.5, 0, TAU, 48, Color(ClubInk.BRASS, maxf(alpha, 0.06)), 1.5, true)
	elif all_in:
		draw_arc(center, radius + 4, 0, TAU, 48, Color(ClubInk.RED, 0.85), 1.6, true)
	# avatar
	draw_circle(center + Vector2(0, 2), radius, Color(0.01, 0.04, 0.03, 0.55))
	draw_circle(center, radius, ClubInk.INK_SOFT if folded else ClubInk.SURFACE_HI)
	if not folded:
		ClubInk.guilloche(self, center, radius - 4, Color(ClubInk.COPPER, 0.16), 18)
	draw_arc(center, radius, 0, TAU, 48, ClubInk.PAPER if acting else Color(ClubInk.COPPER, 0.75), 1.2, true)
	var glyph: String = str(profile.glyph)
	var ink := Color(ClubInk.MUTED, 0.7) if folded else (ClubInk.PAPER if acting else ClubInk.COPPER)
	_draw_portrait(center, radius, profile, folded)
	if folded:
		_centered_at(glyph, ClubInk.SANS, radius * 1.2, center, ink)
	if folded:
		draw_line(center + Vector2(-radius * 0.6, radius * 0.55), center + Vector2(radius * 0.6, -radius * 0.55), Color(ClubInk.RED, 0.75), 1.6, true)
	if dealer:
		var marker := center + Vector2(-radius * 0.75, radius * 0.75)
		draw_circle(marker, 7.0, ClubInk.INK)
		draw_circle(marker, 6.0, Color("f6efe0"))
		_centered_at("D", ClubInk.serif(700), 9, marker, ClubInk.INK)
	_draw_hole_cards(center, folded)
	var name_text := str(profile.name)
	var name_color := ClubInk.MUTED
	if folded:
		name_text = "desistiu"
		name_color = Color(ClubInk.MUTED, 0.55)
	elif all_in:
		name_text = "all-in"
		name_color = Color("e9a89b")
	elif acting:
		name_color = ClubInk.BRASS
	var label_y := center.y + radius + 13
	_centered(name_text, ClubInk.sans(600, 1), int(10 * text_scale), label_y + 9 * text_scale, name_color)
	_centered(str(seat.get("stack", 0)), ClubInk.serif(600), int(14 * text_scale), label_y + 9 * text_scale + 15 * text_scale, ClubInk.PAPER if not folded else Color(ClubInk.MUTED, 0.6))
	if has_focus():
		draw_style_box(ClubInk.box(Color(0, 0, 0, 0), ClubInk.PAPER, 6, 0), Rect2(Vector2(2, 2), size - Vector2(4, 4)))

func _profile() -> Dictionary:
	var index := clampi(int(seat.get("id", 1)) - 1, 0, PROFILES.size() - 1)
	return PROFILES[index]

## Small vector portraits keep the silhouette readable without claiming to be
## final painted art. Each opponent has a face shape, hair and accent of their
## own, while the same monogram system keeps the table cohesive.
func _draw_portrait(center: Vector2, radius: float, profile: Dictionary, folded: bool) -> void:
	if folded:
		return
	var skin: Color = profile.skin
	var accent: Color = profile.accent
	var face := Rect2(center + Vector2(-radius * 0.34, -radius * 0.25), Vector2(radius * 0.68, radius * 0.76))
	draw_style_box(ClubInk.box(skin, Color(0, 0, 0, 0), int(radius * 0.28), 0), face)
	# Hair / signature shape changes by character, but remains compact on phones.
	var top := center + Vector2(0, -radius * 0.42)
	draw_arc(top, radius * 0.48, PI, TAU, 16, accent, radius * 0.24, true)
	var eye_y := center.y - radius * 0.02
	draw_circle(Vector2(center.x - radius * 0.16, eye_y), radius * 0.045, ClubInk.INK)
	draw_circle(Vector2(center.x + radius * 0.16, eye_y), radius * 0.045, ClubInk.INK)
	draw_line(Vector2(center.x - radius * 0.13, center.y + radius * 0.22), Vector2(center.x + radius * 0.13, center.y + radius * 0.22), accent, 1.2, true)

## Two small card backs leaning towards the middle of the table.
func _draw_hole_cards(center: Vector2, folded: bool) -> void:
	var card_size := Vector2(17, 24) if compact else Vector2(19, 27)
	var origin := center + Vector2(9, -13)
	for index in range(2):
		var position := origin + Vector2(index * 6.0, index * 1.5)
		draw_set_transform(position, deg_to_rad(-14.0 + index * 6.0), Vector2.ONE)
		var face := ClubInk.box(Color("123a2a") if not folded else Color("14261f"), Color(ClubInk.COPPER, 0.55 if not folded else 0.2), 3, 0)
		draw_style_box(face, Rect2(Vector2.ZERO, card_size))
		ClubInk.hairline(self, Rect2(Vector2(2, 2), card_size - Vector2(4, 4)), Color(ClubInk.COPPER, 0.16 if not folded else 0.08))
		ClubInk.diamond(self, card_size * 0.5, 2.6, Color(ClubInk.COPPER, 0.35 if not folded else 0.12))
		draw_set_transform(Vector2.ZERO, 0, Vector2.ONE)

func _centered(value: String, font: Font, font_size: int, baseline: float, color: Color) -> void:
	var width := font.get_string_size(value, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
	draw_string(font, Vector2((size.x - width) * 0.5, baseline), value, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)

func _centered_at(value: String, font: Font, font_size: int, center: Vector2, color: Color) -> void:
	var width := font.get_string_size(value, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
	draw_string(font, Vector2(center.x - width * 0.5, center.y + font_size * 0.36), value, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)

func _animate_turn() -> void:
	if _pulse != null:
		_pulse.kill()
	pivot_offset = Vector2(size.x * 0.5, 20)
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector2(1.06, 1.06), 0.12).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2.ONE, 0.22).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	_pulse = tween
