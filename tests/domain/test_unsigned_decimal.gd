extends RefCounted

const Decimal = preload("res://scripts/domain/unsigned_decimal.gd")

func run() -> Array[String]:
	var failures: Array[String] = []
	for value in ["", "00", "01", "-1", "+1", "1.0", " 1", "1 ", "1e3", "１２", "1\n"]:
		if Decimal.valid(value):
			failures.append("Accepted invalid decimal: " + value)
	var hundred := "9".repeat(100)
	var power := "1" + "0".repeat(100)
	if not Decimal.valid(hundred) or not Decimal.valid("0"):
		failures.append("Rejected canonical decimal")
	if Decimal.add(hundred, "1") != power:
		failures.append("100-digit carry failed")
	if Decimal.subtract(power, "1") != hundred:
		failures.append("100-digit borrow failed")
	if Decimal.multiply_small(hundred, 9) != "8" + "9".repeat(99) + "1":
		failures.append("100-digit multiplication failed")
	if Decimal.divide_small(hundred, 9) != "1".repeat(100) or Decimal.modulo_small(hundred, 9) != 0:
		failures.append("100-digit division failed")
	if Decimal.compare(hundred, "10") != 1 or Decimal.compare("9", "10") != -1 or Decimal.compare(power, power) != 0:
		failures.append("Numeric comparison failed")
	if Decimal.subtract("10", "10") != "0" or Decimal.multiply_small(hundred, 0) != "0" or Decimal.divide_small("5", 10) != "0":
		failures.append("Zero normalization failed")
	if Decimal.divide_small("12345", 17) != "726" or Decimal.modulo_small("12345", 17) != 3:
		failures.append("Division remainder failed")
	if Decimal.add("01", "2") != "" or Decimal.subtract("1", "2") != "" or Decimal.multiply_small("1", -1) != "" or Decimal.divide_small("1", 0) != "" or Decimal.modulo_small("1", 0) != -1:
		failures.append("Invalid arithmetic must be rejected")
	for value in ["", "00", "-1", "1.0"]:
		if Decimal.add(value, "1") != "" or Decimal.subtract(value, "0") != "" or Decimal.multiply_small(value, 2) != "" or Decimal.divide_small(value, 2) != "" or Decimal.modulo_small(value, 2) != -1:
			failures.append("Arithmetic accepted invalid decimal: " + value)
	for number in range(0, 300, 7):
		for small in [1, 3, 17, 99]:
			if Decimal.add(str(number), str(small)) != str(number + small) or Decimal.multiply_small(str(number), small) != str(number * small) or Decimal.divide_small(str(number), small) != str(int(number / small)) or Decimal.modulo_small(str(number), small) != number % small:
				failures.append("Native integer cross-check failed: %d, %d" % [number, small])
	if Decimal.multiply_small("9999999999", 2147483647) != "21474836467852516353" or Decimal.divide_small("21474836467852516353", 2147483647) != "9999999999":
		failures.append("Maximum small operand arithmetic failed")
	return failures
