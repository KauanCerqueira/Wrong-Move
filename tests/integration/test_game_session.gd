extends RefCounted

const Session = preload("res://scripts/application/game_session.gd")

func run() -> Array[String]:
	var errors: Array[String] = []
	var directory := "user://tests/session_" + str(Time.get_ticks_usec())
	var session := Session.new(directory)
	var started: Dictionary = session.start("1")
	if not started.ok:
		errors.append("first attempt failed: " + str(started))
		return errors
	if session.campaign().state.wallet != "0":
		errors.append("starting attempt charged wallet")
	var snapshot: Dictionary = session.game().snapshot()
	var resumed := Session.new(directory)
	if not resumed.active() or resumed.game().snapshot() != snapshot or not resumed.paused:
		errors.append("roundtrip did not preserve tournament and paused state")
	resumed.resume()
	var revision: int = resumed.game().state.revision
	var stale: Dictionary = resumed.act("CHECK", 0, revision - 1)
	if stale.ok or resumed.game().state.revision != revision:
		errors.append("stale action changed state")
	var legal: Dictionary = resumed.game().legal_actions(int(resumed.game().state.actor))
	var action := "CHECK" if legal.check_allowed else "CALL"
	var result: Dictionary = resumed.act(action, 0, revision, "test-action")
	var after: Dictionary = resumed.game().snapshot()
	var duplicate: Dictionary = resumed.act(action, 0, revision, "test-action")
	if not result.ok or not duplicate.ok or resumed.game().snapshot() != after:
		errors.append("action command was not idempotent")
	var steps := 0
	while resumed.active() and steps < 3000:
		steps += 1
		if resumed.game().state.phase == "settled":
			result = resumed.next_hand()
		else:
			legal = resumed.game().legal_actions(int(resumed.game().state.actor))
			result = resumed.act("CHECK" if legal.check_allowed else "CALL")
		if not result.ok:
			errors.append("failed integrated action: " + str(result))
			break
	if resumed.active():
		errors.append("passive tournament did not end: " + str(resumed.game().state.get("status")) + " phase=" + str(resumed.game().state.get("phase")))
	else:
		var won: bool = resumed.last_results.normal.won
		var expected_wallet := "200" if won else "0"
		if resumed.campaign().state.wallet != expected_wallet:
			errors.append("terminal prize incorrect")
		var reopened := Session.new(directory)
		if reopened.campaign().state.wallet != expected_wallet or reopened.active():
			errors.append("terminal state did not persist atomically")
		if not reopened.start("1").ok:
			errors.append("free retry unavailable")
	return errors
