class_name StrategicAgent
extends RefCounted

const Basic = preload("res://scripts/ai/basic_agent.gd")

static func choose_action(observation: Dictionary, rng: RandomNumberGenerator, strength: int = 0, style: String = "equilibrado") -> Dictionary:
	return Basic.choose_action(observation, rng, strength, style)
