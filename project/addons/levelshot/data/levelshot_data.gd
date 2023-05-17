tool
class_name LevelshotData
extends Reference

const DATA_FILEPATH = "res://addons/levelshot/data/levelshot_data.json"


const DEFAULT_DATA = {
	"save_folder": "levelshots",
	"data_version": "1.0",
	"levels": []
	}


var levels = {}
var save_folder := "levelshots"
var data_version := "1.0"


var _options := LevelshotLevelData.LevelshotLevelDataOptions.new()


func load() -> void:
	var data = LevelshotFileUtil.load_json_data(DATA_FILEPATH, DEFAULT_DATA)
	save_folder = data["save_folder"]
	data_version = data["data_version"]
	var file := File.new()
	for levelData in data["levels"]:
		var level := LevelshotLevelData.new(_options)
		level.read(levelData)
		if !file.file_exists(level.level_scene_path):
			continue
		levels[level.level_scene_path] = level
	_check_dup_filenames()


func write() -> void:
	var data := {}
	data["save_folder"] = save_folder
	data["data_version"] = data_version
	data["levels"] = []
	for level in levels.values():
		var levelData := {}
		level.write(levelData)
		data["levels"].append(levelData)
	
	LevelshotFileUtil.save_json_data(DATA_FILEPATH, data)


func add_levels(level_paths: Array) -> bool:
	var level_added := false
	for level_path in level_paths:
		if levels.has(level_path):
			continue
		var level := LevelshotLevelData.new(_options, level_path)
		levels[level_path] = level
		level_added = true
	return level_added


func get_levels() -> Array:
	return levels.values()


func get_level(level_scene_path: String) -> LevelshotLevelData:
	if levels.has(level_scene_path):
		return levels[level_scene_path]
	return null


func remove_level(level_path: String) -> void:
	levels.erase(level_path)


func _check_dup_filenames() -> void:
	var dup_filename_found := false
	var filenames := {}
	for level in levels.values():
		if filenames.has(level.filename):
			dup_filename_found = true
		else:
			filenames[level.filename]  = 1
	_options.use_filename_for_display = !dup_filename_found

























