class_name CampaignService
extends RefCounted

const Decimal = preload("res://scripts/domain/unsigned_decimal.gd")
const Generator = preload("res://scripts/campaign/challenge_generator.gd")
const State = preload("res://scripts/campaign/campaign_state.gd")

# These are in-memory proposals. The owner commits snapshot(), restoring the
# previous snapshot on failed durable writes before exposing a successful result.
var state: Dictionary


func _init(mode: String = "normal", seed_hex: String = State.DEFAULT_SEED) -> void:
	state = State.fresh(seed_hex)
	state.mode = mode
	state.unlocked["1"] = Generator.table_config("1", mode, seed_hex)


func config(index: String) -> Dictionary:
	if state.unlocked.has(index):
		return state.unlocked[index].duplicate(true)
	return Generator.table_config(index, state.mode, state.seed_hex)


func unlock(index: String) -> Dictionary:
	if not Generator.valid_index(index):
		return _error("invalid_index")
	if state.unlocked.has(index):
		return state.receipts.unlocks.get(index, {"ok": true, "error": "", "index": index, "cost": 0}).duplicate(true)
	if not state.completed.has(Decimal.subtract(index, "1")):
		return _error("previous_table_not_completed")
	var table := config(index)
	if table.is_empty():
		return _error("invalid_config")
	var cost := str(table.unlock_cost)
	if Decimal.compare(state.wallet, cost) < 0:
		return _error("insufficient_funds")
	state.wallet = Decimal.subtract(state.wallet, cost)
	state.unlocked[index] = table.duplicate(true)
	var receipt := {"ok": true, "error": "", "index": index, "cost": table.unlock_cost}
	state.receipts.unlocks[index] = receipt.duplicate(true)
	return receipt


func start_attempt(index: String) -> Dictionary:
	if not state.unlocked.has(index):
		return _error("table_locked")
	if not state.active_attempt.is_empty():
		return _error("attempt_active")
	var attempt_id: String = state.mode + ":" + state.next_attempt_counter
	state.next_attempt_counter = Decimal.add(state.next_attempt_counter, "1")
	var table := config(index)
	state.active_attempt = {"attempt_id": attempt_id, "index": index, "config": table.duplicate(true)}
	# Keep the latest result until a new attempt begins; older commands are
	# rejected using the active ID and the monotonic counter, without a ledger.
	state.receipts.finish = {}
	state.receipts.hints = {}
	return {"ok": true, "error": "", "attempt_id": attempt_id, "config": table}


func finish_attempt(attempt_id: String, won: bool) -> Dictionary:
	if state.receipts.finish.has(attempt_id):
		return state.receipts.finish[attempt_id].duplicate(true)
	if state.active_attempt.is_empty() or state.active_attempt.attempt_id != attempt_id:
		return _error("attempt_not_active")
	var attempt: Dictionary = state.active_attempt
	var reward := 0
	var first_win: bool = won and not state.completed.has(attempt.index)
	if won:
		reward = int(attempt.config.base_reward)
		if first_win:
			reward += int(attempt.config.first_win_bonus)
		state.completed[attempt.index] = true
	state.wallet = Decimal.add(state.wallet, str(reward))
	var receipt := {"ok": true, "error": "", "attempt_id": attempt_id, "won": won,
		"first_win": first_win, "reward": reward}
	state.receipts.finish[attempt_id] = receipt.duplicate(true)
	state.active_attempt = {}
	state.receipts.hints = {}
	return receipt


func debit_hint(decision_id: String, context: Dictionary = {}) -> Dictionary:
	if state.mode != "normal":
		return _error("hints_unavailable")
	if state.active_attempt.is_empty():
		return _error("attempt_not_active")
	var attempt_id: String = state.active_attempt.attempt_id
	if not _valid_decision_id(decision_id, attempt_id):
		return _error("invalid_decision_id")
	if state.receipts.hints.has(decision_id):
		return state.receipts.hints[decision_id].duplicate(true)
	var cost: int = state.active_attempt.config.hint_price
	if Decimal.compare(state.wallet, str(cost)) < 0:
		return _error("insufficient_funds")
	state.wallet = Decimal.subtract(state.wallet, str(cost))
	var receipt := {"ok": true, "error": "", "attempt_id": attempt_id,
		"decision_id": decision_id, "cost": cost, "context": context.duplicate(true)}
	state.receipts.hints[decision_id] = receipt.duplicate(true)
	return receipt


func snapshot() -> Dictionary:
	return state.duplicate(true)


func restore(saved: Dictionary) -> void:
	# Aggregate save validation belongs to the persistence owner.
	state = saved.duplicate(true)


static func _valid_decision_id(decision_id: String, attempt_id: String) -> bool:
	var prefix := attempt_id + ":"
	if not decision_id.begins_with(prefix):
		return false
	var counters := decision_id.substr(prefix.length()).split(":")
	if counters.size() != 2:
		return false
	for counter in counters:
		if counter != "0" and not Generator.valid_index(counter):
			return false
	return true


static func _error(reason: String) -> Dictionary:
	return {"ok": false, "error": reason}
