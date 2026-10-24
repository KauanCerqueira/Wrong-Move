class_name HintAdvisor
extends RefCounted

const Basic = preload("res://scripts/ai/basic_agent.gd")
const DISCLAIMER := " É uma estimativa, não uma garantia."

static func recommend(observation: Dictionary) -> Dictionary:
	var rng := RandomNumberGenerator.new()
	rng.seed = 51005
	var result := Basic.choose_policy(observation, rng, 5, "equilibrado", false)
	var explanation := ""
	match result.kind:
		"CHECK": explanation = "Você pode ver como a rodada segue sem colocar mais fichas agora."
		"CALL": explanation = "O valor para acompanhar parece razoável para a força estimada da sua mão."
		"BET_TO", "RAISE_TO", "ALL_IN": explanation = "Sua mão parece forte para pressionar. O valor sugerido ainda arrisca suas fichas."
		"FOLD": explanation = "A aposta parece cara para a força estimada desta mão."
		_: explanation = "Não foi possível calcular uma recomendação para esta decisão."
	result["raise_to"] = int(result.get("raise_to", 0))
	result["explanation"] = explanation + DISCLAIMER
	return result
