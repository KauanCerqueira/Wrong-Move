extends RefCounted
## Shared print-and-felt design system: tokens, styleboxes and drawing helpers.
## No game state crosses this boundary.

const INK := Color("08160f")
const INK_SOFT := Color("0d241c")
const SURFACE := Color("132c25")
const SURFACE_HI := Color("1a3a30")
const FELT := Color("194334")
const FELT_DEEP := Color("123526")
const PAPER := Color("f3e9d6")
const PAPER_DEEP := Color("dbcbb0")
const MUTED := Color("bcc6b2")
const COPPER := Color("c3a578")
const BRASS := Color("e6c98f")
const LINE := Color("64755b")
const RED := Color("ba363b")
const OXBLOOD := Color("6e2226")
const SERIF = preload("res://assets/fonts/NotoSerif.ttf")
const SANS = preload("res://assets/fonts/NotoSans.ttf")

static func serif(weight: int = 600, tracking: int = 0) -> FontVariation:
	var font := FontVariation.new()
	font.base_font = SERIF
	font.variation_opentype = {"wght": weight}
	font.spacing_glyph = tracking
	return font

static func sans(weight: int = 500, tracking: int = 0) -> FontVariation:
	var font := FontVariation.new()
	font.base_font = SANS
	font.variation_opentype = {"wght": weight}
	font.spacing_glyph = tracking
	return font

static func box(background: Color, border: Color = LINE, radius: int = 7, padding: int = 10) -> StyleBoxFlat:
	var result := StyleBoxFlat.new()
	result.bg_color = background
	result.border_color = border
	result.set_border_width_all(1)
	result.set_corner_radius_all(radius)
	result.content_margin_left = padding
	result.content_margin_right = padding
	result.content_margin_top = 7
	result.content_margin_bottom = 7
	return result

## Raised plaque resting on felt.
static func plaque(background: Color = SURFACE, border: Color = LINE, radius: int = 10, padding: int = 10) -> StyleBoxFlat:
	var result := box(background, border, radius, padding)
	result.shadow_color = Color(0.01, 0.05, 0.035, 0.45)
	result.shadow_size = 6
	result.shadow_offset = Vector2(0, 3)
	return result

## Ivory letterpress ticket: the one bright, actionable surface per screen.
static func ticket(radius: int = 8, padding: int = 12) -> StyleBoxFlat:
	var result := box(PAPER, COPPER, radius, padding)
	result.border_width_top = 2
	result.shadow_color = Color(0.01, 0.05, 0.035, 0.5)
	result.shadow_size = 8
	result.shadow_offset = Vector2(0, 4)
	return result

static func button(control: Button, kind: String = "secondary", font_size: int = 16) -> void:
	var bg := SURFACE
	var border := LINE
	var text_color := PAPER
	var radius := 8
	var shadow := 0
	match kind:
		"primary":
			bg = PAPER
			border = COPPER
			text_color = INK
			shadow = 6
		"danger":
			bg = OXBLOOD
			border = Color("c07a6a")
			radius = 6
		"green":
			bg = Color("204b39")
			border = Color("84a888")
			radius = 6
		"ghost":
			bg = Color("0c1f19")
			border = Color("33503d")
			radius = 6
	var normal := box(bg, border, radius, 12)
	normal.content_margin_top = 10
	normal.content_margin_bottom = 10
	if shadow > 0:
		normal.shadow_color = Color(0.01, 0.05, 0.035, 0.55)
		normal.shadow_size = shadow
		normal.shadow_offset = Vector2(0, 3)
	var hover: StyleBoxFlat = normal.duplicate()
	hover.bg_color = bg.lightened(0.08) if kind != "primary" else PAPER
	hover.border_color = BRASS
	var pressed := normal.duplicate()
	pressed.bg_color = bg.darkened(0.16) if kind != "primary" else PAPER_DEEP
	pressed.border_color = PAPER if kind != "primary" else COPPER
	pressed.shadow_size = 0
	var disabled := box(Color("152720"), Color("2e4235"), radius, 12)
	disabled.content_margin_top = 10
	disabled.content_margin_bottom = 10
	control.add_theme_stylebox_override("normal", normal)
	control.add_theme_stylebox_override("hover", hover)
	control.add_theme_stylebox_override("pressed", pressed)
	control.add_theme_stylebox_override("disabled", disabled)
	var focus := box(Color(0, 0, 0, 0), PAPER, radius + 1, 12)
	focus.set_border_width_all(2)
	control.add_theme_stylebox_override("focus", focus)
	for state: String in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
		control.add_theme_color_override(state, text_color)
	control.add_theme_color_override("font_disabled_color", Color("7d8d77"))
	control.add_theme_font_override("font", sans(600 if kind == "primary" else 500, 1))
	control.add_theme_font_size_override("font_size", font_size)
	control.custom_minimum_size = Vector2(48, 48)
	control.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	control.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	control.add_theme_constant_override("outline_size", 0)

## Single-line by default: a wrapped Label reports zero minimum width and would
## collapse inside any row that has an expanding sibling. Ask for `wrap` in prose.
static func label(text: String, parent: Node, font_size: int = 16, color: Color = PAPER, font: Font = null, wrap: bool = false) -> Label:
	var result := Label.new()
	result.text = text
	result.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART if wrap else TextServer.AUTOWRAP_OFF
	result.add_theme_font_override("font", font if font != null else sans(500))
	result.add_theme_font_size_override("font_size", font_size)
	result.add_theme_color_override("font_color", color)
	parent.add_child(result)
	return result

## Small tracked capitals: section labels, table furniture, ledger captions.
static func kicker(value: String, parent: Node, font_size: int = 11, color: Color = COPPER) -> Label:
	return label(value, parent, font_size, color, sans(600, 2))

static func rule(parent: Node, color: Color = COPPER) -> void:
	var line := Control.new()
	line.custom_minimum_size.y = 18
	line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	line.draw.connect(func():
		var center := line.size * 0.5
		line.draw_line(Vector2(0, center.y), Vector2(center.x - 18, center.y), color, 1, true)
		line.draw_line(Vector2(center.x + 18, center.y), Vector2(line.size.x, center.y), color, 1, true)
		diamond(line, center, 4.0, RED)
		for direction in [-1, 1]:
			line.draw_circle(center + Vector2(direction * 12, 0), 1.8, color, false, 1, true))
	line.resized.connect(line.queue_redraw)
	parent.add_child(line)

static func slider(control: HSlider) -> void:
	var track := box(Color("0a1d16"), LINE, 3, 0)
	track.content_margin_top = 4
	track.content_margin_bottom = 4
	control.add_theme_stylebox_override("slider", track)
	control.add_theme_stylebox_override("grabber_area", box(Color("7d2f34"), COPPER, 3, 0))
	control.add_theme_stylebox_override("grabber_area_highlight", box(RED, BRASS, 3, 0))
	control.add_theme_icon_override("grabber", preload("res://assets/ui/slider-seal.svg"))
	control.add_theme_icon_override("grabber_highlight", preload("res://assets/ui/slider-seal.svg"))
	control.add_theme_icon_override("grabber_disabled", preload("res://assets/ui/slider-seal-disabled.svg"))

static func diamond(ci: CanvasItem, center: Vector2, half: float, color: Color) -> void:
	ci.draw_colored_polygon(PackedVector2Array([
		center + Vector2(0, -half), center + Vector2(half, 0),
		center + Vector2(0, half), center + Vector2(-half, 0)]), color)

static func hairline(ci: CanvasItem, rect: Rect2, color: Color) -> void:
	ci.draw_rect(rect, color, false, 1.0)

static func corner_marks(ci: CanvasItem, rect: Rect2, color: Color, length: float = 7.0) -> void:
	for corner in [rect.position, Vector2(rect.end.x, rect.position.y), Vector2(rect.position.x, rect.end.y), rect.end]:
		var horizontal := Vector2(length, 0) * (1.0 if corner.x < rect.get_center().x else -1.0)
		var vertical := Vector2(0, length) * (1.0 if corner.y < rect.get_center().y else -1.0)
		ci.draw_line(corner, corner + horizontal, color, 1, true)
		ci.draw_line(corner, corner + vertical, color, 1, true)

## Engine-turned ring: fine arcs that read as engraved metal at any size.
static func guilloche(ci: CanvasItem, center: Vector2, radius: float, color: Color, arcs: int = 36) -> void:
	var step := TAU / float(arcs)
	for index in range(arcs):
		ci.draw_arc(center, radius, index * step, index * step + step * 0.55, 4, color, 0.9, true)

static func chip(ci: CanvasItem, center: Vector2, radius: float, face: Color, ink: Color = Color("081810")) -> void:
	ci.draw_circle(center + Vector2(0, radius * 0.28), radius, Color(ink, 0.5))
	ci.draw_circle(center, radius, ink)
	ci.draw_circle(center, radius - 1.6, face)
	for index in range(6):
		var angle := TAU * float(index) / 6.0 + 0.26
		var from := center + Vector2.from_angle(angle) * (radius * 0.6)
		var to := center + Vector2.from_angle(angle) * (radius - 2.2)
		ci.draw_line(from, to, PAPER if face.v < 0.55 else ink, radius * 0.2, true)
	ci.draw_arc(center, radius - 1.6, 0, TAU, 32, Color(PAPER, 0.55), 1.0, true)
	ci.draw_circle(center, radius * 0.34, Color(PAPER, 0.9), false, 1.0, true)

## Wax seal used by campaign nodes and result plates.
static func seal(ci: CanvasItem, center: Vector2, radius: float, fill: Color, ink: Color) -> void:
	ci.draw_circle(center + Vector2(0, radius * 0.16), radius, Color(0.02, 0.06, 0.04, 0.45))
	for index in range(16):
		var angle := TAU * float(index) / 16.0
		ci.draw_circle(center + Vector2.from_angle(angle) * (radius * 0.94), radius * 0.16, fill)
	ci.draw_circle(center, radius * 0.94, fill)
	guilloche(ci, center, radius * 0.72, Color(ink, 0.35), 24)
