class_name PreferencesStore
extends RefCounted

const DEFAULTS := {"music": 0.35, "sfx": 0.70, "vibration": false,
	"text_scale": 1.0, "four_color": false, "reduced_motion": false}

var values: Dictionary = DEFAULTS.duplicate(true)
var _path: String


func _init(path: String = "user://preferences.cfg") -> void:
	_path = path


func load_preferences() -> void:
	values = DEFAULTS.duplicate(true)
	var config := ConfigFile.new()
	if config.load(_path) != OK:
		return
	for key in DEFAULTS:
		var value: Variant = config.get_value("preferences", key, DEFAULTS[key])
		if _valid(key, value):
			values[key] = value


func set_value(key: String, value: Variant) -> Error:
	if not _valid(key, value):
		return ERR_INVALID_PARAMETER
	var candidate := values.duplicate(true)
	candidate[key] = value
	var config := ConfigFile.new()
	for setting in DEFAULTS:
		config.set_value("preferences", setting, candidate[setting])
	var directory_error := DirAccess.make_dir_recursive_absolute(_path.get_base_dir())
	if directory_error != OK:
		return directory_error
	var save_error := config.save(_path)
	if save_error == OK:
		values = candidate
	return save_error


func snapshot() -> Dictionary:
	return values.duplicate(true)


static func _valid(key: String, value: Variant) -> bool:
	if not DEFAULTS.has(key):
		return false
	if DEFAULTS[key] is bool:
		return value is bool
	if not (value is int or value is float) or not is_finite(float(value)):
		return false
	if key == "text_scale":
		return value >= 0.75 and value <= 2.0
	return value >= 0.0 and value <= 1.0
