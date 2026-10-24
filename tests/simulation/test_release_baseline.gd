extends RefCounted

const Generator = preload("res://scripts/campaign/challenge_generator.gd")
const Campaign = preload("res://scripts/campaign/campaign_service.gd")
const Preferences = preload("res://scripts/persistence/preferences_store.gd")
const Agent = preload("res://scripts/ai/basic_agent.gd")
const Clock = preload("res://scripts/application/hardcore_clock.gd")
const Decimal = preload("res://scripts/domain/unsigned_decimal.gd")

func run() -> Array[String]:
	var errors: Array[String] = []
	var baseline: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://specs/001-mobile-poker/release-baseline.json"))
	var seed := "00112233445566778899aabbccddeeff"
	for offset in range(6):
		var table := Generator.table_config(str(offset + 1), "normal", seed)
		if table.participants != baseline.play.first_six_participants[offset] or table.base_reward != baseline.economy.first_six_base_rewards[offset] or table.unlock_cost != baseline.economy.first_six_unlock_prices[offset] or table.hint_price != baseline.economy.first_six_hint_prices[offset]:
			errors.append("first-six runtime/baseline mismatch at " + str(offset + 1))
		if table.starting_stack != baseline.play.starting_stack or table.balance_version != baseline.release.balance_version or table.generator_version != baseline.release.generator_version:
			errors.append("runtime version/stack differs from baseline")
	for level in range(9):
		if Agent.SAMPLES[level] != baseline.bots.equity_samples_by_strength[level] or not is_equal_approx(Agent.NOISE[level], baseline.bots.decision_noise_by_strength[level]):
			errors.append("agent runtime/baseline mismatch at strength " + str(level))
	if Clock.DECISION_MS != baseline.play.hardcore_decision_ms or Clock.RESERVE_MS != baseline.play.hardcore_reserve_ms or Clock.MAX_DURABLE_WINDOW_MS != baseline.play.max_clock_loss_on_abrupt_kill_ms:
		errors.append("clock runtime/baseline mismatch")
	for key: String in ["music", "sfx", "vibration", "text_scale", "reduced_motion"]:
		if Preferences.DEFAULTS[key] != baseline.defaults[key]:
			errors.append("preference runtime/baseline mismatch: " + key)
	if Preferences.DEFAULTS.four_color != baseline.defaults.four_color_suits:
		errors.append("suit default differs from baseline")
	var huge := "9".repeat(100)
	var table := Generator.table_config(huge, "hardcore", seed)
	if table.index != huge or table.base_reward != baseline.economy.base_reward_cap or table.strength != baseline.bots.hardcore_tier_strength[-1]:
		errors.append("100-digit runtime/baseline mismatch")
	if Decimal.add(huge, "1") != "1" + "0".repeat(100):
		errors.append("100-digit carry mismatch")
	# Purchased configurations must survive a later in-memory balance update.
	var campaign := Campaign.new("normal", seed)
	var purchased: Dictionary = campaign.config("1")
	var original := Generator._balance.duplicate(true)
	Generator._balance.first_six_base_rewards[0] += 17
	if campaign.config("1") != purchased:
		errors.append("purchased config changed with balance")
	Generator._balance = original
	return errors
