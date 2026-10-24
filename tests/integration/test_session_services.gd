extends RefCounted

const Session = preload("res://scripts/application/game_session.gd")

func run() -> Array[String]:
	var errors: Array[String] = []
	var directory := "user://tests/services_" + str(Time.get_ticks_usec())
	var session := Session.new(directory)
	if session.complete_lesson(-1).ok or session.complete_lesson(5).ok:
		errors.append("invalid lesson accepted")
	if not session.complete_lesson(2).ok:
		errors.append("lesson save failed")
	var restored := Session.new(directory)
	if int(restored.tutorial_progress.last_step) != 3 or not restored.tutorial_progress.completed.has("2"):
		errors.append("tutorial progress not preserved")
	if not session.start("1").ok:
		errors.append("cannot start hint fixture")
		return errors
	while int(session.game().state.actor) > 0:
		var legal: Dictionary = session.game().legal_actions(int(session.game().state.actor))
		session.act("CHECK" if legal.check_allowed else "CALL")
	if session.hint().ok:
		errors.append("hint available before eight seconds")
	session.tick(8000)
	if session.hint().ok:
		errors.append("hint purchased with empty wallet")
	# Seed an earned balance for this transaction fixture, not a product grant.
	session.campaign().state.wallet = "100"
	session._store.fail_at = "before_rename"
	if session.hint().ok or session.campaign().state.wallet != "100":
		errors.append("failed save charged hint")
	if not session.campaign().state.receipts.hints.is_empty():
		errors.append("failed save retained hint receipt")
	session._store.fail_at = ""
	if not session.retry_save().ok:
		errors.append("retry after transient save failure failed")
	session.resume()
	var advice: Dictionary = session.hint()
	if not advice.get("ok", false) or session.campaign().state.wallet != "90":
		errors.append("ready hint not charged exactly once: " + str(advice) + " wallet=" + str(session.campaign().state.wallet) + " elapsed=" + str(session.hint_elapsed_ms) + " error=" + session.error)
	if session.hint() != advice or session.campaign().state.wallet != "90":
		errors.append("hint reopen charged twice or changed advice")
	session.pause()
	var reopened := Session.new(directory)
	reopened.resume()
	var reopened_advice: Dictionary = reopened.hint()
	if not _same_advice(reopened_advice, advice) or reopened.campaign().state.wallet != "90":
		errors.append("hint receipt not preserved across reload: " + str(reopened_advice) + " expected=" + str(advice) + " wallet=" + str(reopened.campaign().state.wallet))
	reopened.pause()
	reopened.mode = "hardcore"
	if not reopened.start("1").ok:
		errors.append("hardcore fixture failed")
	if reopened.hint().ok or reopened.campaign().state.wallet != "0":
		errors.append("hardcore hint or shared balance detected")
	return errors

func _same_advice(left: Dictionary, right: Dictionary) -> bool:
	# JSON numbers load as float and interned keys become String. Compare the
	# persisted recommendation contract, not GDScript Variant storage types.
	return left.get("ok", false) == right.get("ok", false) and str(left.get("kind", "")) == str(right.get("kind", "")) and int(left.get("raise_to", -1)) == int(right.get("raise_to", -1)) and str(left.get("explanation", "")) == str(right.get("explanation", ""))
