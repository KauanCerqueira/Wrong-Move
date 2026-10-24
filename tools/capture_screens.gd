extends SceneTree
## Visual QA sheet: renders every screen at the logical size so layout can be
## inspected as an image. Design tool only; it is not part of the game flow.
## godot --path . -s tools/capture_screens.gd -- --capture-dir=/tmp/ui --scale=1.0

var _dir := ""
var _scale := 1.0
var _app: Control

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--capture-dir="):
			_dir = arg.trim_prefix("--capture-dir=")
		elif arg.begins_with("--scale="):
			_scale = float(arg.trim_prefix("--scale="))
	if _dir.is_empty():
		printerr("missing --capture-dir")
		quit(1)
		return
	DirAccess.make_dir_recursive_absolute(_dir)
	# Watchdog: a failed await must never leave the editor-less process alive.
	create_timer(60.0).timeout.connect(func(): printerr("capture watchdog expired"); quit(1))
	var scene: PackedScene = load("res://scenes/app/app.tscn")
	_app = scene.instantiate()
	root.add_child(_app)
	root.size = Vector2i(360, 800)
	_app.session = load("res://scripts/application/game_session.gd").new("user://tests/ui_capture_" + str(Time.get_ticks_usec()))
	_app.view._settings["text_scale"] = _scale
	await process_frame
	await process_frame
	_app._home()
	await _shot("home")
	_app._command("campaign", {"mode": "normal"})
	await _shot("campaign")
	_app._command("play", {"index": "1"})
	for index in range(90):
		await process_frame
		if not _app._busy:
			break
	await _shot("table")
	for index in range(60):
		var ready: bool = _app.session.active() and int(_app.session.game().state.actor) == 0 and not _app.view._table.controls.fold.disabled
		if ready:
			break
		await process_frame
	if _app.session.active() and int(_app.session.game().state.actor) == 0 and not _app.view._table.controls.fold.disabled:
		_app.view._table.controls.fold.pressed.emit()
		await process_frame
		await process_frame
		if not _app._busy:
			await _shot("table-settled")
	_app.session.pause()
	_app.view.show_pause()
	await create_timer(0.3).timeout
	await _shot("pause")
	_app._command("home", {})
	_app.session = load("res://scripts/application/game_session.gd").new("user://tests/ui_capture_hc_" + str(Time.get_ticks_usec()))
	_app._home()
	_app._command("campaign", {"mode": "hardcore"})
	print("hardcore campaign shown")
	await _shot("campaign-hardcore")
	_app._command("play", {"index": "1"})
	for index in range(120):
		await process_frame
		if not _app._busy:
			break
	await _shot("table-hardcore")
	_app.view.show_tutorial(0)
	await create_timer(0.4).timeout
	await _shot("tutorial")
	_app.view.show_result({"won": true, "message": "Boa mão. A próxima mesa espera por você.", "reward": 250, "bonus": 250, "wallet": "500", "index": "1", "next_index": "2", "mode": "normal"})
	await _shot("result")
	_app.view.show_rules()
	await _shot("rules")
	_app.view.show_settings(_app._ui_preferences())
	await _shot("settings")
	_app.session.pause()
	await create_timer(0.3).timeout
	_app.queue_free()
	await process_frame
	quit()

func _shot(name: String) -> void:
	await create_timer(0.45).timeout
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(_dir.path_join(name + ".png"))
	print("captured ", name)
