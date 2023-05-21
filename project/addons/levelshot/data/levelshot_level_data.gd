class_name LevelshotLevelData
extends Reference


class LevelshotLevelDataOptions:
	var use_filename_for_display := true


enum ImageSizeOptions {
	SCALE,
	MAXSIZE,
	SCALEWITHMAXSIZE,
}


enum LevelBoundaryOptions {
	CALCULATE,
	LEVELSHOTREFRECT
}


var level_scene_path := ""
var filename := ""
var image_size_option:int = ImageSizeOptions.SCALE
var scale := 10
var size := Vector2(1920, 1080)
var level_boundary_option:int = LevelBoundaryOptions.CALCULATE
var excluded_node_groups := "levelshot_exclude"
var include_canvas_layers := false
var disabled := false


var display_name :String setget ,_get_display_name

var _options:LevelshotLevelDataOptions


func _init(options: LevelshotLevelDataOptions, scene_path: String = ""):
	_options = options
	if scene_path and scene_path != "":
		level_scene_path = scene_path
		filename = level_scene_path.get_file()


func read(data: Dictionary) -> void:
	level_scene_path = data["level_scene_path"]
	filename = level_scene_path.get_file()
	image_size_option = data["image_size_option"]
	scale = data["scale"]
	size.x = data["size_x"]
	size.y = data["size_y"]
	level_boundary_option = data["level_boundary_option"]
	excluded_node_groups = data["excluded_node_groups"]
	include_canvas_layers = data["include_canvas_layers"]
	disabled = data["disabled"]


func write(data: Dictionary) -> void:
	data["level_scene_path"] = level_scene_path
	data["image_size_option"] = image_size_option
	data["scale"] = scale
	data["size_x"] = size.x
	data["size_y"] = size.y
	data["level_boundary_option"] = level_boundary_option
	data["excluded_node_groups"] = excluded_node_groups
	data["include_canvas_layers"] = include_canvas_layers
	data["disabled"] = disabled


func get_excluded_node_groups_array() -> Array:
	var a := []
	
	for i in excluded_node_groups.split(","):
		a.append(i.lstrip(" ").rstrip(" "))
	
	return a


func _get_display_name():
	if _options.use_filename_for_display:
		return filename
	return level_scene_path





