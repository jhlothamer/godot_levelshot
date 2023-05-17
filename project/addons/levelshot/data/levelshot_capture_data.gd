tool
class_name LevelshotCaptureData
extends Reference

const DATA_FILEPATH = "user://levelshot_capture_data.json"


var level_scene_paths := []


func save() -> void:
	var data := {
		"level_scene_paths": level_scene_paths
	}
	LevelshotFileUtil.save_json_data(DATA_FILEPATH, data)


func load() -> void:
	var data := LevelshotFileUtil.load_json_data(DATA_FILEPATH)
	if !data.has("level_scene_paths"):
		printerr("LevelshotCaptureData: no level_scene_paths array in capture data file")
	level_scene_paths = data["level_scene_paths"]
