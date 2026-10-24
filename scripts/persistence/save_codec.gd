class_name SaveCodec
extends RefCounted

const Decimal = preload("res://scripts/domain/unsigned_decimal.gd")
const GameState = preload("res://scripts/domain/game_state.gd")

## Validate the aggregate while allowing additional game/version metadata.
static func validate(data: Dictionary) -> Array[String]:
	var errors: Array[String] = []
	if data.has("mode") and data.mode not in ["normal", "hardcore"]:
		errors.append("invalid selected mode")
	if data.has("games"):
		if not data.games is Dictionary:
			errors.append("invalid games aggregate")
		else:
			for mode: Variant in data.games:
				if mode not in ["normal", "hardcore"] or not data.games[mode] is Dictionary:
					errors.append("invalid game entry")
				elif not GameState.valid_snapshot(data.games[mode]):
					errors.append(str(mode) + ": invalid tournament snapshot")
	if data.has("tutorial_progress"):
		var progress: Variant = data.tutorial_progress
		if not progress is Dictionary or not _integer(progress.get("last_step")) or progress.last_step < 0 or progress.last_step > 4 or not progress.get("completed") is Dictionary:
			errors.append("invalid tutorial progress")
	var campaigns: Dictionary = data.get("campaigns", data) if data.get("campaigns", data) is Dictionary else {}
	for mode in ["normal", "hardcore"]:
		if not campaigns.get(mode) is Dictionary:
			errors.append(mode + ": missing campaign")
			continue
		var campaign: Dictionary = campaigns[mode]
		if campaign.get("mode", mode) != mode:
			errors.append(mode + ": incorrect mode")
		if not campaign.get("wallet") is String or not Decimal.valid(campaign.get("wallet", "")):
			errors.append(mode + ": invalid wallet")
		for field in ["next_attempt_counter", "frontier"]:
			if campaign.has(field) and (not campaign[field] is String or not Decimal.valid(campaign[field]) or campaign[field] == "0"):
				errors.append(mode + ": invalid " + field)
		for field in ["unlocked", "completed", "receipts", "active_attempt"]:
			if campaign.has(field) and not campaign[field] is Dictionary:
				errors.append(mode + ": invalid " + field)
		var attempt: Variant = campaign.get("active_attempt", {})
		if attempt is Dictionary and not attempt.is_empty():
			var identifier: Variant = attempt.get("attempt_id", attempt.get("id", ""))
			if not identifier is String or not identifier.begins_with(mode + ":"):
				errors.append(mode + ": invalid attempt id")
			else:
				var counter: String = identifier.substr(mode.length() + 1)
				if not Decimal.valid(counter) or counter == "0":
					errors.append(mode + ": invalid attempt counter")
				elif campaign.get("next_attempt_counter") is String and Decimal.compare(counter, campaign.next_attempt_counter) >= 0:
					errors.append(mode + ": attempt counter not advanced")
	_walk(data, "payload", errors)
	return errors


static func _walk(value: Variant, path: String, errors: Array[String]) -> void:
	if value is Dictionary:
		for key in value:
			var key_name := str(key)
			if not (key is String or key is StringName or key is int):
				errors.append(path + ": JSON keys must be strings")
				continue
			if key is int and value.has(str(key)):
				errors.append(path + ": colliding JSON keys")
			var item: Variant = value[key]
			if key_name == "game" and item is Dictionary and not GameState.valid_snapshot(item):
				errors.append(path + ": invalid tournament snapshot")
			if key_name in ["domain_revision", "save_revision", "next_attempt_counter"]:
				if not item is String or not Decimal.valid(item):
					errors.append(path + "." + key + ": invalid decimal")
			if key_name in ["stack", "street_contribution", "hand_contribution", "decision_remaining_ms", "reserve_remaining_ms", "cursor"]:
				if not (item is int or item is float) or not is_finite(float(item)) or float(item) < 0 or floor(float(item)) != float(item):
					errors.append(path + "." + key + ": invalid nonnegative integer")
				elif key_name == "decision_remaining_ms" and item > 10000 or key_name == "reserve_remaining_ms" and item > 30000:
					errors.append(path + "." + key + ": clock exceeds budget")
			if key_name in ["cards", "deck_order", "board", "hole_cards", "burns"] and item is Array:
				var seen := {}
				for card in item:
					if not _integer(card) or card < 0 or card > 51 or seen.has(card):
						errors.append(path + "." + str(key) + ": invalid or repeated card")
					seen[card] = true
			if key_name == "deck" and item is Dictionary:
				if not item.get("cards") is Array or item.cards.size() != 52 or not _integer(item.get("cursor")) or item.cursor < 0 or item.cursor > 52:
					errors.append(path + ": invalid deck")
			_walk(item, path + "." + str(key), errors)
	elif value is Array:
		for index in value.size():
			_walk(value[index], path + "[" + str(index) + "]", errors)
	elif value is float:
		if not is_finite(value) or (floor(value) == value and abs(value) > 9007199254740991.0):
			errors.append(path + ": unsafe JSON number")
	elif value is int:
		if value > 9007199254740991 or value < -9007199254740991:
			errors.append(path + ": use decimal string for large integers")
	elif not (value == null or value is String or value is StringName or value is bool):
		errors.append(path + ": unsupported JSON type")


static func _integer(value: Variant) -> bool:
	return (value is int or value is float) and is_finite(float(value)) and floor(float(value)) == float(value)
