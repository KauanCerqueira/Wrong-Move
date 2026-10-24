class_name ChallengeGenerator
extends RefCounted

const Decimal = preload("res://scripts/domain/unsigned_decimal.gd")
static var _balance: Dictionary = {}
static var _blinds: Dictionary = {}


static func valid_index(index: String) -> bool:
	if index.is_empty() or index.begins_with("0"):
		return false
	for digit in index:
		if digit < "0" or digit > "9":
			return false
	return true


@warning_ignore("integer_division")
static func table_config(index: String, mode: String, seed_hex: String) -> Dictionary:
	if not valid_index(index) or mode not in ["normal", "hardcore"]:
		return {}
	if _balance.is_empty():
		_balance = JSON.parse_string(FileAccess.get_file_as_string("res://data/balance/campaign.json"))
		_blinds = JSON.parse_string(FileAccess.get_file_as_string("res://data/balance/blinds.json"))
	var tier := 5
	if Decimal.compare(index, "51") < 0:
		tier = Decimal.modulo_small(Decimal.divide_small(Decimal.subtract(index, "1"), 10), 6)
	var participants: int
	var reward: int
	var unlock_cost: int
	var hint_price: int
	if Decimal.compare(index, "6") <= 0:
		var slot: int = Decimal.modulo_small(index, 7) - 1
		participants = int(_balance.first_six_participants[slot])
		reward = int(_balance.first_six_base_rewards[slot])
		unlock_cost = int(_balance.first_six_unlock_prices[slot])
		hint_price = int(_balance.first_six_hint_prices[slot])
	else:
		var slot: int = Decimal.modulo_small(Decimal.subtract(index, "7"), 10)
		participants = int(_balance.later_participants_cycle[slot])
		reward = _base_reward(index)
		unlock_cost = 8 * _base_reward(Decimal.subtract(index, "1")) / 5
		hint_price = (reward + 9) / 10 + int(_balance.hint_tier_surcharge) * tier
	var styles: Array[String] = []
	for bot_seat in range(1, participants):
		var identity := "wm-v1|%s|%s|%s|%d" % [seed_hex, mode, index, bot_seat]
		var first_byte := identity.sha256_buffer()[0]
		styles.append(str(_balance.styles[first_byte % 3]))
	var strength_key := "normal_tier_strength" if mode == "normal" else "hardcore_tier_strength"
	var frequency_key := "hands_per_level_heads_up_by_tier" if participants == 2 else "hands_per_level_multiway_by_tier"
	var small_blinds: Array[int] = []
	for blind in _blinds.small_blinds:
		small_blinds.append(int(blind))
	return {
		"index": index, "mode": mode, "seed_hex": seed_hex,
		"generator_version": int(_balance.generator_version),
		"balance_version": int(_balance.balance_version),
		"participants": participants, "starting_stack": int(_balance.starting_stack),
		"base_reward": reward, "first_win_bonus": reward, "unlock_cost": unlock_cost,
		"hint_price": hint_price, "strength": int(_balance[strength_key][tier]),
		"styles": styles, "blind_frequency": int(_blinds[frequency_key][tier]),
		"small_blinds": small_blinds,
	}


static func _base_reward(index: String) -> int:
	if Decimal.compare(index, "36") >= 0:
		return int(_balance.base_reward_cap)
	# Only this bounded remainder becomes a native integer, never the index itself.
	return 250 + int(_balance.later_reward_step) * (Decimal.modulo_small(index, 36) - 6)
