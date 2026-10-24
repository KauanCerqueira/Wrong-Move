extends RefCounted

const Clock = preload("res://scripts/application/hardcore_clock.gd")

func run() -> Array[String]:
	var failures: Array[String] = []
	var clock := Clock.new()
	clock.advance(50000)
	_check(clock.decision_remaining_ms == 10000 and clock.reserve_remaining_ms == 30000, "Paused clocks must not advance", failures)
	clock.resume()
	_check(not clock.advance(0), "Zero delta must not expire a fresh decision", failures)
	clock.advance(999)
	_check(clock.decision_remaining_ms == 9001, "999 ms boundary", failures)
	clock.advance(1)
	_check(clock.decision_remaining_ms == 9000, "1000 ms boundary", failures)
	clock.pause()
	clock.advance(99999)
	clock.resume()
	_check(clock.decision_remaining_ms == 9000, "Pause/resume must not refresh time", failures)
	clock.advance(-1)
	_check(clock.decision_remaining_ms == 9000, "Negative deltas must not credit time", failures)
	clock.advance(9001)
	_check(clock.decision_remaining_ms == 0 and clock.reserve_remaining_ms == 29999, "Overflow must debit reserve exactly", failures)
	clock.new_decision()
	_check(clock.paused and clock.decision_remaining_ms == 10000 and clock.reserve_remaining_ms == 29999, "New decision preserves reserve", failures)
	clock.resume()
	_check(not clock.advance(39998), "One ms must remain before expiration", failures)
	_check(clock.advance(1) and clock.advance(0), "Expiration must stay expired", failures)
	clock.pause()
	clock.resume()
	_check(clock.advance(100000), "Expired clocks cannot revive on resume", failures)
	clock.new_attempt()
	_check(clock.snapshot() == {"decision_remaining_ms": 10000, "reserve_remaining_ms": 30000, "paused": true}, "New attempt resets both balances paused", failures)
	clock.resume()
	clock.advance(9500)
	var exact := clock.snapshot()
	var projected := clock.durable_snapshot()
	_check(projected.decision_remaining_ms == 0 and projected.reserve_remaining_ms == 29500, "Conservative projection crosses reserve boundary", failures)
	_check(clock.snapshot() == exact, "Projection must not mutate live clock", failures)
	for elapsed in [0, 999, 1000]:
		var killed := Clock.new()
		killed.restore(projected)
		var live := Clock.new()
		live.restore(exact)
		live.resume()
		live.advance(elapsed)
		var loss: int = live.decision_remaining_ms + live.reserve_remaining_ms - killed.decision_remaining_ms - killed.reserve_remaining_ms
		_check(loss >= 0 and loss <= 1000 and killed.paused, "Kill must never refund time and lose at most 1 s", failures)
	clock.restore(JSON.parse_string(JSON.stringify(exact)))
	_check(clock.paused and clock.decision_remaining_ms == 500 and clock.reserve_remaining_ms == 30000, "Exact pause save takes precedence when restored", failures)
	var before := clock.snapshot()
	for invalid in [{}, {"decision_remaining_ms": -1, "reserve_remaining_ms": 30000}, {"decision_remaining_ms": 10001, "reserve_remaining_ms": 0}, {"decision_remaining_ms": 1.5, "reserve_remaining_ms": 0}, {"decision_remaining_ms": "100", "reserve_remaining_ms": 0}, {"decision_remaining_ms": 0, "reserve_remaining_ms": 30001}]:
		clock.restore(invalid)
		_check(clock.snapshot() == before, "Invalid restore must be atomic", failures)
	return failures

func _check(condition: bool, message: String, failures: Array[String]) -> void:
	if not condition:
		failures.append(message)
