extends Control
## The felt. Owns the rail, seats, pot, board and the player's cards.
## No rules, no money decisions: it renders a view and nothing else.
signal seat_selected(body: String)
const ClubInk = preload("res://scripts/presentation/club_skin.gd")
const CardView = preload("res://scripts/presentation/card_view.gd")
const Seat = preload("res://scripts/presentation/seat_badge.gd")
const Chips = preload("res://scripts/presentation/chip_stack.gd")
const STREETS := {"preflop": "PRÉ-FLOP", "flop": "FLOP", "turn": "TURN", "river": "RIVER", "settled": "RESULTADO"}
var bots: Array[Button] = []
var board_cards: Array[Button] = []
var own_cards: Array[Button] = []
var pot_label: Label
var street_label: Label
var _pot_caption: Label
var _chips: Control
var _opponents: Array = []
var _text_scale := 1.0
var _street := ""
var _reduced_motion := false
var _shown_pot := 0.0
var _pot_tween: Tween
var _pending_board: Array[int] = []
var _pending_hand: Array[int] = []

func _ready() -> void:
	custom_minimum_size.y = 300
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	mouse_filter = Control.MOUSE_FILTER_PASS
	for index in range(5):
		var bot := Seat.new()
		add_child(bot)
		bots.append(bot)
		bot.pressed.connect(func(): seat_selected.emit(bot.tooltip_text))
	street_label = ClubInk.kicker("", self, 9, ClubInk.INK)
	street_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	for index in range(5):
		var card := CardView.new()
		card.draggable = true
		add_child(card)
		board_cards.append(card)
	_pot_caption = ClubInk.kicker("Pote", self, 9, Color(ClubInk.COPPER, 0.85))
	_pot_caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pot_label = ClubInk.label("0", self, 30, ClubInk.PAPER, ClubInk.serif(700))
	pot_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_chips = Chips.new()
	add_child(_chips)
	for index in range(2):
		var card := CardView.new()
		card.draggable = true
		add_child(card)
		own_cards.append(card)
	resized.connect(_layout)
	_layout()

func render(view: Dictionary, four_colors: bool, scale_value: float, reduced_motion: bool) -> void:
	_text_scale = scale_value
	_reduced_motion = reduced_motion
	_opponents = []
	for seat: Dictionary in view.get("seats", []):
		if int(seat.get("id", 0)) != 0:
			_opponents.append(seat)
	for index in range(5):
		bots[index].visible = index < _opponents.size()
		if index < _opponents.size():
			var seat: Dictionary = _opponents[index]
			bots[index].reduced_motion = reduced_motion
			bots[index].configure(seat, int(view.get("actor", -1)) == int(seat.id), int(view.get("button", -1)) == int(seat.id), scale_value, _opponents.size() > 2)
	var board: Array = view.get("board", [])
	var fresh_board: Array[int] = []
	for index in range(5):
		var value := int(board[index]) if index < board.size() else -1
		if value >= 0 and value != int(board_cards[index].card_id):
			fresh_board.append(index)
		board_cards[index].reduced_motion = reduced_motion
		board_cards[index].set_card(value, four_colors, index >= board.size())
	var hand: Array = view.get("own_cards", [])
	var fresh_hand: Array[int] = []
	for index in range(2):
		var value := int(hand[index]) if index < hand.size() else -1
		if value >= 0 and value != int(own_cards[index].card_id):
			fresh_hand.append(index)
		own_cards[index].reduced_motion = reduced_motion
		own_cards[index].set_card(value, four_colors)
	_set_pot(int(view.get("pot", 0)))
	_street = STREETS.get(str(view.get("phase", "")), "")
	street_label.text = _street
	street_label.visible = false
	_layout()
	_deal_fresh_cards(fresh_board, fresh_hand)

func _layout() -> void:
	if bots.is_empty() or size.x <= 0 or size.y <= 0:
		return
	var felt := _felt_rect()
	var count := _opponents.size()
	var seat_width := minf(112.0, size.x / 2.9)
	var seat_height := 82.0 + 20.0 * (_text_scale - 1.0)
	for index in range(bots.size()):
		var x := 0.5
		var y := felt.position.y + 2.0
		if count <= 1:
			x = 0.5
		elif count == 2:
			x = 0.32 if index == 0 else 0.68
		elif count == 3:
			x = [0.20, 0.5, 0.80][index]
		elif index < 3:
			x = [0.20, 0.5, 0.80][index]
		else:
			x = 0.02 if index == 3 else 0.98
			y = felt.position.y + felt.size.y * 0.30
		var left := clampf(size.x * x - seat_width * 0.5, -6.0, size.x - seat_width + 6.0)
		bots[index].position = Vector2(left, y)
		bots[index].size = Vector2(seat_width, seat_height)
	var card_width := minf(58.0, (felt.size.x - 40.0) / 5.0 - 6.0)
	var card_height := card_width * 1.42
	var gap := 6.0
	var row_width := card_width * 5.0 + gap * 4.0
	var board_y := felt.position.y + felt.size.y * 0.50
	for index in range(5):
		board_cards[index].set_slot(Vector2((size.x - row_width) * 0.5 + index * (card_width + gap), board_y))
		board_cards[index].size = Vector2(card_width, card_height)
	var pot_y := felt.position.y + felt.size.y * 0.325
	_pot_caption.position = Vector2(0, pot_y)
	_pot_caption.size = Vector2(size.x, 13)
	pot_label.position = Vector2(0, pot_y + 11)
	pot_label.size = Vector2(size.x, 34)
	_chips.position = Vector2(size.x * 0.5 - 31, pot_y + 44)
	_chips.size = Vector2(62, 24)
	_chips.visible = felt.size.y > 300
	var hand_width := minf(72.0, felt.size.x * 0.225)
	var hand_height := hand_width * 1.4
	var hand_y := size.y - hand_height - 12.0
	var overlap := hand_width * 0.16
	var total := hand_width * 2.0 - overlap
	var hand_left := (size.x - total) * 0.5
	for index in range(2):
		own_cards[index].pivot_offset = Vector2(hand_width, hand_height) * 0.5
		own_cards[index].set_slot(Vector2(hand_left + index * (hand_width - overlap), hand_y + index * 2.0))
		own_cards[index].size = Vector2(hand_width, hand_height)
		own_cards[index].z_index = index
		own_cards[index].set_rest_rotation(deg_to_rad(-3.0 + index * 5.0))
	_flush_deal()
	queue_redraw()

func _felt_rect() -> Rect2:
	return Rect2(Vector2(0, 4), Vector2(size.x, maxf(180, size.y - 8)))

func _draw() -> void:
	var felt := _felt_rect()
	var radius := minf(felt.size.x * 0.5 - 1.0, felt.size.y * 0.5 - 1.0)
	var shadow := ClubInk.box(ClubInk.FELT_DEEP, Color(0, 0, 0, 0), int(radius), 0)
	shadow.draw_center = false
	shadow.shadow_color = Color(0.004, 0.02, 0.014, 0.55)
	shadow.shadow_size = 10
	shadow.shadow_offset = Vector2(0, 5)
	draw_style_box(shadow, felt)
	draw_style_box(ClubInk.box(Color("123c2e"), Color(0, 0, 0, 0), int(radius), 0), felt)
	# Soft pool of light: many low-alpha ovals instead of a few hard bands.
	for step in range(7):
		var t := float(step) / 6.0
		var pool := felt.grow(-8.0 - t * minf(felt.size.x, felt.size.y) * 0.34)
		if pool.size.x <= 6 or pool.size.y <= 6:
			break
		draw_style_box(ClubInk.box(Color(0.10, 0.29, 0.21, 0.06), Color(0, 0, 0, 0), int(_radius_of(pool)), 0), pool)
	draw_polyline(_outline(felt.grow(-1.5), radius - 1.5), Color(0.62, 0.55, 0.39, 0.75), 1.4, true)
	if street_label.visible:
		draw_style_box(ClubInk.box(ClubInk.COPPER, Color(0, 0, 0, 0), 9, 0), Rect2(street_label.position, street_label.size))

static func _radius_of(rect: Rect2) -> float:
	return minf(rect.size.x * 0.5 - 1.0, rect.size.y * 0.5 - 1.0)

## Cards enter from the dealer's spot on the rail, so a new street reads as
## something happening at the table instead of a redraw. The first render can
## happen before the container gives the stage its size, so the deal is held
## until a layout has run.
func _deal_fresh_cards(fresh_board: Array[int], fresh_hand: Array[int]) -> void:
	if not is_inside_tree() or _reduced_motion:
		return
	_pending_board = fresh_board
	_pending_hand = fresh_hand
	_flush_deal()

func _flush_deal() -> void:
	if _pending_board.is_empty() and _pending_hand.is_empty():
		return
	if size.x < 10 or size.y < 10:
		return
	var origin := Vector2(size.x * 0.5 - 20, 30)
	var order := 0
	for index: int in _pending_hand:
		own_cards[index].play_deal(origin, 0.04 * order)
		order += 1
	for index: int in _pending_board:
		board_cards[index].play_deal(origin, 0.06 * order)
		order += 1
	_pending_hand.clear()
	_pending_board.clear()

func _set_pot(value: int) -> void:
	_chips.amount = value
	if _reduced_motion or not is_inside_tree():
		_shown_pot = float(value)
		pot_label.text = str(value)
		return
	if is_equal_approx(_shown_pot, float(value)):
		return
	if _pot_tween != null:
		_pot_tween.kill()
	_pot_tween = create_tween()
	_pot_tween.tween_method(_on_pot_step, _shown_pot, float(value), 0.32).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	if value > int(_shown_pot):
		pot_label.pivot_offset = pot_label.size * 0.5
		var pop := create_tween()
		pop.tween_property(pot_label, "scale", Vector2(1.07, 1.07), 0.1)
		pop.tween_property(pot_label, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)

func _on_pot_step(shown: float) -> void:
	_shown_pot = shown
	pot_label.text = str(int(round(shown)))

func _outline(rect: Rect2, radius: float) -> PackedVector2Array:
	var r := minf(radius, minf(rect.size.x, rect.size.y) * 0.5)
	var points := PackedVector2Array()
	points.append(Vector2(rect.position.x + r, rect.position.y))
	points.append(Vector2(rect.end.x - r, rect.position.y))
	var corners := [
		{"center": Vector2(rect.end.x - r, rect.position.y + r), "from": -PI * 0.5},
		{"center": Vector2(rect.end.x - r, rect.end.y - r), "from": 0.0},
		{"center": Vector2(rect.position.x + r, rect.end.y - r), "from": PI * 0.5},
		{"center": Vector2(rect.position.x + r, rect.position.y + r), "from": PI},
	]
	for corner: Dictionary in corners:
		for step in range(1, 9):
			var angle: float = float(corner.from) + PI * 0.5 * float(step) / 8.0
			points.append(corner.center + Vector2.from_angle(angle) * r)
		points.append(corner.center + Vector2.from_angle(float(corner.from) + PI * 0.5) * r)
	points.append(points[0])
	return points
