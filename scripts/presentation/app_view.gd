class_name WrongMoveView
extends Control
## Presentation boundary. The controller owns persistence, money and game rules.
## Seat 0 is the local player. Table indices and wallets remain strings.
signal command(kind: String, payload: Dictionary)

const SafeArea = preload("res://scripts/presentation/safe_area.gd")
const TableView = preload("res://scripts/presentation/table_view.gd")
const MobileTheme = preload("res://assets/ui/mobile_theme.tres")
const CardView = preload("res://scripts/presentation/card_view.gd")
const Decimal = preload("res://scripts/domain/unsigned_decimal.gd")
const ClubInk = preload("res://scripts/presentation/club_skin.gd")
const Backdrop = preload("res://scripts/presentation/club_backdrop.gd")
const Ornament = preload("res://scripts/presentation/club_ornament.gd")
const HomeArt = preload("res://assets/art/home-card-fan.png")
const CampaignPath = preload("res://scripts/presentation/campaign_path.gd")
const Hero = preload("res://scripts/presentation/hero_plate.gd")
const Celebration = preload("res://scripts/presentation/celebration.gd")
const SwitchOn = preload("res://assets/ui/switch-on.svg")
const SwitchOff = preload("res://assets/ui/switch-off.svg")
var _page: VBoxContainer
var _table: VBoxContainer
var _dialog: AcceptDialog
var _settings: Dictionary = {}
var _campaign_mode := "normal"
var _map_navigation: HBoxContainer
var _map_previous: Button
var _map_start := "1"
var _map_detail: VBoxContainer
var _map_selected := ""
var _scroll: ScrollContainer
var _last_view: Dictionary = {}
var _celebration: Control

func _ready() -> void:
	_initialize()

func _initialize() -> void:
	if is_instance_valid(_page):
		return
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	theme = MobileTheme
	var background := Backdrop.new()
	add_child(background)
	var safe := SafeArea.new()
	safe.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(safe)
	_page = VBoxContainer.new()
	_page.add_theme_constant_override("separation", 8)
	safe.add_child(_page)

func _clear() -> void:
	_initialize()
	if is_instance_valid(_dialog):
		_dialog.hide()
		_dialog.queue_free()
		_dialog = null
	if is_instance_valid(_celebration):
		_celebration.queue_free()
		_celebration = null
	for child in _page.get_children():
		_page.remove_child(child)
		child.queue_free()
	_table = null
	_map_navigation = null
	_map_previous = null
	_map_detail = null
	_map_selected = ""
	_scroll = null

func _send(kind: String, payload: Dictionary = {}) -> void:
	command.emit(kind, payload)

## Sheet header: back mark, serif title, optional trailing widget and a hairline.
func _screen(title: String, back: bool = true, trailing: Callable = Callable()) -> VBoxContainer:
	_clear()
	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 6)
	_page.add_child(header)
	if back:
		var back_button := Button.new()
		back_button.text = "‹"
		ClubInk.button(back_button, "ghost", 22)
		back_button.custom_minimum_size = Vector2(44, 40)
		back_button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		back_button.tooltip_text = "Voltar"
		header.add_child(back_button)
		back_button.pressed.connect(func(): _send("back"))
	var heading := ClubInk.label(title, header, 22, ClubInk.PAPER, ClubInk.serif(600))
	heading.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	heading.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	heading.custom_minimum_size.x = 96
	if trailing.is_valid():
		trailing.call(header)
	var rule := Control.new()
	rule.custom_minimum_size.y = 1
	rule.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rule.draw.connect(func(): rule.draw_rect(Rect2(0, 0, rule.size.x, 1), Color(ClubInk.COPPER, 0.28)))
	_page.add_child(rule)
	_scroll = ScrollContainer.new()
	_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_page.add_child(_scroll)
	var content := VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 12)
	_scroll.add_child(content)
	_entrance()
	return content

func show_home(summary: Dictionary) -> void:
	_clear()
	var kicker := ClubInk.kicker("Texas Hold'em", _page, 11, ClubInk.COPPER)
	kicker.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var brand := ClubInk.label("WRONG\nMOVE", _page, 44, ClubInk.PAPER, ClubInk.serif(700, 3))
	brand.add_theme_constant_override("line_spacing", -18)
	brand.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var hero := Hero.new()
	hero.texture = HomeArt
	hero.size_flags_vertical = Control.SIZE_EXPAND_FILL
	hero.custom_minimum_size.y = 150
	_page.add_child(hero)
	_page.add_child(Ornament.new())
	var caption := ClubInk.label("Uma boa mão começa com uma decisão.", _page, 13, ClubInk.MUTED, ClubInk.sans(500, 0), true)
	caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	if summary.get("has_active", summary.get("has_save", false)):
		var resume_button := _button("Continuar torneio", _page, func(): _send("resume"))
		_button_style(resume_button, "green", 15)
	var normal := _button("Jogar Normal", _page, func(): _send("campaign", {"mode": "normal"}))
	_button_style(normal, "primary", 18)
	normal.custom_minimum_size.y = 56
	normal.text = "JOGAR NORMAL    →"
	var hardcore := _button("Hardcore", _page, func(): _send("campaign", {"mode": "hardcore"}))
	_button_style(hardcore, "danger", 13)
	hardcore.custom_minimum_size.y = 50
	hardcore.text = "HARDCORE   ·   CONTRA O RELÓGIO"
	var learn := _button("Aprender a jogar", _page, func(): _send("tutorial"))
	_button_style(learn, "ghost", 16)
	learn.custom_minimum_size.y = 48
	_ledger(summary)
	var footer := HBoxContainer.new()
	footer.add_theme_constant_override("separation", 6)
	_page.add_child(footer)
	var rules := _button("Regras", footer, show_rules)
	_button_style(rules, "ghost", 14)
	rules.custom_minimum_size.y = 44
	var settings := _button("Ajustes", footer, func(): _send("settings"))
	_button_style(settings, "ghost", 14)
	settings.custom_minimum_size.y = 44
	settings.tooltip_text = "Configurações de som, acessibilidade e texto"
	var note := ClubInk.kicker("Offline  ·  sem compras  ·  sem anúncios", _page, 9, Color(ClubInk.MUTED, 0.8))
	note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_entrance()

## Two campaigns, two private balances: shown as a printed ledger strip.
func _ledger(summary: Dictionary) -> void:
	if not summary.has("normal_wallet") and not summary.has("hardcore_wallet"):
		return
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", ClubInk.box(Color(ClubInk.INK, 0.45), Color(ClubInk.COPPER, 0.28), 6, 8))
	panel.custom_minimum_size.y = 44
	_page.add_child(panel)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	panel.add_child(row)
	for entry in [["NORMAL", "normal_wallet"], ["HARDCORE", "hardcore_wallet"]]:
		var column := VBoxContainer.new()
		column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		column.add_theme_constant_override("separation", 0)
		row.add_child(column)
		var caption := ClubInk.kicker(entry[0], column, 9, ClubInk.COPPER)
		caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		var balance := ClubInk.label(str(summary.get(entry[1], "0")), column, 16, ClubInk.PAPER, ClubInk.serif(600))
		balance.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		balance.tooltip_text = "Fichas de progressão desta campanha. Não é dinheiro real."
	var separator := Control.new()
	separator.custom_minimum_size.x = 1
	separator.draw.connect(func(): separator.draw_rect(Rect2(0, 6, 1, separator.size.y - 12), Color(ClubInk.COPPER, 0.3)))
	row.add_child(separator)
	row.move_child(separator, 1)

func show_campaign(mode: String, wallet: String, tables: Array, has_active: bool) -> void:
	_campaign_mode = mode
	var content := _screen("Seu caminho", true, func(header: HBoxContainer):
		var chip := PanelContainer.new()
		chip.add_theme_stylebox_override("panel", ClubInk.box(Color("3b1a1c") if mode == "hardcore" else Color("0e2a20"), Color("8a4a44") if mode == "hardcore" else Color(ClubInk.COPPER, 0.45), 9, 8))
		chip.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		header.add_child(chip)
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 6)
		chip.add_child(row)
		ClubInk.kicker("HC" if mode == "hardcore" else "Normal", row, 9, Color("e9a89b") if mode == "hardcore" else ClubInk.COPPER)
		var balance := ClubInk.label("◉ " + wallet, row, 15, ClubInk.PAPER, ClubInk.serif(600))
		balance.tooltip_text = "Fichas de progressão desta campanha. Não são dinheiro real.")
	if has_active:
		var resume_button := _button("Continuar torneio salvo", content, func(): _send("resume"))
		_button_style(resume_button, "green", 15)
		var abandon := _button("Abandonar torneio", content, _confirm_abandon)
		_button_style(abandon, "ghost", 13)
		abandon.custom_minimum_size.y = 40
	if tables.is_empty():
		_label("Nenhuma mesa nesta janela.", content)
		return
	var header := ClubInk.kicker("Mapa da campanha  ·  " + mode, content, 10, Color(ClubInk.COPPER, 0.85))
	header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var path := CampaignPath.new()
	content.add_child(path)
	path.selected.connect(func(entry: Dictionary): _show_campaign_detail(entry, has_active))
	var detail := PanelContainer.new()
	detail.add_theme_stylebox_override("panel", ClubInk.plaque(Color("0f2a21"), Color(ClubInk.COPPER, 0.5), 8, 10))
	_page.add_child(detail)
	_map_detail = VBoxContainer.new()
	_map_detail.add_theme_constant_override("separation", 4)
	detail.add_child(_map_detail)
	path.set_entries(tables, _text_scale())

func _show_campaign_detail(entry: Dictionary, has_active: bool) -> void:
	if not is_instance_valid(_map_detail):
		return
	var config: Dictionary = entry.get("config", entry)
	var index := str(entry.get("index", "1"))
	if index == _map_selected:
		return
	_map_selected = index
	for child: Node in _map_detail.get_children():
		_map_detail.remove_child(child)
		child.queue_free()
	var head := HBoxContainer.new()
	head.add_theme_constant_override("separation", 8)
	_map_detail.add_child(head)
	var title := ClubInk.label("Mesa " + index.pad_zeros(2), head, 19, ClubInk.PAPER, ClubInk.serif(700))
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.max_lines_visible = 1
	title.autowrap_mode = TextServer.AUTOWRAP_OFF
	title.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	title.custom_minimum_size.x = 92
	var state := "VENCIDA" if entry.get("won", false) else ("BLOQUEADA" if entry.get("locked", false) else ("LIBERADA" if entry.get("unlocked", false) else "A DESBLOQUEAR"))
	var tag := ClubInk.kicker(state, head, 9, ClubInk.COPPER if not entry.get("locked", false) else Color(ClubInk.MUTED, 0.75))
	tag.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	var participants := int(config.get("participants", 2))
	var specs := "%s lugares  ·  %s fichas  ·  blinds a cada %s mãos" % [participants, config.get("starting_stack", 1000), config.get("blind_frequency", "?")]
	ClubInk.label(specs, _map_detail, int(11 * _text_scale()), ClubInk.MUTED, null, true)
	var reward := str(config.get("base_reward", 0))
	ClubInk.label("Vitória +" + reward + "  ·  1ª vitória +" + str(config.get("first_win_bonus", 0)), _map_detail, int(11 * _text_scale()), ClubInk.COPPER, null, true)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	_map_detail.add_child(row)
	if entry.get("locked", false):
		var locked_button := _button("Vença a mesa anterior", row, func(): pass, true)
		_button_style(locked_button, "ghost", 13)
		locked_button.custom_minimum_size.y = 44
		locked_button.tooltip_text = "O caminho é linear. Volte à última mesa liberada."
	elif entry.get("unlocked", false):
		var play := _button("JOGAR  →  tentativa grátis", row, func(): _send("play", {"index": index}), has_active)
		_button_style(play, "primary", 15)
		play.custom_minimum_size.y = 46
	else:
		var cost: Variant = config.get("unlock_cost", 0)
		var buy := _button("Desbloquear · %s fichas" % cost, row, func(): _confirm_unlock(index, cost), has_active)
		_button_style(buy, "primary", 14)
		buy.custom_minimum_size.y = 46
	var note := "Compra única. Depois, jogar é grátis." if not entry.get("locked", false) else "Mesas anteriores continuam pagando fichas."
	ClubInk.label(note, _map_detail, int(10 * _text_scale()), Color(ClubInk.MUTED, 0.8), null, true)

## Two navigation buttons only; the controller supplies the next bounded window.
func show_map_navigation(start: String) -> void:
	_initialize()
	_map_start = start if Decimal.valid(start) and Decimal.compare(start, "1") >= 0 else "1"
	if not is_instance_valid(_map_navigation):
		_map_navigation = HBoxContainer.new()
		_map_navigation.add_theme_constant_override("separation", 6)
		_page.add_child(_map_navigation)
		_map_previous = _button("‹ Anteriores", _map_navigation, func():
			var previous := Decimal.subtract(_map_start, "10") if Decimal.compare(_map_start, "11") > 0 else "1"
			_send("map_page", {"start": previous}))
		_button_style(_map_previous, "ghost", 13)
		_map_previous.custom_minimum_size.y = 40
		var next := _button("Próximas  ›", _map_navigation, func(): _send("map_page", {"start": Decimal.add(_map_start, "10")}))
		_button_style(next, "ghost", 13)
		next.custom_minimum_size.y = 40
	_map_previous.disabled = _map_start == "1"

func show_table(view: Dictionary) -> void:
	_initialize()
	if not is_instance_valid(_table):
		_clear()
		_table = TableView.new()
		_page.add_child(_table)
		_table.command.connect(_table_command)
	_table.four_colors = bool(_settings.get("four_colors", false))
	_table.text_scale = _text_scale()
	_table.reduced_motion = bool(_settings.get("reduced_motion", false))
	_table.render(view)
	_last_view = view.duplicate()

## Uses the normal table commands; the controller advances the local lesson.
func show_tutorial_practice(view: Dictionary) -> void:
	var practice := view.duplicate()
	practice["mode"] = "tutorial"
	show_table(practice)

## Clock-only updates never rebuild controls, reset a wager or move keyboard focus.
func update_clock(clock: Dictionary) -> void:
	if is_instance_valid(_table):
		_table.update_clock(clock)

## Availability-only updates keep the existing table, slider and focus intact.
func update_hint_available(available: bool) -> void:
	if is_instance_valid(_table):
		_table.update_hint_available(available)

func _table_command(kind: String, payload: Dictionary) -> void:
	if kind == "confirm_hint":
		_confirm("Ver dica por %s fichas?" % payload.get("price", 0), "Ela ajuda a pensar, mas não garante vitória.", "Ver dica", func(): _send("hint"))
	elif kind == "pause":
		_send("pause")
		show_pause()
	elif kind == "rules":
		show_rules()
	elif kind == "seat_details":
		show_message("Participante", str(payload.get("body", "")))
	else:
		_send(kind, payload)

func show_pause() -> void:
	var content := _screen("Torneio pausado", false)
	if not _last_view.is_empty():
		var plate := PanelContainer.new()
		plate.add_theme_stylebox_override("panel", ClubInk.box(Color(ClubInk.INK, 0.4), Color(ClubInk.COPPER, 0.3), 6, 10))
		content.add_child(plate)
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 8)
		plate.add_child(row)
		var info := "Mesa %s  ·  blinds %s/%s  ·  mão %s" % [str(_last_view.get("table_index", "1")).pad_zeros(2), _last_view.get("small_blind", 0), _last_view.get("big_blind", 0), _last_view.get("hand_number", 1)]
		var caption := ClubInk.label(info, row, int(11 * _text_scale()), ClubInk.MUTED, null, true)
		caption.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var chips := ClubInk.label("◉ " + str(_last_view.get("player_stack", 0)), row, int(14 * _text_scale()), ClubInk.PAPER, ClubInk.serif(600))
		chips.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	ClubInk.label("Seu torneio pode continuar de onde parou. Nada foi perdido.", content, int(13 * _text_scale()), ClubInk.MUTED, null, true)
	var resume := _button("Continuar", content, func(): _send("resume"))
	_button_style(resume, "primary", 17)
	resume.custom_minimum_size.y = 52
	var review := _button("Rever a última mão", content, func(): _send("review"))
	_button_style(review, "green", 15)
	var rules := _button("Regras e ranking", content, show_rules)
	_button_style(rules, "ghost", 15)
	var leave := _button("Salvar e sair", content, func(): _send("home"))
	_button_style(leave, "ghost", 15)
	var abandon := _button("Abandonar torneio", content, _confirm_abandon)
	_button_style(abandon, "danger", 14)

func show_message(title: String, body: String) -> void:
	_initialize()
	_close_dialog()
	_dialog = AcceptDialog.new()
	_dialog.title = title
	_dialog.dialog_text = body
	_dialog.dialog_autowrap = true
	_dialog.ok_button_text = "Entendi"
	_dialog.min_size = Vector2i(260, 140)
	_dialog.get_ok_button().custom_minimum_size.y = 48
	add_child(_dialog)
	_dialog.popup_centered(Vector2i(int(minf(size.x - 24, 420)), 0))

func show_storage_error(reason: String) -> void:
	show_message("Não conseguimos salvar", "Sua última gravação está preservada. Libere espaço se necessário e tente novamente.\n" + reason)
	_dialog.ok_button_text = "Tentar novamente"
	_dialog.confirmed.connect(func(): _send("retry_save"), CONNECT_ONE_SHOT)

func show_rules() -> void:
	var content := _screen("Regras")
	ClubInk.label("A melhor combinação de cinco cartas vence. Use quantas cartas da sua mão quiser junto às cinco comunitárias. Se os outros desistirem, você leva o pote.", content, int(13 * _text_scale()), ClubInk.PAPER, null, true)
	_section("Ranking, do maior para o menor", content)
	var ranking := [
		["Straight flush", "cinco em sequência do mesmo naipe"],
		["Quadra", "quatro cartas de mesmo valor"],
		["Full house", "uma trinca e um par"],
		["Flush", "cinco do mesmo naipe"],
		["Sequência", "cinco valores seguidos"],
		["Trinca", "três cartas de mesmo valor"],
		["Dois pares", "dois pares distintos"],
		["Um par", "duas cartas de mesmo valor"],
		["Carta alta", "a maior carta decide"],
	]
	for index in range(ranking.size()):
		var line := HBoxContainer.new()
		line.add_theme_constant_override("separation", 8)
		content.add_child(line)
		var number := ClubInk.label(str(index + 1), line, 12, ClubInk.COPPER, ClubInk.serif(700))
		number.custom_minimum_size.x = 14
		var text := ClubInk.label("%s — %s" % [ranking[index][0], ranking[index][1]], line, int(12 * _text_scale()), ClubInk.PAPER, null, true)
		text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ClubInk.label("Royal flush é o straight flush mais alto. O ás pode ser baixo em A–2–3–4–5. Na mesma categoria, compare os valores e depois as cartas de desempate (kickers). Empates dividem o pote.", content, int(12 * _text_scale()), ClubInk.MUTED, null, true)
	_section("Vocabulário da mesa", content)
	for line in ["Mão: uma rodada completa, até entregar o pote.", "Pote (pot): fichas em disputa nesta mão.", "Suas fichas (stack): quanto você ainda pode apostar no torneio.", "Mesa (board): cartas comunitárias usadas por todos.", "Botão (D): marca a ordem de ação e muda entre mãos.", "Blinds: apostas obrigatórias, não uma taxa da campanha.", "Passar (check): continuar sem apostar quando não há valor para pagar.", "Pagar (call): acompanhar a aposta até o limite das suas fichas.", "Apostar (bet): abrir a aposta. Aumentar (raise): elevar o total da rodada.", "Desistir (fold): sair da mão sem recuperar as fichas apostadas.", "All-in: apostar todas as fichas. Você disputa somente os potes que cobriu.", "Showdown: comparar as melhores mãos de quem restou.", "Pote separado (side pot): disputa entre quem apostou além do valor coberto por outro participante."]:
		ClubInk.label(line, content, int(12 * _text_scale()), ClubInk.PAPER, null, true)

func show_settings(values: Dictionary) -> void:
	_settings = values.duplicate(true)
	var scale_value := float(values.get("text_scale", 1.0))
	if scale_value > 3:
		scale_value /= 100.0
	_initialize()
	theme = MobileTheme.duplicate(true)
	theme.default_font_size = int(18 * clampf(scale_value, 1.0, 1.5))
	var content := _screen("Configurações")
	_section("Som", content)
	for spec in [["music_volume", "Música", 0.35], ["sfx_volume", "Efeitos", 0.7]]:
		var label := ClubInk.label(spec[1], content, int(14 * _text_scale()))
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var slider := HSlider.new()
		slider.custom_minimum_size.y = 44
		slider.min_value = 0
		slider.max_value = 1
		slider.step = 0.05
		slider.value = float(values.get(spec[0], spec[2]))
		ClubInk.slider(slider)
		content.add_child(slider)
		var key := str(spec[0])
		slider.value_changed.connect(func(value: float): _send("set_setting", {"key": key, "value": value}))
	_section("Mesa", content)
	for spec in [["vibration", "Vibração"], ["four_colors", "Quatro cores de naipes"], ["reduced_motion", "Reduzir movimento"]]:
		var toggle := CheckButton.new()
		toggle.text = spec[1]
		toggle.custom_minimum_size.y = 48
		toggle.add_theme_font_override("font", ClubInk.sans(500))
		toggle.add_theme_font_size_override("font_size", int(14 * _text_scale()))
		toggle.add_theme_icon_override("checked", SwitchOn)
		toggle.add_theme_icon_override("unchecked", SwitchOff)
		toggle.button_pressed = bool(values.get(spec[0], false))
		content.add_child(toggle)
		var key := str(spec[0])
		toggle.toggled.connect(func(value: bool):
			_settings[key] = value
			_send("set_setting", {"key": key, "value": value}))
	_section("Tamanho do texto", content)
	var sizes := HBoxContainer.new()
	sizes.add_theme_constant_override("separation", 6)
	content.add_child(sizes)
	for value in [1.0, 1.25, 1.5]:
		var button := _button("%d%%" % int(value * 100), sizes, func():
			_settings["text_scale"] = value
			_send("set_setting", {"key": "text_scale", "value": value})
			show_settings(_settings))
		_button_style(button, "primary" if is_equal_approx(value, scale_value) else "ghost", 14)
		button.custom_minimum_size.y = 44
	_section("Sobre", content)
	ClubInk.label("Wrong Move · 0.1.0-dev", content, int(14 * _text_scale()), ClubInk.PAPER, ClubInk.serif(600))
	ClubInk.label("Pôquer offline com fichas fictícias. Sem compras ou anúncios. O progresso fica neste aparelho; desinstalar ou apagar os dados remove a gravação.\n\nFontes Noto Sans e Noto Serif (SIL OFL 1.1). Áudio original CC0. Engine Godot (MIT).\n\nBuild de desenvolvimento, ainda sem aceite de release.", content, int(11 * _text_scale()), ClubInk.MUTED, null, true)

func show_tutorial(step: int) -> void:
	var lesson := clampi(step, 0, 4)
	var titles := ["Suas cartas e a mesa", "Passar e pagar", "Apostar e aumentar", "Comparar e desistir", "Seu primeiro torneio"]
	var texts := ["Estas duas cartas são suas. As cinco da mesa são de todo mundo. Vale a melhor combinação de cinco cartas, usando quantas das suas você quiser.", "Sem aposta para acompanhar, você pode passar (check). Se alguém apostar, pagar (call) coloca as fichas necessárias para continuar.", "Você escolhe quanto arriscar. Aumentar para 60 significa deixar sua aposta desta rodada em 60, não adicionar 60. Se você já colocou 10, coloca mais 50.", "Se todo mundo desistir, o pote é seu. Quando mostram, a combinação e as cartas de desempate decidem.", "Todo mundo começa com as mesmas fichas. Quem fica com todas vence. Os blinds sobem e você pode fechar o jogo para continuar depois."]
	var content := _screen("Aprender · %d de 5" % (lesson + 1))
	var progress := HBoxContainer.new()
	progress.add_theme_constant_override("separation", 5)
	content.add_child(progress)
	for index in range(5):
		var dot := PanelContainer.new()
		dot.custom_minimum_size = Vector2(0, 4)
		dot.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		dot.add_theme_stylebox_override("panel", ClubInk.box(ClubInk.COPPER if index <= lesson else Color("2c4636"), Color(0, 0, 0, 0), 2, 0))
		progress.add_child(dot)
	ClubInk.label(titles[lesson], content, int(19 * _text_scale()), ClubInk.PAPER, ClubInk.serif(600))
	ClubInk.kicker("Treino · cartas de exemplo · sem custo ou prêmio", content, 9, ClubInk.COPPER)
	ClubInk.label(texts[lesson], content, int(13 * _text_scale()), ClubInk.PAPER, null, true)
	var examples := [[38, 24], [32, 45], [38, 24], [38, 23], [38, 25]]
	var boards := [[12, 31, 39, 20, 1], [37, 5, 13], [], [37, 24, 44, 5, 13], [12, 31, 39, 20, 1]]
	var explanations := ["Exemplo: contra Q♠ Q♣, seu par de ases vence o par de damas.", "Primeiro: passar com custo zero. Depois de uma aposta de 20: pagar 20 para continuar.", "Blinds 10/20, você já colocou 10. Aumentar para 60 significa colocar mais 50 nesta rodada.", "Uma trinca de reis vence dois pares. Sem par, a carta mais alta decide o desempate.", "Você começa com as mesmas fichas dos bots. Vencer significa ficar com todas."]
	_section("Suas cartas · toque para ampliar", content)
	var hand := HBoxContainer.new()
	hand.add_theme_constant_override("separation", 8)
	hand.alignment = BoxContainer.ALIGNMENT_CENTER
	content.add_child(hand)
	for id in examples[lesson]:
		var card := CardView.new()
		card.custom_minimum_size = Vector2(58, 82)
		hand.add_child(card)
		card.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		card.set_card(id, bool(_settings.get("four_colors", false)))
	_section("Cartas da mesa · comunitárias", content)
	var community := HBoxContainer.new()
	community.add_theme_constant_override("separation", 5)
	content.add_child(community)
	for i in range(5):
		var card := CardView.new()
		community.add_child(card)
		card.set_card(int(boards[lesson][i]) if i < boards[lesson].size() else -1, bool(_settings.get("four_colors", false)), i >= boards[lesson].size())
	ClubInk.label(explanations[lesson], content, int(12 * _text_scale()), ClubInk.COPPER, null, true)
	_section("Praticar", content)
	var practice := _button("Praticar esta lição", content, func(): _send("tutorial", {"step": lesson, "practice": true}))
	_button_style(practice, "primary", 16)
	practice.custom_minimum_size.y = 50
	var next := _button("Próxima lição" if lesson < 4 else "Ir para a campanha Normal", content, func():
		if lesson < 4:
			show_tutorial(lesson + 1)
		else:
			_send("campaign", {"mode": "normal"}))
	_button_style(next, "green", 15)
	var again := _button("Repetir lição", content, func(): show_tutorial(lesson))
	_button_style(again, "ghost", 14)
	var rules := _button("Regras e ranking", content, show_rules)
	_button_style(rules, "ghost", 14)
	var skip := _button("Pular tutorial", content, func(): _send("home"))
	_button_style(skip, "ghost", 13)

func show_result(result: Dictionary) -> void:
	var won: bool = result.get("won", result.get("victory", false))
	var content := _screen("Mesa vencida" if won else "Não foi dessa vez", false)
	if won and not bool(_settings.get("reduced_motion", false)):
		_celebration = Celebration.new()
		add_child(_celebration)
		# Behind the sheet, above the backdrop: the chips fall across the empty
		# felt instead of over the verdict text.
		move_child(_celebration, 1)
	var plate := PanelContainer.new()
	plate.add_theme_stylebox_override("panel", ClubInk.plaque(Color("123a2a") if won else Color("3a1b1d"), ClubInk.COPPER if won else Color("a5615c"), 8, 14))
	content.add_child(plate)
	var body := VBoxContainer.new()
	body.add_theme_constant_override("separation", 6)
	plate.add_child(body)
	var verdict := ClubInk.kicker("VITÓRIA" if won else "DERROTA", body, 11, ClubInk.COPPER if won else Color("e9a89b"))
	verdict.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var message := ClubInk.label(str(result.get("message", "Tentar de novo é grátis." if not won else "Boa mão. A próxima mesa espera por você.")), body, int(16 * _text_scale()), ClubInk.PAPER, ClubInk.serif(600), true)
	message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	for pot in result.get("pots", []):
		var line := ClubInk.label(str(pot), body, int(12 * _text_scale()), ClubInk.MUTED, null, true)
		line.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var ledger := VBoxContainer.new()
	ledger.add_theme_constant_override("separation", 3)
	content.add_child(ledger)
	_section("Balanço da mesa", ledger)
	for spec in [["Vitória", result.get("reward", result.get("base_reward", 0))], ["Primeira vitória", result.get("bonus", result.get("first_win_bonus", 0))], ["Seu saldo", result.get("wallet", "—")]]:
		var row := HBoxContainer.new()
		ledger.add_child(row)
		var caption := ClubInk.label(str(spec[0]), row, int(12 * _text_scale()), ClubInk.MUTED)
		caption.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		ClubInk.label(str(spec[1]), row, int(14 * _text_scale()), ClubInk.PAPER, ClubInk.serif(600))
	if result.has("next_index"):
		var next := _button("Próxima mesa  →", content, func(): _send("play", {"index": result.next_index}))
		_button_style(next, "primary", 16)
		next.custom_minimum_size.y = 52
	if result.has("table_index") or result.has("index"):
		var index: Variant = result.get("table_index", result.get("index", "1"))
		var again := _button("Jogar novamente", content, func(): _send("play", {"index": index}))
		_button_style(again, "primary" if not result.has("next_index") else "green", 15)
		again.custom_minimum_size.y = 48
	var map := _button("Mapa da campanha", content, func(): _send("campaign", {"mode": result.get("mode", _campaign_mode)}))
	_button_style(map, "ghost", 14)
	var home := _button("Início", content, func(): _send("home"))
	_button_style(home, "ghost", 14)

func _confirm_abandon() -> void:
	_confirm("Abandonar este torneio?", "Conta como derrota. A mesa continua liberada.", "Abandonar", func(): _send("abandon_confirmed"))

func _confirm_unlock(index: Variant, cost: Variant) -> void:
	_confirm("Desbloquear por %s fichas?" % cost, "O acesso é permanente. Jogar novamente é grátis.", "Desbloquear", func(): _send("unlock", {"index": index}))

func _close_dialog() -> void:
	if is_instance_valid(_dialog):
		_dialog.hide()
		_dialog.queue_free()
		_dialog = null

func _confirm(title: String, body: String, accept: String, callback: Callable) -> void:
	_initialize()
	_close_dialog()
	var confirmation := ConfirmationDialog.new()
	_dialog = confirmation
	confirmation.title = title
	confirmation.dialog_text = body
	confirmation.dialog_autowrap = true
	confirmation.ok_button_text = accept
	confirmation.cancel_button_text = "Continuar jogando" if accept == "Abandonar" else "Cancelar"
	confirmation.get_ok_button().custom_minimum_size.y = 48
	confirmation.get_cancel_button().custom_minimum_size.y = 48
	confirmation.confirmed.connect(callback, CONNECT_ONE_SHOT)
	add_child(confirmation)
	confirmation.popup_centered(Vector2i(int(minf(size.x - 24, 420)), 0))

## Section heading with a hairline tail; keeps long sheets scannable.
func _section(title: String, parent: Node) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	parent.add_child(row)
	var label := ClubInk.kicker(title, row, 10, ClubInk.COPPER)
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	var tail := Control.new()
	tail.custom_minimum_size.y = 1
	tail.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tail.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	tail.draw.connect(func(): tail.draw_rect(Rect2(0, 0, tail.size.x, 1), Color(ClubInk.COPPER, 0.25)))
	row.add_child(tail)

func _label(value: String, parent: Node, font_size: int = 0) -> Label:
	var label := Label.new()
	label.text = value
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_override("font", ClubInk.sans(500))
	if font_size > 0:
		label.add_theme_font_size_override("font_size", int(font_size * _text_scale()))
	parent.add_child(label)
	return label

func _button(value: String, parent: Node, callback: Callable, disabled: bool = false) -> Button:
	var button := Button.new()
	ClubInk.button(button, "secondary", int(16 * _text_scale()))
	button.text = value
	button.custom_minimum_size = Vector2(48, 50)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	button.disabled = disabled
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	parent.add_child(button)
	button.pressed.connect(callback)
	return button

func _button_style(button: Button, kind: String, font_size: int) -> void:
	ClubInk.button(button, kind, maxi(11, int(font_size * _text_scale())))

func _text_scale() -> float:
	return clampf(float(_settings.get("text_scale", 1.0)), 1.0, 1.5)

func _entrance() -> void:
	if bool(_settings.get("reduced_motion", false)):
		_page.modulate.a = 1.0
		return
	_page.modulate.a = 1.0
	var children := _page.get_children()
	for index in range(children.size()):
		var child := children[index] as Control
		if child == null:
			continue
		child.modulate.a = 0.0
		var tween := create_tween()
		tween.tween_interval(0.018 * float(index))
		tween.tween_property(child, "modulate:a", 1.0, 0.2).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
