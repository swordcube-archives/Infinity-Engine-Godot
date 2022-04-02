extends Node

func round_decimal(num, digit):
	return round(num * pow(10.0, digit)) / pow(10.0, digit)
