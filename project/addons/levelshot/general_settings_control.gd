tool
extends VBoxContainer


onready var _save_folder: TextEdit = get_node("%SaveFolderTextEdit")


var level_data: LevelshotData setget _set_level_data


func update_data():
	level_data.save_folder = _save_folder.text


func _set_level_data(value):
	level_data = value
	if _save_folder != null:
		_save_folder.text = level_data.save_folder
