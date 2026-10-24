extends Control
## Short, skippable chip shower for a won table. Frees itself; never blocks input.
const ClubInk = preload("res://scripts/presentation/club_skin.gd")
const DURATION := 1.8
const FADE_FROM := 1.15
var _chips: Array[Dictionary] = []
var _time := 0.0
var _spawned := false

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func _process(delta: float) -> void:
	if not _spawned:
		_spawn()
		_spawned = true
	_time += delta
	for chip: Dictionary in _chips:
		chip.delay = maxf(0.0, float(chip.delay) - delta)
		if float(chip.delay) > 0.0:
			continue
		chip.pos += Vector2(chip.vel) * delta
		chip.vel = Vector2(chip.vel) + Vector2(0, 900.0) * delta
		chip.angle = float(chip.angle) + float(chip.spin) * delta
	modulate.a = clampf(1.0 - (_time - FADE_FROM) / (DURATION - FADE_FROM), 0.0, 1.0)
	queue_redraw()
	if _time >= DURATION:
		queue_free()

func _spawn() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 7331
	var faces := [ClubInk.RED, ClubInk.FELT, ClubInk.COPPER, Color("1c3f31")]
	for index in range(16):
		_chips.append({
			"pos": Vector2(rng.randf_range(size.x * 0.1, size.x * 0.9), rng.randf_range(size.y * 0.46, size.y * 0.6)),
			"vel": Vector2(rng.randf_range(-20, 20), rng.randf_range(40, 120)),
			"spin": rng.randf_range(-7.0, 7.0),
			"angle": rng.randf_range(0.0, TAU),
			"radius": rng.randf_range(7.5, 11.5),
			"face": faces[index % faces.size()],
			"delay": rng.randf_range(0.0, 0.35),
		})

func _draw() -> void:
	for chip: Dictionary in _chips:
		if float(chip.delay) > 0.0:
			continue
		draw_set_transform(chip.pos, float(chip.angle), Vector2(1.0, 0.78))
		ClubInk.chip(self, Vector2.ZERO, float(chip.radius), chip.face)
		draw_set_transform(Vector2.ZERO, 0, Vector2.ONE)
