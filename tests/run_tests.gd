extends SceneTree

var failures: Array[String] = []
var suites_run: int = 0
var started_ms: int = 0

func _initialize() -> void:
	started_ms = Time.get_ticks_msec()
	call_deferred("_run")

func _run() -> void:
	var selected := "all"
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--suite="):
			selected = arg.trim_prefix("--suite=")
	if selected not in ["all", "domain", "integration", "simulation"]:
		printerr("Unknown suite: ", selected)
		quit(2)
		return
	for group: String in ["domain", "integration", "simulation"]:
		if selected != "all" and selected != group:
			continue
		var directory := DirAccess.open("res://tests/" + group)
		if directory == null:
			continue
		var files := directory.get_files()
		files.sort()
		for filename: String in files:
			if not filename.begins_with("test_") or not filename.ends_with(".gd"):
				continue
			var path := "res://tests/" + group + "/" + filename
			var script: Script = load(path)
			if script == null or not script.can_instantiate():
				failures.append(path + ": script could not compile")
				continue
			var instance: RefCounted = script.new()
			if not instance.has_method("run"):
				failures.append(path + ": missing run()")
				continue
			var suite_failures: Variant = instance.run()
			suites_run += 1
			if not suite_failures is Array:
				failures.append(path + ": run() must return Array[String]")
			elif suite_failures.is_empty():
				print("PASS ", group, "/", filename)
			else:
				for failure: Variant in suite_failures:
					failures.append(path + ": " + str(failure))
	if suites_run == 0:
		failures.append("No test suites executed")
	for failure: String in failures:
		printerr("FAIL ", failure)
	print(JSON.stringify({"suites": suites_run, "failures": failures.size(), "elapsed_ms": Time.get_ticks_msec() - started_ms}))
	quit(0 if failures.is_empty() else 1)
