class_name ClockStore
extends RefCounted

const Decimal = preload("res://scripts/domain/unsigned_decimal.gd")
var _directory: String

func _init(directory: String = "user://clock") -> void:
	_directory = directory

func latest() -> Dictionary:
	var best: Dictionary = {}
	for slot: String in ["a", "b"]:
		var path := _directory.path_join("clock_" + slot + ".json")
		if not FileAccess.file_exists(path):
			continue
		var envelope: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
		if not envelope is Dictionary or not envelope.get("payload") is String:
			continue
		if envelope.get("checksum", "") != str(envelope.payload).sha256_text():
			continue
		var data: Variant = JSON.parse_string(envelope.payload)
		if not data is Dictionary or not Decimal.valid(str(data.get("sequence", ""))):
			continue
		if best.is_empty() or Decimal.compare(str(data.sequence), str(best.sequence)) > 0:
			best = data
	return best

func commit(data: Dictionary) -> bool:
	if DirAccess.make_dir_recursive_absolute(_directory) != OK:
		return false
	var previous := latest()
	var candidate := data.duplicate(true)
	candidate.sequence = Decimal.add(str(previous.get("sequence", "0")), "1")
	var slot := "a" if Decimal.modulo_small(candidate.sequence, 2) == 1 else "b"
	var path := _directory.path_join("clock_" + slot + ".json")
	var payload := JSON.stringify(candidate, "", true, true)
	var file := FileAccess.open(path + ".tmp", FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify({"payload": payload, "checksum": payload.sha256_text()}))
	file.flush()
	var error := file.get_error()
	file.close()
	if error != OK:
		return false
	var check: Variant = JSON.parse_string(FileAccess.get_file_as_string(path + ".tmp"))
	if not check is Dictionary or check.get("payload", "") != payload:
		return false
	return DirAccess.rename_absolute(path + ".tmp", path) == OK
