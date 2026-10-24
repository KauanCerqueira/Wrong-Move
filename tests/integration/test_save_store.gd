extends RefCounted

const Store = preload("res://scripts/persistence/save_store.gd")
const Codec = preload("res://scripts/persistence/save_codec.gd")
const Preferences = preload("res://scripts/persistence/preferences_store.gd")
const Campaign = preload("res://scripts/campaign/campaign_state.gd")
const Tournament = preload("res://scripts/domain/tournament.gd")

var _root: String
var _failures: Array[String] = []


func run() -> Array[String]:
	_failures = []
	_root = "user://persistence_test_" + str(Time.get_unix_time_from_system()).replace(".", "_") + "_" + str(Time.get_ticks_usec())
	var data := _payload("10")
	var store := Store.new(_root.path_join("basic"))
	_check(store.load_state().ok and store.load_state().data.is_empty(), "fresh store")
	_check(store.commit(data).ok, "initial commit")
	_check(Store.new(_root.path_join("basic")).load_state().data == JSON.parse_string(JSON.stringify(data)), "restart round trip")
	_check(store.commit(_payload("20")).ok, "second slot")
	_check(store.commit(_payload("30")).ok, "atomic replacement of existing slot")
	_check(store.load_state().data.normal.wallet == "30", "latest valid revision")
	var copy: Dictionary = store.load_state().data
	copy.normal.wallet = "999"
	_check(store.load_state().data.normal.wallet == "30", "snapshot isolation")
	for boundary in ["before_write", "before_rename", "after_rename"]:
		var directory := _root.path_join(boundary)
		var fault := Store.new(directory)
		_check(fault.commit(data).ok and fault.commit(_payload("20")).ok, boundary + " setup")
		fault.fail_at = boundary
		_check(not fault.commit(_payload("30")).ok, boundary + " injected failure")
		var loaded: Dictionary = Store.new(directory).load_state()
		_check(loaded.ok and not loaded.recovered, boundary + " loads committed state")
		_check(loaded.data.normal.wallet == ("30" if boundary == "after_rename" else "20"), boundary + " durable commit point")
		fault.fail_at = ""
		_check(fault.commit(_payload("40")).ok and fault.load_state().data.normal.wallet == "40", boundary + " retry")
	var corrupt_dir := _root.path_join("corrupt")
	var corrupt := Store.new(corrupt_dir)
	_check(corrupt.commit(data).ok and corrupt.commit(_payload("20")).ok, "corruption setup")
	var envelope := _read(corrupt_dir.path_join("state_b.json"))
	envelope.payload_json = str(envelope.payload_json).replace('"20"', '"99"')
	_write(corrupt_dir.path_join("state_b.json"), envelope)
	var recovered: Dictionary = corrupt.load_state()
	_check(recovered.ok and recovered.recovered and recovered.data.normal.wallet == "10", "checksum tamper recovers previous slot")
	_check(not recovered.error.is_empty(), "recovery warning")
	_check(corrupt.commit(_payload("30")).ok, "repair corrupt inactive slot by commit")
	for slot in ["state_a.json", "state_b.json"]:
		_write(corrupt_dir.path_join(slot), {"broken": true})
	_check(not corrupt.load_state().ok and not corrupt.commit(data).ok, "both invalid refuse overwrite")
	_check(_read(corrupt_dir.path_join("state_a.json")) == {"broken": true}, "invalid data preserved")
	var tmp_dir := _root.path_join("temporary_only")
	DirAccess.make_dir_recursive_absolute(tmp_dir)
	_write(tmp_dir.path_join("state_a.json.tmp"), _read(_root.path_join("basic/state_a.json")))
	_check(Store.new(tmp_dir).load_state().data.is_empty(), "temporary never accepted")
	var future_dir := _root.path_join("future")
	var future := Store.new(future_dir)
	_check(future.commit(data).ok, "future setup")
	var future_envelope := {"schema_version": 2, "payload_json": "future bytes"}
	_write(future_dir.path_join("state_b.json"), future_envelope)
	_check(not future.load_state().ok and future.load_state().error == "future_schema", "future schema blocks fallback")
	var future_bytes := FileAccess.get_file_as_string(future_dir.path_join("state_b.json"))
	_check(not future.commit(data).ok and FileAccess.get_file_as_string(future_dir.path_join("state_b.json")) == future_bytes, "future schema preserved")
	var huge_dir := _root.path_join("huge_revision")
	var huge := Store.new(huge_dir)
	_check(huge.commit(data).ok, "huge setup")
	var large := _read(huge_dir.path_join("state_a.json"))
	large.save_revision = "9".repeat(100)
	large.checksum = ("1\n" + large.save_revision + "\n" + large.payload_json).sha256_text()
	_write(huge_dir.path_join("state_a.json"), large)
	_check(huge.commit(_payload("9".repeat(100))).ok, "arbitrary precision commit")
	_check(_read(huge_dir.path_join("state_b.json")).save_revision == "1" + "0".repeat(100), "arbitrary precision increment")
	_check(huge.load_state().data.normal.wallet == "9".repeat(100), "revision compared without numeric conversion")
	var tournament := Tournament.new()
	tournament.start(6, 42)
	var game_data := _payload("0")
	game_data.normal.active_attempt = {"attempt_id": "normal:1", "game": tournament.snapshot()}
	game_data.normal.next_attempt_counter = "2"
	var game_store := Store.new(_root.path_join("game"))
	var game_commit := game_store.commit(game_data)
	_check(game_commit.ok, "live six seat game commits: " + game_commit.error)
	var restored := Tournament.new()
	if game_store.load_state().ok and not game_store.load_state().data.is_empty():
		restored.restore(game_store.load_state().data.normal.active_attempt.game)
	_check(restored.snapshot() == tournament.snapshot(), "game deck and RNG round trip")
	_validation_checks()
	_preferences_checks()
	# Test fixtures intentionally remain in their unique directory for inspection.
	return _failures


func _validation_checks() -> void:
	for wallet in ["-1", "01", "", 10, 1.5]:
		var data := _payload("0")
		data.normal.wallet = wallet
		_check(not Codec.validate(data).is_empty(), "reject malformed wallet " + str(wallet))
	_check(not Codec.validate({}).is_empty(), "both campaigns required")
	var timed := _payload("0")
	timed.hardcore.active_attempt = {"attempt_id": "hardcore:1", "clock": {"decision_remaining_ms": 10001, "reserve_remaining_ms": 30000}}
	timed.hardcore.next_attempt_counter = "2"
	_check(not Codec.validate(timed).is_empty(), "reject renewed clock")
	timed.hardcore.active_attempt.clock.decision_remaining_ms = 0
	_check(Codec.validate(timed).is_empty(), "zero decision balance valid")
	var bad_deck := _payload("0")
	bad_deck.normal["game"] = {"deck": {"cards": [1, 1], "cursor": 53}}
	_check(not Codec.validate(bad_deck).is_empty(), "reject invalid deck")
	var tournament := Tournament.new()
	tournament.start(2, 42)
	var corrupt_game := _payload("0")
	corrupt_game.games = {"normal": tournament.snapshot()}
	corrupt_game.games.normal.seats[1].hole_cards[0] = corrupt_game.games.normal.seats[0].hole_cards[0]
	_check(not Codec.validate(corrupt_game).is_empty(), "reject repeated card across seats")
	corrupt_game.games.normal = tournament.snapshot()
	corrupt_game.games.normal.seats[0].stack += 1
	_check(not Codec.validate(corrupt_game).is_empty(), "reject broken chip conservation")
	corrupt_game.games.normal = tournament.snapshot()
	corrupt_game.mode = "unknown"
	_check(not Codec.validate(corrupt_game).is_empty(), "reject unknown selected campaign")
	var revision_dir := _root.path_join("revision_tamper")
	var revision_store := Store.new(revision_dir)
	_check(revision_store.commit(_payload("0")).ok, "revision tamper setup")
	var envelope := _read(revision_dir.path_join("state_a.json"))
	envelope.save_revision = "999"
	_write(revision_dir.path_join("state_a.json"), envelope)
	_check(not revision_store.load_state().ok, "revision authenticated by checksum")
	var invariant_dir := _root.path_join("invalid_invariants")
	var invariant_store := Store.new(invariant_dir)
	_check(invariant_store.commit(_payload("0")).ok, "invariant tamper setup")
	envelope = _read(invariant_dir.path_join("state_a.json"))
	var invalid := _payload("-1")
	envelope.payload_json = JSON.stringify(invalid)
	envelope.checksum = ("1\n" + envelope.save_revision + "\n" + envelope.payload_json).sha256_text()
	_write(invariant_dir.path_join("state_a.json"), envelope)
	_check(not invariant_store.load_state().ok, "valid checksum still requires valid payload")


func _preferences_checks() -> void:
	var path := _root.path_join("preferences.cfg")
	var preferences := Preferences.new(path)
	preferences.load_preferences()
	_check(preferences.values == Preferences.DEFAULTS, "release defaults")
	_check(preferences.set_value("music", 0.5) == OK, "preferences persist")
	var loaded := Preferences.new(path)
	loaded.load_preferences()
	_check(loaded.values.music == 0.5 and loaded.values.vibration == false, "preferences restart")
	_check(loaded.set_value("sfx", 2.0) == ERR_INVALID_PARAMETER and loaded.set_value("vibration", 1) == ERR_INVALID_PARAMETER, "preferences validate ranges and types")
	var snapshot := loaded.snapshot()
	snapshot.music = 1.0
	_check(loaded.values.music == 0.5, "preferences snapshot isolation")
	var blocked := Preferences.new(_root.path_join("missing_parent"))
	_check(blocked.set_value("unknown", true) == ERR_INVALID_PARAMETER, "unknown preference refused")


func _payload(wallet: String) -> Dictionary:
	var normal := Campaign.fresh()
	normal.wallet = wallet
	var hardcore := Campaign.fresh()
	hardcore.mode = "hardcore"
	return {"normal": normal, "hardcore": hardcore, "domain_revision": "0"}


func _read(path: String) -> Dictionary:
	return JSON.parse_string(FileAccess.get_file_as_string(path))


func _write(path: String, data: Dictionary) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(JSON.stringify(data))
	file.close()


func _check(condition: bool, label: String) -> void:
	if not condition:
		_failures.append("save_store: " + label)
