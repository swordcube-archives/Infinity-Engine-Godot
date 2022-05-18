extends Node

var string_directions = {
	"1k": ["E"],
	"2k": ["A", "D"],
	"3k": ["A", "E", "D"],
	"4k": ["A", "B", "C", "D"],
	"5k": ["A", "B", "E", "C", "D"],
	"6k": ["A", "B", "D", "F", "H", "I"],
	"7k": ["A", "B", "D", "E", "F", "H", "I"],
	"8k": ["A", "B", "C", "D", "F", "G", "H", "I"],
	"9k": ["A", "B", "C", "D", "E", "F", "G", "H", "I"],
}

func dir_to_str(dir:int = 0, keycount:int = 4):
	return string_directions[str(keycount) + "k"][dir]
