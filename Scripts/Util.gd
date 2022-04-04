extends Node

func round_decimal(num, digit):
	return round(num * pow(10.0, digit)) / pow(10.0, digit)
	
func remap_to_range(value, start1, stop1, start2, stop2):
	return start2 + (value - start1) * ((stop2 - start2) / (stop1 - start1))
	
func format_time(seconds, show_ms):
	var timeString:String = str(int(seconds / 60)) + ":"
	var timeStringHelper:int = int(seconds) % 60;
	if (timeStringHelper < 10):
		timeString += "0"
		
	timeString += str(timeStringHelper)
	
	if (show_ms):
		timeString += ".";
		timeStringHelper = int((seconds - int(seconds)) * 100)
		if (timeStringHelper < 10):
			timeString += "0"

		timeString += str(timeStringHelper)

	return timeString

