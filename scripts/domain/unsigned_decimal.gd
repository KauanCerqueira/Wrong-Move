class_name UnsignedDecimal
extends RefCounted

## Canonical ASCII unsigned decimals only. Arithmetic rejects invalid input with
## an empty string; modulo rejects it with -1. compare returns 0 if invalid.
## Small operands are nonnegative signed 32-bit integers (divisors must be >0).
const MAX_SMALL: int = 2147483647

static func valid(value: String) -> bool:
	if value.is_empty() or (value.length() > 1 and value.unicode_at(0) == 48):
		return false
	for index in range(value.length()):
		var code: int = value.unicode_at(index)
		if code < 48 or code > 57:
			return false
	return true

static func compare(a: String, b: String) -> int:
	if not valid(a) or not valid(b) or a == b:
		return 0
	if a.length() != b.length():
		return 1 if a.length() > b.length() else -1
	return 1 if a > b else -1

static func add(a: String, b: String) -> String:
	if not valid(a) or not valid(b):
		return ""
	var left: int = a.length() - 1
	var right: int = b.length() - 1
	var carry: int = 0
	var digits: PackedStringArray = []
	while left >= 0 or right >= 0 or carry > 0:
		var total: int = carry
		if left >= 0:
			total += a.unicode_at(left) - 48
		if right >= 0:
			total += b.unicode_at(right) - 48
		digits.append(str(total % 10))
		carry = int(total / 10)
		left -= 1
		right -= 1
	digits.reverse()
	return "".join(digits)

static func subtract(a: String, b: String) -> String:
	if not valid(a) or not valid(b) or compare(a, b) < 0:
		return ""
	var right: int = b.length() - 1
	var borrow: int = 0
	var digits: PackedStringArray = []
	for left in range(a.length() - 1, -1, -1):
		var digit: int = a.unicode_at(left) - 48 - borrow
		if right >= 0:
			digit -= b.unicode_at(right) - 48
		borrow = 1 if digit < 0 else 0
		if digit < 0:
			digit += 10
		digits.append(str(digit))
		right -= 1
	digits.reverse()
	return _normalize("".join(digits))

static func multiply_small(value: String, factor: int) -> String:
	if not valid(value) or factor < 0 or factor > MAX_SMALL:
		return ""
	var carry: int = 0
	var digits: PackedStringArray = []
	for index in range(value.length() - 1, -1, -1):
		var product: int = (value.unicode_at(index) - 48) * factor + carry
		digits.append(str(product % 10))
		carry = int(product / 10)
	while carry > 0:
		digits.append(str(carry % 10))
		carry = int(carry / 10)
	digits.reverse()
	return _normalize("".join(digits))

static func divide_small(value: String, divisor: int) -> String:
	if not valid(value) or divisor <= 0 or divisor > MAX_SMALL:
		return ""
	var remainder: int = 0
	var digits: PackedStringArray = []
	for index in range(value.length()):
		var current: int = remainder * 10 + value.unicode_at(index) - 48
		digits.append(str(int(current / divisor)))
		remainder = current % divisor
	return _normalize("".join(digits))

static func modulo_small(value: String, divisor: int) -> int:
	if not valid(value) or divisor <= 0 or divisor > MAX_SMALL:
		return -1
	var remainder: int = 0
	for index in range(value.length()):
		remainder = (remainder * 10 + value.unicode_at(index) - 48) % divisor
	return remainder

static func _normalize(value: String) -> String:
	var first: int = 0
	while first < value.length() - 1 and value.unicode_at(first) == 48:
		first += 1
	return value.substr(first)
