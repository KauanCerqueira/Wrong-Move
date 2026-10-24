class_name GameFeedback
extends Node
## Main owns action wiring. Apply saved preferences before add_child() to avoid
## briefly playing music at the defaults. No timers or waits in the action path.

const EFFECT_NAMES := ["card", "check", "call", "raise", "fold", "pot", "victory", "alert"]
const MUSIC_PATH := "res://assets/audio/ambient.ogg"
const VOICE_COUNT := 6
const MUSIC_GAIN := 0.32
const SFX_GAIN := 0.65

var _music_volume: float = 0.35
var _sfx_volume: float = 0.70
var _vibration: bool = false
var _music: AudioStreamPlayer
var _voices: Array[AudioStreamPlayer] = []
var _effects: Dictionary = {}
var _next_voice: int = 0
var _last_vibration_ms: int = -1000


func _ready() -> void:
	_music = AudioStreamPlayer.new()
	_music.name = "AmbientMusic"
	var ambient := load(MUSIC_PATH) as AudioStreamOggVorbis
	if ambient != null:
		ambient.loop = true
		_music.stream = ambient
	add_child(_music)
	for effect in EFFECT_NAMES:
		_effects[effect] = load("res://assets/audio/%s.wav" % effect) as AudioStreamWAV
	for index in VOICE_COUNT:
		var voice := AudioStreamPlayer.new()
		voice.name = "EffectVoice%d" % index
		add_child(voice)
		_voices.append(voice)
	_update_volumes()


func apply_preferences(values: Dictionary) -> void:
	_music_volume = _volume(values.get("music", _music_volume), _music_volume)
	_sfx_volume = _volume(values.get("sfx", _sfx_volume), _sfx_volume)
	if values.get("vibration") is bool:
		_vibration = values["vibration"]
	_update_volumes()


func stop_all() -> void:
	if is_instance_valid(_music):
		_music.stop()
		_music.stream = null
	for voice in _voices:
		voice.stop()
		voice.stream = null


func _exit_tree() -> void:
	stop_all()


func play(effect: String) -> void:
	if not _effects.has(effect):
		return
	if _vibration and OS.has_feature("android"):
		var now := Time.get_ticks_msec()
		if now - _last_vibration_ms >= 80:
			Input.vibrate_handheld(35 if effect in ["victory", "alert"] else 15)
			_last_vibration_ms = now
	if _sfx_volume <= 0.0 or _effects[effect] == null or _voices.is_empty():
		return
	# Prefer an idle voice; bounded voice stealing prevents an unbounded node pool.
	var voice := _voices[_next_voice]
	for candidate in _voices:
		if not candidate.playing:
			voice = candidate
			break
	voice.stop()
	voice.stream = _effects[effect]
	voice.play()
	_next_voice = (_voices.find(voice) + 1) % _voices.size()


func _update_volumes() -> void:
	if not is_instance_valid(_music):
		return
	_music.volume_linear = _music_volume * MUSIC_GAIN
	if _music_volume <= 0.0:
		_music.stop()
	elif _music.stream != null and not _music.playing:
		_music.play()
	for voice in _voices:
		voice.volume_linear = _sfx_volume * SFX_GAIN
		if _sfx_volume <= 0.0:
			voice.stop()


func _volume(value: Variant, fallback: float) -> float:
	if (value is float or value is int) and is_finite(float(value)):
		return clampf(float(value), 0.0, 1.0)
	return fallback
