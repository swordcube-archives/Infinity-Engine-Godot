extends Node2D

const modScenePath:String = "res://scenes/misc/Mod.tscn"

var files:Array = [
	modScenePath
]

func _on_ChooseFiles_pressed():
	$FileDialog.popup_centered()

func _on_FileDialog_files_selected(paths):
	files = [
		modScenePath
	]
	
	for file in paths:
		if not file in files:
			files.append(file)

func _on_PackUp_pressed():
	var packer = PCKPacker.new()
	packer.pck_start("yourNewMod.pck")

	for file in files:
		packer.add_file(file, file)

	packer.flush()
