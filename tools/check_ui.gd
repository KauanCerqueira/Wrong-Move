extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var controller: Script = load("res://scripts/application/app.gd")
	if controller == null or not controller.can_instantiate():
		printerr("App controller could not compile")
		quit(1)
		return
	var scene: PackedScene = load("res://scenes/app/app.tscn")
	var app: Control = scene.instantiate()
	root.add_child(app)
	app.session = load("res://scripts/application/game_session.gd").new("user://tests/ui_" + str(Time.get_ticks_usec()))
	app._home()
	root.size = Vector2i(360, 800)
	await process_frame
	await process_frame
	var capture := ""
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--capture-dir="):
			capture = arg.trim_prefix("--capture-dir=")
	if not capture.is_empty():
		DirAccess.make_dir_recursive_absolute(capture)
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(capture.path_join("home.png"))
	app._command("campaign", {"mode": "normal"})
	await process_frame
	app._command("play", {"index": "1"})
	for index in range(60):
		await process_frame
		if not app._busy:
			break
	if app.session.active() and int(app.session.game().state.actor) == 0:
		var revision: int = app.session.game().state.revision
		app.view._table.controls.call_button.pressed.emit()
		await process_frame
		if int(app.session.game().state.revision) <= revision:
			printerr("UI action did not reach the poker engine")
			quit(1)
			return
		for index in range(60):
			await process_frame
			if not app._busy:
				break
	if not capture.is_empty():
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(capture.path_join("table.png"))
	print("UI smoke complete: home, campaign, table")
	app.session.pause()
	app._screen = "home"
	# Allow any in-flight bot coroutine and hand-transition timer to finish
	# before freeing the scene, rather than reporting shutdown resource leaks.
	await create_timer(1.1).timeout
	app._feedback.stop_all()
	await create_timer(0.1).timeout
	app.queue_free()
	await process_frame
	await process_frame
	quit()
