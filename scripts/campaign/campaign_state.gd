class_name CampaignState
extends RefCounted

const Generator = preload("res://scripts/campaign/challenge_generator.gd")
const DEFAULT_SEED := "00112233445566778899aabbccddeeff"


static func fresh(seed_hex: String = DEFAULT_SEED) -> Dictionary:
	return {
		"mode": "normal", "seed_hex": seed_hex, "wallet": "0",
		"unlocked": {"1": Generator.table_config("1", "normal", seed_hex)},
		"completed": {}, "active_attempt": {}, "next_attempt_counter": "1",
		"receipts": {"unlocks": {"1": {"ok": true, "error": "", "index": "1", "cost": 0}},
			"finish": {}, "hints": {}},
	}
