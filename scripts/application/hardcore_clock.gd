class_name HardcoreClock
extends RefCounted

const DECISION_MS := 10000
const RESERVE_MS := 30000
const MAX_DURABLE_WINDOW_MS := 1000

var decision_remaining_ms: int = DECISION_MS
var reserve_remaining_ms: int = RESERVE_MS
var paused: bool = true

func new_attempt() -> void:
	decision_remaining_ms = DECISION_MS
	reserve_remaining_ms = RESERVE_MS
	paused = true

## Caller must only invoke this when decision_id changes, never on resume.
func new_decision() -> void:
	decision_remaining_ms = DECISION_MS
	paused = true

func advance(elapsed_ms: int) -> bool:
	if not paused:
		_debit(maxi(0, elapsed_ms))
	return decision_remaining_ms == 0 and reserve_remaining_ms == 0

func _debit(elapsed_ms: int) -> void:
	var from_decision := mini(decision_remaining_ms, elapsed_ms)
	decision_remaining_ms -= from_decision
	reserve_remaining_ms = maxi(0, reserve_remaining_ms - (elapsed_ms - from_decision))

func pause() -> void:
	paused = true

func resume() -> void:
	paused = false

## Optional elapsed is a projection, not a mutation. Persist it before enabling
## an active window. The store owns IDs/revisions/commit sequencing; restores
## always start paused. Exact saves should use snapshot() after advance().
func snapshot(elapsed_ms: int = 0) -> Dictionary:
	var projected_decision := maxi(0, decision_remaining_ms - maxi(0, elapsed_ms))
	var projected_reserve := maxi(0, reserve_remaining_ms - maxi(0, elapsed_ms - decision_remaining_ms))
	return {"decision_remaining_ms": projected_decision, "reserve_remaining_ms": projected_reserve, "paused": paused}

func durable_snapshot(window_ms: int = MAX_DURABLE_WINDOW_MS) -> Dictionary:
	return snapshot(clampi(window_ms, 0, MAX_DURABLE_WINDOW_MS))

## Reject malformed snapshots atomically. JSON's integral floats are accepted.
func restore(data: Dictionary) -> void:
	var decision: Variant = data.get("decision_remaining_ms")
	var reserve: Variant = data.get("reserve_remaining_ms")
	if not _valid_balance(decision, DECISION_MS) or not _valid_balance(reserve, RESERVE_MS):
		return
	decision_remaining_ms = int(decision)
	reserve_remaining_ms = int(reserve)
	paused = true

static func _valid_balance(value: Variant, maximum: int) -> bool:
	if not (value is int or value is float):
		return false
	return is_finite(float(value)) and float(value) >= 0 and float(value) <= maximum and float(value) == floor(float(value))
