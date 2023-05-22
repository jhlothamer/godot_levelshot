tool
class_name LevelshotData
extends Reference


const DEFAULT_DATA = {
	"save_folder": "levelshots",
	"data_version": "1.0",
	"levels": []
	}


var data_version := "1.0"
var levels = {}
var save_folder := "levelshots"


var _options := LevelshotLevelData.LevelshotLevelDataOptions.new()


func load() -> void:
	var data_filepath = _get_data_file_path()
	var data = LevelshotFileUtil.load_json_data(data_filepath, DEFAULT_DATA)
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


func save() -> void:
	if !_ensure_data_folder_exists():
		return
	var data := {}
	data["save_folder"] = save_folder
	data["data_version"] = data_version
	data["levels"] = []
	for level in levels.values():
		var levelData := {}
		level.write(levelData)
		data["levels"].append(levelData)
	
	var data_filepath = _get_data_file_path()
	LevelshotFileUtil.save_json_data(data_filepath, data)


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


func _get_project_name() -> String:
	var project_name:String = ProjectSettings.get_setting("application/config/name")
	project_name = project_name.to_lower().replace(" ", "_").replace(".", "_")
	return project_name
	

func _get_data_file_path() -> String:
	var data_folder = LevelshotSettings.get_data_folder()
	if !data_folder.ends_with("/"):
		data_folder += "/"
	var data_filename_pattern = LevelshotSettings.get_data_file_name_pattern()
	var project_name = _get_project_name()
	var filename = data_filename_pattern.replace("[PROJECTNAME]", project_name)
	return "%s%s" % [data_folder, filename]


func _ensure_data_folder_exists() -> bool:
	var data_folder = LevelshotSettings.get_data_folder()
	var dir := Directory.new()
	if dir.dir_exists(data_folder):
		return true
	if OK != dir.make_dir_recursive(data_folder):
		printerr("LevelshotData: could not make data folder %s : is it a valid path?" % data_folder)
		return false
	return true
