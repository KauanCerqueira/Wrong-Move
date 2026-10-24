extends RefCounted

const Service = preload("res://scripts/campaign/campaign_service.gd")
const Decimal = preload("res://scripts/domain/unsigned_decimal.gd")


func run() -> Array[String]:
	var failures: Array[String] = []
	var normal := Service.new()
	var hardcore := Service.new("hardcore", "ffeeddccbbaa99887766554433221100")
	_check(normal.state.wallet == "0" and not normal.config("1").is_empty(), "fresh campaign", failures)
	_check(hardcore.config("1").strength == 3, "first hardcore config", failures)
	_check(not normal.unlock("2").ok, "previous win required", failures)
	var first := normal.start_attempt("1")
	_check(first.ok and normal.state.wallet == "0", "zero balance free entry", failures)
	_check(not normal.start_attempt("1").ok, "one active attempt", failures)
	_check(not normal.debit_hint(first.attempt_id + ":1:1").ok, "unaffordable hint", failures)
	_check(normal.state.wallet == "0" and normal.state.receipts.hints.is_empty(),
		"failed hint leaves no receipt or debit", failures)
	var reward := normal.finish_attempt(first.attempt_id, true)
	_check(reward.reward == 200 and normal.state.wallet == "200", "first victory bonus", failures)
	_check(normal.finish_attempt(first.attempt_id, false) == reward and normal.state.wallet == "200",
		"finish replay uses original result", failures)
	var pass_receipt := normal.unlock("2")
	_check(pass_receipt.ok and normal.state.wallet == "80", "first pass fixture", failures)
	_check(normal.unlock("2") == pass_receipt and normal.state.wallet == "80", "one pass charge", failures)
	var purchased := normal.config("2")
	purchased.base_reward = 999
	_check(normal.config("2").base_reward == 120, "config copy isolation", failures)
	var second := normal.start_attempt("2")
	_check(normal.state.wallet == "80", "no entry debit", failures)
	var before_hint := normal.snapshot()
	_check(not normal.debit_hint(first.attempt_id + ":1:1").ok
		and not normal.debit_hint(second.attempt_id + ":01:1").ok
		and normal.snapshot() == before_hint, "invalid hint commands do not mutate", failures)
	var decision: String = second.attempt_id + ":1:1"
	var hint := normal.debit_hint(decision, {"text": "stored advice"})
	_check(hint.ok and normal.state.wallet == "68", "hint debit", failures)
	_check(normal.debit_hint(decision, {"text": "changed"}) == hint and normal.state.wallet == "68",
		"hint replay retains context", failures)
	var resumed := Service.new()
	resumed.restore(normal.snapshot())
	_check(resumed.debit_hint(decision) == hint and resumed.state.wallet == "68", "saved hint receipt", failures)
	normal.restore(before_hint)
	_check(normal.state.wallet == "80" and normal.debit_hint(decision).ok
		and normal.state.wallet == "68", "failed save rollback permits one retry", failures)
	_check(normal.finish_attempt(second.attempt_id, false).reward == 0
		and normal.state.wallet == "68", "loss grants zero", failures)
	_check(not normal.debit_hint(decision).ok, "closed attempt hint rejected", failures)
	var repeat := normal.start_attempt("1")
	_check(not normal.finish_attempt(first.attempt_id, true).ok, "compacted old command rejected", failures)
	_check(normal.finish_attempt(repeat.attempt_id, true).reward == 100
		and normal.state.wallet == "168", "repeat victory only base", failures)
	_check(hardcore.state.wallet == "0" and not hardcore.state.unlocked.has("2")
		and hardcore.state.completed.is_empty(), "campaign isolation", failures)
	var hard_attempt := hardcore.start_attempt("1")
	hardcore.state.wallet = "200"
	_check(not hardcore.debit_hint(hard_attempt.attempt_id + ":1:1").ok
		and hardcore.state.wallet == "200", "hardcore forbids hints", failures)
	var huge := "9".repeat(100)
	var fixture := Service.new()
	fixture.state.wallet = huge
	fixture.state.next_attempt_counter = huge
	fixture.state.completed[Decimal.subtract(huge, "1")] = true
	_check(fixture.unlock(huge).ok and fixture.state.wallet == Decimal.subtract(huge, "1600"),
		"100 digit wallet and pass", failures)
	var large_attempt := fixture.start_attempt(huge)
	_check(large_attempt.attempt_id == "normal:" + huge
		and fixture.state.next_attempt_counter == "1" + "0".repeat(100), "100 digit attempt rollover", failures)
	var large_before: String = fixture.state.wallet
	var large_hint := fixture.debit_hint(large_attempt.attempt_id + ":" + huge + ":0", {"text": "large counter"})
	_check(large_hint.ok and fixture.state.wallet == Decimal.subtract(large_before, "150"),
		"100 digit wallet and decision hint", failures)
	large_before = fixture.state.wallet
	_check(fixture.finish_attempt(large_attempt.attempt_id, true).reward == 2000
		and fixture.state.wallet == Decimal.add(large_before, "2000"), "100 digit reward", failures)
	var saved := fixture.snapshot()
	var restored := Service.new("hardcore")
	restored.restore(saved)
	_check(restored.finish_attempt(large_attempt.attempt_id, true).reward == 2000
		and restored.state.wallet == fixture.state.wallet, "saved reward receipt", failures)
	saved.wallet = "0"
	_check(restored.state.wallet != "0", "restore snapshot isolation", failures)
	return failures


func _check(condition: bool, label: String, failures: Array[String]) -> void:
	if not condition:
		failures.append("campaign_economy: " + label)
