extends SceneTree
## Original deterministic synthesis for Wrong Move. Run from the project root:
## godot --headless --path . --script tools/generate_audio.gd -- --ffmpeg /path/to/ffmpeg
## After importing assets: same command with -- --verify (no encoder needed).

const RATE := 44100
const AUDIO_DIR := "res://assets/audio"
const EFFECTS := {"card": 0.16, "check": 0.12, "call": 0.22, "raise": 0.30,
	"fold": 0.20, "pot": 0.38, "victory": 0.48, "alert": 0.32}
const CHORDS := [[110.0, 130.0, 164.0, 220.0], [88.0, 110.0, 130.0, 174.0],
	[98.0, 122.0, 146.0, 196.0], [82.0, 110.0, 124.0, 164.0]]
var _rng := RandomNumberGenerator.new()


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var arguments := OS.get_cmdline_user_args()
	if "--verify" in arguments:
		await _verify()
		return
	_rng.seed = 7202026
	if DirAccess.make_dir_recursive_absolute(AUDIO_DIR) != OK:
		_fail("Could not create audio directory.")
		return
	for effect in EFFECTS:
		if _write_effect(effect, EFFECTS[effect]) != OK:
			_fail("Could not write effect: " + effect)
			return
	var temporary := AUDIO_DIR + "/ambient.source.wav"
	var music := AudioStreamWAV.new()
	music.mix_rate = RATE
	music.stereo = true
	music.format = AudioStreamWAV.FORMAT_16_BITS
	music.data = _ambient_pcm()
	if music.save_to_wav(temporary) != OK:
		_fail("Could not write ambient source.")
		return
	var encoder := "ffmpeg"
	var encoder_index := arguments.find("--ffmpeg")
	if encoder_index >= 0 and encoder_index + 1 < arguments.size():
		encoder = arguments[encoder_index + 1]
	var output: Array = []
	var result := OS.execute(encoder, PackedStringArray(["-hide_banner", "-loglevel", "error",
		"-y", "-i", ProjectSettings.globalize_path(temporary), "-map_metadata", "-1",
		"-c:a", "libvorbis", "-q:a", "2", "-ar", str(RATE), "-ac", "2",
		ProjectSettings.globalize_path(AUDIO_DIR + "/ambient.ogg")]), output, true)
	if result != 0:
		_fail("Vorbis encoding failed; source retained. Pass --ffmpeg PATH. " + str(output))
		return
	DirAccess.remove_absolute(temporary)
	print("Generated eight original mono WAV effects and one original 60 s stereo OGG loop.")
	quit()


func _write_effect(effect: String, duration: float) -> Error:
	var count := int(round(duration * RATE))
	var pcm := PackedByteArray()
	pcm.resize(count * 2)
	var filtered_noise := 0.0
	for index in count:
		var t := float(index) / RATE
		var noise := _rng.randf_range(-1.0, 1.0)
		filtered_noise = lerpf(filtered_noise, noise, 0.16)
		var sample := 0.0
		match effect:
			"card":
				sample = (noise - filtered_noise) * 0.25 * sin(PI * t / duration) * exp(-t * 19.0)
			"check":
				sample = _ping(t, 740.0, 0.12, 0.0) * 0.34
			"call":
				sample = (_ping(t, 880.0, 0.13, 0.0) + _ping(t, 1174.66, 0.14, 0.07)) * 0.26
			"raise":
				sample = (_ping(t, 659.25, 0.15, 0.0) + _ping(t, 880.0, 0.16, 0.07)
					+ _ping(t, 1318.51, 0.16, 0.14)) * 0.24
			"fold":
				sample = filtered_noise * 0.7 * sin(PI * t / duration) * exp(-t * 14.0)
			"pot":
				for hit in 5:
					sample += _ping(t, 950.0 + hit * 137.0, 0.17, hit * 0.045) * 0.15
			"victory":
				for note in 4:
					var frequency: float = [523.25, 659.25, 783.99, 1046.5][note]
					sample += _ping(t, frequency, 0.26, note * 0.07) * 0.22
			"alert":
				sample = (_ping(t, 554.37, 0.13, 0.0) + _ping(t, 554.37, 0.14, 0.17)) * 0.30
		# A final 5 ms taper guarantees silence at either end, avoiding clicks.
		var edge := minf(1.0, minf(t / 0.003, (duration - t) / 0.005))
		pcm.encode_s16(index * 2, int(clampf(sample * edge, -0.95, 0.95) * 32767.0))
	var stream := AudioStreamWAV.new()
	stream.mix_rate = RATE
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.stereo = false
	stream.data = pcm
	return stream.save_to_wav(AUDIO_DIR + "/" + effect + ".wav")


func _ping(t: float, frequency: float, duration: float, offset: float) -> float:
	var local := t - offset
	if local < 0.0 or local >= duration:
		return 0.0
	var envelope := sin(PI * local / duration) * exp(-local * 15.0)
	return envelope * (sin(TAU * frequency * local) + 0.18 * sin(TAU * frequency * 2.76 * local))


func _ambient_pcm() -> PackedByteArray:
	var pcm := PackedByteArray()
	pcm.resize(RATE * 60 * 4)
	for index in RATE * 60:
		var t := float(index) / RATE
		var position := t / 15.0
		var chord := int(position) % 4
		# Cosine interpolation wraps the fourth chord into the first. Oscillator
		# frequencies and modulation complete integer cycles over sixty seconds.
		var blend := (1.0 - cos(PI * fposmod(position, 1.0))) * 0.5
		var left := 0.0
		var right := 0.0
		for tone in 4:
			var current: float = CHORDS[chord][tone]
			var following: float = CHORDS[(chord + 1) % 4][tone]
			var pan := 0.15 + tone * 0.23
			var wave := lerpf(_pad(t, current, tone), _pad(t, following, tone), blend)
			left += wave * sqrt(1.0 - pan) * 0.055
			right += wave * sqrt(pan) * 0.055
		var breath := 0.84 + 0.16 * cos(TAU * t / 20.0)
		pcm.encode_s16(index * 4, int(left * breath * 32767.0))
		pcm.encode_s16(index * 4 + 2, int(right * breath * 32767.0))
	return pcm


func _pad(t: float, frequency: float, tone: int) -> float:
	var phase := float(tone) * 0.43
	return (sin(TAU * frequency * t + phase)
		+ 0.20 * sin(TAU * frequency * 2.0 * t + phase)) * (0.93 + 0.07 * cos(TAU * t / 30.0 + phase))


func _verify() -> void:
	for effect in EFFECTS:
		var path: String = AUDIO_DIR + "/" + effect + ".wav"
		var wav := AudioStreamWAV.load_from_file(path)
		if wav == null or wav.stereo or wav.mix_rate != RATE or wav.get_length() > 0.5:
			_fail("Invalid WAV: " + path)
			return
		var peak := 0
		for index in wav.data.size() / 2:
			peak = maxi(peak, absi(wav.data.decode_s16(index * 2)))
		if peak == 0 or peak >= 32767:
			_fail("Silent or clipped WAV: " + path)
			return
		print("PASS %s: mono %d Hz, %.3f s, peak %.3f" % [effect, wav.mix_rate, wav.get_length(), peak / 32767.0])
	var ambient := AudioStreamOggVorbis.load_from_file(AUDIO_DIR + "/ambient.ogg")
	if ambient == null or absf(ambient.get_length() - 60.0) > 0.01:
		_fail("Ambient OGG must be 60 seconds.")
		return
	print("PASS ambient: %.3f s" % ambient.get_length())
	var feedback_script := load("res://scripts/presentation/feedback.gd") as GDScript
	if feedback_script == null or not feedback_script.can_instantiate():
		_fail("GameFeedback could not be compiled.")
		return
	var feedback = feedback_script.new()
	feedback.apply_preferences({"music": 0.0, "sfx": 0.0, "vibration": false})
	root.add_child(feedback)
	await process_frame
	if feedback._music.playing or feedback._voices.size() != 6:
		_fail("Preferences before ready or voice pool failed.")
		return
	feedback.apply_preferences({"music": 0.35, "sfx": 0.70})
	if not feedback._music.playing or not feedback._music.stream.loop:
		_fail("Music did not start or loop.")
		return
	for effect in EFFECTS:
		if feedback._effects.get(effect) == null:
			_fail("Effect failed to load in GameFeedback: " + effect)
			return
		feedback.play(effect)
	if not feedback._voices[0].playing:
		_fail("Effect playback did not start.")
		return
	for index in 64:
		feedback.play("card")
	if feedback.get_child_count() != 7:
		_fail("Effect overlap must use a bounded pool.")
		return
	feedback.play("unknown")
	feedback.apply_preferences({"music": -1.0, "sfx": 2.0, "vibration": true})
	if feedback._music.playing or feedback._sfx_volume != 1.0 or not feedback._vibration:
		_fail("Preference clamp or vibration state failed.")
		return
	feedback.apply_preferences({"music": NAN, "sfx": "invalid", "vibration": false})
	if feedback._music_volume != 0.0 or feedback._sfx_volume != 1.0:
		_fail("Invalid preferences did not preserve previous values.")
		return
	feedback.apply_preferences({"sfx": 0.0})
	for voice in feedback._voices:
		if voice.playing:
			_fail("Muting must stop active effects.")
			return
	feedback.queue_free()
	await process_frame
	var defaults = feedback_script.new()
	root.add_child(defaults)
	await process_frame
	if not defaults._music.playing or defaults._vibration or defaults._sfx_volume != 0.70:
		_fail("Default startup preferences failed.")
		return
	defaults.apply_preferences({"music": 0.0, "sfx": 0.0})
	defaults.queue_free()
	# Let the audio mixer retire stopped playbacks before headless shutdown.
	await create_timer(0.15).timeout
	print("PASS GameFeedback: startup, looping, eight effects, bounded voices, mute, preferences, invalid inputs.")
	quit()


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
