class_name TutorialController
extends RefCounted

const Evaluator = preload("res://scripts/domain/hand_evaluator.gd")
var lesson: int = 0
var checkpoint: int = 0
var finished: bool = false
var message: String = ""

func start(step: int) -> void:
	lesson = clampi(step, 0, 4)
	checkpoint = 0
	finished = false
	message = ""

func act(kind: String, amount: int = 0) -> Dictionary:
	if finished:
		return {"ok": false, "error": "Lição concluída. Toque em Concluir lição."}
	var expected := "CHECK"
	match lesson:
		1: expected = "CHECK" if checkpoint == 0 else "CALL"
		2: expected = "RAISE_TO"
		4: expected = "CALL"
	if kind != expected or (lesson == 2 and amount != 60):
		return {"ok": false, "error": _instruction()}
	if lesson == 1 and checkpoint == 0:
		checkpoint = 1
		message = "O bot apostou20. Agora você pode pagar20 para continuar."
		return {"ok": true}
	finished = true
	message = ["Seu par de ases venceu o par de damas. Vale a melhor combinação de cinco cartas.",
		"Você passou quando era grátis e pagou quando houve aposta. São ações diferentes.",
		"Você já tinha colocado10. Para aumentar para60, colocou mais50.",
		"Ambos têm reis e setes. Seu ás de desempate venceu o valete. Se o bot desiste, você leva o pote sem ver as cartas dele.",
		"Você venceu o torneio de treino com trinca de ases. A vitória aqui não altera o saldo da campanha."][lesson]
	return {"ok": true}

func _instruction() -> String:
	return ["Toque em Passar para comparar as cartas de exemplo.",
		"Toque em Passar: não há aposta para pagar." if checkpoint == 0 else "Agora toque em Pagar20.",
		"Ajuste o total para60 e confirme Aumentar para60. Não custa fichas da campanha.",
		"Toque em Passar para ver o desempate.",
		"Pague as95 fichas restantes para acompanhar o all-in de treino."][lesson]

func player_view() -> Dictionary:
	var own: Array[int] = [38, 24]
	var other: Array[int] = [49, 10]
	var board: Array[int] = [12, 31, 39, 20, 1]
	if lesson == 1:
		own = [32, 45]
		board = [37, 5, 13]
		other = [38, 24]
	elif lesson == 3:
		own = [38, 23]
		other = [48, 8]
		board = [37, 24, 44, 5, 13]
	elif lesson == 4:
		own = [38, 25]
		other = [50, 11]
	var visible_board: Array[int] = board.duplicate() if lesson in [0, 1, 3] or finished else []
	var call_cost := 0
	if lesson == 1 and checkpoint > 0:
		call_cost = 20
	elif lesson == 4:
		call_cost = 95
	var combined: Array[int] = own.duplicate()
	combined.append_array(visible_board)
	var legal := {"check_allowed": call_cost == 0, "fold_allowed": false, "call_allowed": call_cost > 0,
		"raise_allowed": lesson == 2, "all_in_allowed": false, "to_call": call_cost, "min_raise_to": 40,
		"max_raise_to": 1000, "opening_bet": false, "street_contribution": 10 if lesson == 2 else 0}
	return {"mode": "tutorial", "table_index": "Treino " + str(lesson + 1), "hand_number": 1, "phase": "Treino: cartas de exemplo",
		"board": visible_board, "own_cards": own, "seats": [{"id": 0, "stack": 95 if lesson == 4 else 1000},
		{"id": 1, "stack": 0 if lesson == 4 else 1000, "all_in": lesson == 4, "hole_cards": other if finished or lesson in [0, 3] else []}],
		"actor": -1 if finished else 0, "pot": 105 if lesson == 4 else 40, "button": 0,
		"small_blind": 5 if lesson == 4 else 10, "big_blind": 10 if lesson == 4 else 20,
		"player_stack": 200 if finished and lesson == 4 else (95 if lesson == 4 else 1000),
		"current_combination": Evaluator.describe(combined), "legal_actions": legal, "hint_available": false,
		"result": {"summary": message} if finished else null, "instruction": message if not message.is_empty() else _instruction()}
