extends Control


const ZERO_RECT = Rect2(Vector2.ZERO, Vector2.ZERO)


onready var _vp_container: ViewportContainer = get_node("%ViewportContainer")
onready var _vp: Viewport = get_node("%Viewport")
onready var _level_parent: Node2D = get_node("%LevelParent")


var _capture_data: LevelshotCaptureData
var _levelshot_data: LevelshotData


func _ready():
	_capture_data = LevelshotCaptureData.new()
	_capture_data.load()
	_levelshot_data = LevelshotData.new()
	_levelshot_data.load()
	_ensure_save_folder_exists()
	_process_levels()


func _ensure_save_folder_exists() -> void:
	pass
	var full_save_folder = "user://%s" % _levelshot_data.save_folder
	var d := Directory.new()
	if d.dir_exists(full_save_folder):
		return
	d.make_dir_recursive(full_save_folder)


func _process_levels():
	print("LevelshotCapture: beginning levelshot captures")
	get_tree().paused = true
	for level_scene_path in _capture_data.level_scene_paths:
		var level = _levelshot_data.get_level(level_scene_path)
		yield(_process_level(level), "completed")
	print("LevelshotCapture: levelshot captures complete")
	get_tree().quit()


func _process_level(level: LevelshotLevelData):
	print("LevelshotCapture: processing level %s" % level.level_scene_path)
	var level_scene = load(level.level_scene_path)
	
	var loaded_level = level_scene.instance()
	_level_parent.add_child(loaded_level)
	
	var level_extent: Rect2
	if level.level_boundary_option == LevelshotLevelData.LevelBoundaryOptions.LEVELSHOTREFRECT:
		level_extent = _get_level_extent_from_levelshot_ref_rect_rec(loaded_level)
	else:
		#level_extent = _get_node_extent_rec(loaded_level)
		var calculator := LevelshotLevelExtentCalculator.new()
		level_extent = calculator.get_level_extent(loaded_level, level.include_canvas_layers, level.get_excluded_node_groups_array())
	
	if Vector2.ZERO.is_equal_approx(level_extent.size):
		printerr("LevelshotCapture: could not determine level boundary for level %s" % level.level_scene_path)
		loaded_level.queue_free()
		yield(get_tree(), "idle_frame")
		return

	yield(get_tree(), "idle_frame")
	
	var camera := Camera2D.new()
	camera.current = true
	_vp.add_child(camera)

	# size viewport/viewportcontainer - make fit into max size but keep level rect aspect ratio
	var v = level.size / level_extent.size
	var f = min(v.x, v.y)
	var viewport_size = level_extent.size * f
	_vp.size = viewport_size
	_vp_container.rect_size = viewport_size

	# center camera in level
	camera.global_position = level_extent.position + level_extent.size / 2.0
	
	# zoom camera out so entire level in view
	var zoom_xy = level_extent.size / _vp_container.rect_size
	var zoom = max(zoom_xy.x, zoom_xy.y)
	camera.zoom = Vector2(zoom, zoom)

	yield(get_tree(), "idle_frame")
	
	_save_level_image(level.level_scene_path)
	
	# clean up
	camera.queue_free()
	loaded_level.queue_free()
	yield(get_tree(), "idle_frame")
	print("LevelshotCapture: capture complete for level %s" % level.level_scene_path)


func _save_level_image(level_scene_path: String) -> void:
	var image: Image = _vp.get_texture().get_data()
	image.flip_y()
	#_levelshot_data.save_folder
	var s:= ""
	level_scene_path.get_file()
	var base_file_name = level_scene_path.get_file().replace(".tscn", "").replace(".scn", "")
	var image_file_path = "user://%s/%s.png" % [_levelshot_data.save_folder, base_file_name]
	var result = image.save_png(image_file_path)
	if result != OK:
		printerr("Unable to save level image to %s (error code %d)" % [image_file_path, result])


func _get_level_extent_from_levelshot_ref_rect_rec(n: Node) -> Rect2:
	if n is LevelshotReferenceRect:
		var rr: LevelshotReferenceRect = n
		return rr.get_global_rect()
	
	for c in get_children():
		var result := _get_level_extent_from_levelshot_ref_rect_rec(c)
		if result.size != Vector2.ZERO:
			return result
	
	return ZERO_RECT


