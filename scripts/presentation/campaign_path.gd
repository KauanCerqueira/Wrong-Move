extends Control
## The campaign route: a copper inlay that becomes dotted where the path is
## still sealed, with one wax node per table.
signal selected(entry: Dictionary)
const ClubInk = preload("res://scripts/presentation/club_skin.gd")
const Seal = preload("res://scripts/presentation/campaign_seal.gd")
const SPACING := 108.0
var entries: Array = []
var seals: Array[Button] = []
var _labels: Array[Label] = []
var _points: Array[Vector2] = []
var _selected_index := ""
var _text_scale := 1.0

func _ready() -> void:
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	resized.connect(_layout)

func set_entries(values: Array, scale_value: float = 1.0) -> void:
	entries = values
	_text_scale = scale_value
	for child: Node in get_children():
		remove_child(child)
		child.queue_free()
	seals.clear()
	_labels.clear()
	custom_minimum_size.y = entries.size() * SPACING + 16
	var initial: Dictionary = {}
	for entry: Dictionary in entries:
		var seal := Seal.new()
		seal.entry = entry
		seal.tooltip_text = "Mesa " + str(entry.get("index", "1"))
		add_child(seal)
		seals.append(seal)
		seal.pressed.connect(func(): choose(entry))
		var label := ClubInk.label("", self, int(11 * scale_value), ClubInk.MUTED, ClubInk.sans(600, 1))
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		label.autowrap_mode = TextServer.AUTOWRAP_OFF
		label.clip_text = true
		_labels.append(label)
		if initial.is_empty() and not entry.get("won", false) and not entry.get("locked", false):
			initial = entry
	if initial.is_empty() and not entries.is_empty():
		initial = entries[0]
	if not initial.is_empty():
		choose(initial)
	_layout()

func choose(entry: Dictionary) -> void:
	_selected_index = str(entry.get("index", "1"))
	for seal: Button in seals:
		seal.selected = str(seal.entry.get("index", "1")) == _selected_index
		seal.refresh()
	selected.emit(entry)

func _layout() -> void:
	if seals.size() != entries.size():
		return
	_points.clear()
	for index in range(seals.size()):
		var x: float = [0.28, 0.5, 0.72, 0.5][index % 4] * size.x
		var point := Vector2(x, 46 + index * SPACING)
		_points.append(point)
		seals[index].position = point - Vector2(38, 38)
		seals[index].size = Vector2(76, 76)
		var entry: Dictionary = entries[index]
		var caption := "VENCIDA" if entry.get("won", false) else ("BLOQUEADA" if entry.get("locked", false) else ("LIBERADA" if entry.get("unlocked", false) else "PRÓXIMA"))
		var participants: int = int(entry.get("config", {}).get("participants", 2))
		var players := "Duelo · 1 bot" if participants == 2 else "%s na mesa" % participants
		var on_right := x < size.x * 0.6
		_labels[index].text = caption + "\n" + players
		_labels[index].max_lines_visible = 2
		_labels[index].position = Vector2(x + 48 if on_right else 6, point.y - 22)
		_labels[index].size = Vector2(maxf(74, size.x - x - 54) if on_right else maxf(74, x - 52), 46)
		_labels[index].horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT if on_right else HORIZONTAL_ALIGNMENT_RIGHT
		_labels[index].add_theme_color_override("font_color", ClubInk.COPPER if entry.get("unlocked", false) or entry.get("won", false) else Color(ClubInk.MUTED, 0.7))
	queue_redraw()

func _draw() -> void:
	for index in range(1, _points.size()):
		var curve := Curve2D.new()
		curve.add_point(_points[index - 1], Vector2.ZERO, Vector2(0, SPACING * 0.62))
		curve.add_point(_points[index], Vector2(0, -SPACING * 0.62), Vector2.ZERO)
		var points := curve.get_baked_points()
		var open: bool = entries[index].get("unlocked", false) or entries[index].get("won", false) or entries[index - 1].get("won", false)
		draw_polyline(points, Color("0a1f18"), 4.0, true)
		if not open:
			for step in range(0, points.size(), 5):
				draw_circle(points[step], 1.9, Color(ClubInk.COPPER, 0.42))
			continue
		draw_polyline(points, Color(ClubInk.COPPER, 0.85), 1.8, true)
		draw_polyline(points, Color(ClubInk.BRASS, 0.35), 0.8, true)
