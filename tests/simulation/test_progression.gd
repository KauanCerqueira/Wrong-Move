extends RefCounted

const Generator = preload("res://scripts/campaign/challenge_generator.gd")
const Decimal = preload("res://scripts/domain/unsigned_decimal.gd")
const SEED := "00112233445566778899aabbccddeeff"


func run() -> Array[String]:
	var failures: Array[String] = []
	var participants := [2, 2, 3, 2, 4, 3]
	var rewards := [100, 120, 145, 175, 210, 250]
	var passes := [0, 120, 150, 180, 220, 265]
	var hints := [10, 12, 15, 18, 21, 25]
	for i in range(6):
		var table := Generator.table_config(str(i + 1), "normal", SEED)
		_check(table.participants == participants[i] and table.base_reward == rewards[i]
			and table.first_win_bonus == rewards[i] and table.unlock_cost == passes[i]
			and table.hint_price == hints[i], "initial fixture %d" % (i + 1), failures)
	var index := "1"
	var cycle := [2, 3, 2, 4, 3, 5, 2, 4, 5, 6]
	for stage in range(1, 10001):
		var normal := Generator.table_config(index, "normal", SEED)
		var hardcore := Generator.table_config(index, "hardcore", SEED)
		var next := Generator.table_config(Decimal.add(index, "1"), "normal", SEED)
		_check(normal == Generator.table_config(index, "normal", SEED), "determinism " + index, failures)
		_check(normal.index == index and normal.starting_stack == 1000
			and normal.participants >= 2 and normal.participants <= 6
			and normal.styles.size() == normal.participants - 1,
			"valid configuration " + index, failures)
		_check(normal.base_reward + normal.first_win_bonus >= next.unlock_cost,
			"first win affords next pass " + index, failures)
		_check(normal.strength <= 5 and hardcore.strength == normal.strength + 3
			and normal.base_reward <= 1000 and normal.unlock_cost <= 1600
			and normal.hint_price <= 150 and normal.blind_frequency >= 3,
			"bounded difficulty/economy " + index, failures)
		_check(normal.base_reward == hardcore.base_reward and normal.unlock_cost == hardcore.unlock_cost,
			"mode economy parity " + index, failures)
		var expected_tier: int = mini(5, int((stage - 1) / 10))
		var frequencies: Array = [4, 4, 4, 3, 3, 3] if normal.participants == 2 else [6, 6, 5, 5, 4, 4]
		_check(normal.strength == expected_tier and normal.blind_frequency == frequencies[expected_tier]
			and hardcore.blind_frequency == normal.blind_frequency
			and normal.small_blinds == [10, 15, 25, 40, 60, 100, 150, 250, 400, 600, 1000, 1500, 3000],
			"exact tier and blind structure " + index, failures)
		if stage >= 7:
			_check(normal.participants == cycle[(stage - 7) % 10], "participant cycle " + index, failures)
		for seat in range(1, normal.participants):
			var identity := "wm-v1|%s|normal|%s|%d" % [SEED, index, seat]
			var expected: String = ["cauteloso", "equilibrado", "agressivo"][identity.sha256_buffer()[0] % 3]
			_check(normal.styles[seat - 1] == expected, "style hash " + index, failures)
		index = Decimal.add(index, "1")
	for boundary in ["7", "36", "37", "51"]:
		var table := Generator.table_config(boundary, "normal", SEED)
		if boundary == "7":
			_check(table.base_reward == 275 and table.unlock_cost == 400 and table.hint_price == 28,
				"stage 7 boundary", failures)
		if boundary == "36":
			_check(table.base_reward == 1000 and table.unlock_cost == 1560, "stage 36 boundary", failures)
		if boundary == "37":
			_check(table.unlock_cost == 1600, "stage 37 pass cap", failures)
		if boundary == "51":
			_check(table.hint_price == 150 and table.strength == 5, "stage 51 tier cap", failures)
	for huge in ["1" + "0".repeat(99), "9".repeat(100)]:
		var table := Generator.table_config(huge, "normal", SEED)
		var cycle_slot: int = Decimal.modulo_small(Decimal.subtract(huge, "7"), 10)
		_check(table.index == huge and table.base_reward == 1000 and table.unlock_cost == 1600
			and table.hint_price == 150 and table.participants == cycle[cycle_slot],
			"100 digit configuration " + huge, failures)
		_check(table == Generator.table_config(huge, "normal", SEED), "100 digit determinism", failures)
		var hard := Generator.table_config(huge, "hardcore", SEED)
		_check(table.strength == 5 and hard.strength == 8
			and hard.participants == table.participants, "100 digit mode parity", failures)
	for invalid in ["", "0", "01", "-1", "1.0", "1e3", " 1"]:
		_check(Generator.table_config(invalid, "normal", SEED).is_empty(), "invalid index " + invalid, failures)
	return failures


func _check(condition: bool, label: String, failures: Array[String]) -> void:
	if not condition:
		failures.append("progression: " + label)
