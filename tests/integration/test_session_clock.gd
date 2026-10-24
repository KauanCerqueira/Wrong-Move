extends RefCounted
const Session = preload("res://scripts/application/game_session.gd")

func _human_turn(directory: String) -> RefCounted:
	var session := Session.new(directory)
	session.mode = "hardcore"
	session.start("1")
	for iteration in range(20):
		if int(session.game().state.actor) == 0:
			break
		if session.game().state.phase == "settled":
			session.next_hand()
		else:
			var legal: Dictionary = session.game().legal_actions(int(session.game().state.actor))
			session.act("CHECK" if legal.check_allowed else "CALL")
	return session

func run() -> Array[String]:
	var errors: Array[String] = []
	var base := "user://tests/clock_" + str(Time.get_ticks_usec())
	var exact := _human_turn(base + "/exact")
	exact.tick(250)
	var expected: int = exact.clock.decision_remaining_ms
	exact.pause()
	var loaded := Session.new(base + "/exact")
	if loaded.clock.decision_remaining_ms != expected or not loaded.paused:
		errors.append("normal pause did not preserve exact clock")
	loaded.resume()
	if loaded.clock.decision_remaining_ms != expected:
		errors.append("resume renewed decision budget")
	var killed := _human_turn(base + "/kill")
	killed.tick(250)
	var live: int = killed.clock.decision_remaining_ms + killed.clock.reserve_remaining_ms
	var restored := Session.new(base + "/kill")
	var durable: int = restored.clock.decision_remaining_ms + restored.clock.reserve_remaining_ms
	if durable > live or live - durable > 1000:
		errors.append("abrupt process restore gained time or lost over1000ms")
	if restored.clock_decision_id != killed.clock_decision_id:
		errors.append("restore changed decision identity")
	return errors
