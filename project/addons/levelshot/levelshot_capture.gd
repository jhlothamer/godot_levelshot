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
	var full_save_folder = "user://%s" % _levelshot_data.save_folder
	var d := Directory.new()
	if d.dir_exists(full_save_folder):
		return
	if OK != d.make_dir_recursive(full_save_folder):
		printerr("LevelshotCapture: could not create save folder %s" % full_save_folder)
		assert(false)


func _process_levels():
	print("LevelshotCapture: beginning levelshot captures")
	for level_scene_path in _capture_data.level_scene_paths:
		var level = _levelshot_data.get_level(level_scene_path)
		yield(_process_level(level), "completed")
	print("LevelshotCapture: levelshot captures complete")
	get_tree().quit()


func _is_size_greater(a: Vector2, b: Vector2) -> bool:
	return a.x > b.x or a.y > b.y


func _process_level(level: LevelshotLevelData):
	print("LevelshotCapture: processing level %s" % level.level_scene_path)
	
	var level_scene = load(level.level_scene_path)
	
	var loaded_level = level_scene.instance()

	yield(get_tree(), "idle_frame")
	
	# add level to root and set it as current scene
	#  some games rely on the level scene being on the root and being the current scene
	get_tree().root.add_child(loaded_level)
	get_tree().current_scene = loaded_level
	
	# plug-in here??

	yield(get_tree(), "idle_frame")

	#  gather level extents (boundaries)
	#  a game level can have multiple LevelshotReferenceRect nodes which results in multiple images
	#  Note: this process also hides/disables/frees certain node types
	var level_extents := []
	
	if level.level_boundary_option == LevelshotLevelData.LevelBoundaryOptions.LEVELSHOTREFRECT:
		var calculator := LevelshotLevelExtentFromRefRect.new()
		level_extents = calculator.get_level_extents(loaded_level, level.include_canvas_layers, level.get_excluded_node_groups_array())
	else:
		var calculator := LevelshotLevelExtentCalculator.new()
		level_extents = calculator.get_level_extents(loaded_level, level.include_canvas_layers, level.get_excluded_node_groups_array())

	yield(get_tree(), "idle_frame")

	# now pause to stop game level code from running
	get_tree().paused = true

	# and now that code is paused move level node to be under the capture viewport
	get_tree().root.call_deferred("remove_child", loaded_level)
	_level_parent.call_deferred("add_child", loaded_level)

	yield(get_tree(), "idle_frame")

	# any camera in the level was freed during extent calculations - so we can control the camera
	var camera := Camera2D.new()
	camera.current = true
	_vp.add_child(camera)

	for i in level_extents.size():
		var level_extent: Rect2 = level_extents[i]
		if Vector2.ZERO.is_equal_approx(level_extent.size):
			printerr("LevelshotCapture: could not determine level boundary for level %s" % level.level_scene_path)
			loaded_level.queue_free()
			camera.queue_free()
			yield(get_tree(), "idle_frame")
			return

		# size viewport/viewportcontainer - make fit into max size but keep level rect aspect ratio
		
		var viewport_size := Vector2.ZERO
		
		if level.image_size_option == LevelshotLevelData.ImageSizeOptions.SCALE or level.image_size_option == LevelshotLevelData.ImageSizeOptions.SCALEWITHMAXSIZE:
			var f = 1.0 / float(level.scale)
			viewport_size = level_extent.size * f
		if level.image_size_option == LevelshotLevelData.ImageSizeOptions.MAXSIZE or (level.image_size_option == LevelshotLevelData.ImageSizeOptions.SCALEWITHMAXSIZE and _is_size_greater(viewport_size, level.size)):
			var v = level.size / level_extent.size
			var f = min(v.x, v.y)
			viewport_size = level_extent.size * f
			_vp.size = viewport_size
		if viewport_size == Vector2.ZERO:
			printerr("LevelshotCapture: invalid image size option value for level %s: option value is %s" % [level.level_scene_path, level.image_size_option])
			return
		
		if viewport_size.x > Image.MAX_WIDTH or viewport_size.y > Image.MAX_HEIGHT:
			viewport_size = Vector2(Image.MAX_WIDTH, Image.MAX_HEIGHT)
			push_warning("LevelshotCapture: resulting image size is > max.  Limiting image size to %s." % viewport_size)
		
		_vp_container.rect_size = viewport_size
		_vp.size = viewport_size
		
		# center camera in level
		camera.global_position = level_extent.position + level_extent.size / 2.0
		
		# zoom camera out so entire level in view
		var zoom_xy = level_extent.size / _vp_container.rect_size
		var zoom = max(zoom_xy.x, zoom_xy.y)
		camera.zoom = Vector2(zoom, zoom)
		
		yield(get_tree(), "idle_frame")
		
		var suffix = "" if level_extents.size() == 1 else "_%d" % (i+1)
		_save_level_image(level.level_scene_path, suffix)
	
	# clean up
	camera.queue_free()
	loaded_level.queue_free()
	yield(get_tree(), "idle_frame")
	print("LevelshotCapture: capture complete for level %s" % level.level_scene_path)
	get_tree().paused = false


func _save_level_image(level_scene_path: String, suffix: String) -> void:
	var image: Image = _vp.get_texture().get_data()
	image.flip_y()
	var base_file_name = level_scene_path.get_file().replace(".tscn", "").replace(".scn", "")
	var image_file_path = "user://%s/%s%s.png" % [_levelshot_data.save_folder, base_file_name, suffix]
	var result = image.save_png(image_file_path)
	if result != OK:
		printerr("Unable to save level image to %s (error code %d)" % [image_file_path, result])

