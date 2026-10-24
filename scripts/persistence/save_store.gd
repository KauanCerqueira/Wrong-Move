class_name SaveStore
extends RefCounted

const Codec = preload("res://scripts/persistence/save_codec.gd")
const Decimal = preload("res://scripts/domain/unsigned_decimal.gd")
const SLOT_NAMES := ["state_a.json", "state_b.json"]

var fail_at: String = ""
var _directory: String


func _init(directory: String = "user://save") -> void:
	_directory = directory


func load_state() -> Dictionary:
	var scan := _scan()
	if scan.future:
		return {"ok": false, "data": {}, "error": "future_schema", "recovered": false}
	if scan.best.is_empty():
		return {"ok": scan.existing == 0, "data": {}, "error": "no_valid_save" if scan.existing > 0 else "", "recovered": false}
	return {"ok": true, "data": scan.best.data.duplicate(true),
		"error": "recovered_previous_slot" if scan.invalid > 0 else "", "recovered": scan.invalid > 0}


func commit(data: Dictionary) -> Dictionary:
	var scan := _scan()
	if scan.future:
		return _failure("future_schema")
	if scan.existing > 0 and scan.best.is_empty():
		return _failure("no_valid_save")
	var errors := Codec.validate(data)
	if not errors.is_empty():
		return _failure("invalid_payload: " + "; ".join(errors))
	var revision: String = Decimal.add(scan.best.get("revision", "0"), "1")
	var inactive: int = 1 - int(scan.best.get("slot", 1))
	var payload_json := JSON.stringify(data, "", true, true)
	var envelope := {"schema_version": 1, "save_revision": revision,
		"payload_json": payload_json, "checksum": _checksum(1, revision, payload_json)}
	if fail_at == "before_write":
		return _failure("injected_before_write")
	var mkdir_error := DirAccess.make_dir_recursive_absolute(_directory)
	if mkdir_error != OK:
		return _failure("create_directory: " + error_string(mkdir_error))
	var target := _directory.path_join(SLOT_NAMES[inactive])
	var temporary := target + ".tmp"
	var file := FileAccess.open(temporary, FileAccess.WRITE)
	if file == null:
		return _failure("open_temporary: " + error_string(FileAccess.get_open_error()))
	file.store_string(JSON.stringify(envelope))
	file.flush()
	var write_error := file.get_error()
	file.close()
	if write_error != OK:
		return _failure("write_temporary: " + error_string(write_error))
	var verified := _read_slot(temporary)
	if not verified.ok or verified.get("revision", "") != revision or verified.get("payload_json", "") != payload_json:
		return _failure("verify_temporary")
	if fail_at == "before_rename":
		return _failure("injected_before_rename")
	# Same-filesystem replacement; never remove the destination before renaming.
	var rename_error := DirAccess.rename_absolute(temporary, target)
	if rename_error != OK:
		return _failure("rename: " + error_string(rename_error))
	if fail_at == "after_rename":
		# Simulates process death before feedback. A new reader sees this commit.
		return _failure("injected_after_rename")
	return {"ok": true, "error": ""}


func _scan() -> Dictionary:
	var result := {"future": false, "existing": 0, "invalid": 0, "best": {}}
	for index in SLOT_NAMES.size():
		var path := _directory.path_join(SLOT_NAMES[index])
		if not FileAccess.file_exists(path):
			continue
		result.existing += 1
		var slot := _read_slot(path)
		if slot.get("future", false):
			result.future = true
		if not slot.ok:
			result.invalid += 1
			continue
		if result.best.is_empty() or Decimal.compare(slot.revision, result.best.revision) > 0:
			slot.slot = index
			result.best = slot
	return result


func _read_slot(path: String) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return _failure("read")
	var raw := file.get_as_text()
	var read_error := file.get_error()
	file.close()
	if read_error != OK and read_error != ERR_FILE_EOF:
		return _failure("read")
	var parser := JSON.new()
	if parser.parse(raw) != OK or not parser.data is Dictionary:
		return _failure("json")
	var envelope: Dictionary = parser.data
	var schema: Variant = envelope.get("schema_version")
	if (schema is int or schema is float) and schema > 1:
		return {"ok": false, "error": "future_schema", "future": true}
	if not (schema is int or schema is float) or schema != 1:
		return _failure("schema")
	var revision: Variant = envelope.get("save_revision")
	var payload: Variant = envelope.get("payload_json")
	if not revision is String or not Decimal.valid(revision) or revision == "0" or not payload is String:
		return _failure("envelope")
	if envelope.get("checksum") != _checksum(1, revision, payload):
		return _failure("checksum")
	var payload_parser := JSON.new()
	if payload_parser.parse(payload) != OK or not payload_parser.data is Dictionary:
		return _failure("payload_json")
	var data: Dictionary = payload_parser.data
	if not Codec.validate(data).is_empty():
		return _failure("payload_invariants")
	return {"ok": true, "error": "", "revision": revision, "data": data, "payload_json": payload}


static func _checksum(schema: int, revision: String, payload_json: String) -> String:
	return (str(schema) + "\n" + revision + "\n" + payload_json).sha256_text()


static func _failure(reason: String) -> Dictionary:
	return {"ok": false, "error": reason}
