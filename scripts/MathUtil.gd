extends Node

func roundDecimal(num, digit):
	return round(num * pow(10.0, digit)) / pow(10.0, digit)
	
func remapToRange(value:float, start1:float, stop1:float, start2:float, stop2:float):
	return start2 + (value - start1) * ((stop2 - start2) / (stop1 - start1))
	
func boundTo(value:float, minV:float, maxV:float):
	return max(minV, min(maxV, value))
	
func getLerpValue(value_60, delta):
	return delta * (value_60 / (1.0 / 60.0))
