tool
extends VBoxContainer


const HEADER_LABEL_STRING_FORMAT = "Level Settings (%s)"
const SCALE_HELPER_TEXT_STRING_FORMAT = "(image will be %s%% of level size)"


signal remove_level_requested()
signal level_disabled_toggled(disabled)


onready var _level_setings:VBoxContainer = $LevelSettingsVBoxContainer
onready var _none_selected: Control = $NoLevelSelectedCenterContainer
onready var _header_lbl: Label = get_node("%LevelSettingsHeaderLabel")
# image size
onready var _image_size_scale_cb:CheckBox = get_node("%SizeOptionScaleCheckBox")
onready var _image_size_max_size_cb:CheckBox = get_node("%SizeOptionMaxCheckBox")
onready var _image_size_scale_with_max_size_cb:CheckBox = get_node("%ScaleWithMaxMaxCheckBox")
onready var _scale:SpinBox = get_node("%ScaleSpinBox")
onready var _scale_helper_lbl:Label = get_node("%ScaleHelperLabel")
onready var _size_x:SpinBox = get_node("%SizeXSpinBox")
onready var _size_y:SpinBox = get_node("%SizeYSpinBox")
# level boundary
onready var _level_extent_calc_cb:CheckBox = get_node("%LevelExtentsCalculateCheckBox")
onready var _level_extent_use_ref_rect_cb:CheckBox = get_node("%LevelExtentsLevelshotRefRectCheckBox")
# other
onready var _excluded_node_groups: TextEdit = get_node("%ExcludedNodeGroupsTextEdit")
onready var _include_canvas_layers: CheckBox = get_node("%IncludeCanvasLayersCheckBox")
onready var _disabled:CheckBox = get_node("%DisableLevelshotCheckBox")


var current_level_data: LevelshotLevelData


func _ready():
	if OK != _scale.get_line_edit().connect("text_changed", self, "_on_ScaleSpinBox_line_edit_text_changed"):
		printerr("Could not connect to spin box text edit text_change signal")
	clear()


func clear() -> void:
	current_level_data = null
	_level_setings.visible = false
	_none_selected.visible = true


func display(level_data: LevelshotLevelData) -> void:
	if current_level_data != null:
		update_data()
	
	current_level_data = level_data
	
	_header_lbl.text = HEADER_LABEL_STRING_FORMAT % level_data.display_name
	_image_size_scale_cb.pressed = level_data.image_size_option == LevelshotLevelData.ImageSizeOptions.SCALE
	_image_size_max_size_cb.pressed = level_data.image_size_option == LevelshotLevelData.ImageSizeOptions.MAXSIZE
	_image_size_scale_with_max_size_cb.pressed = level_data.image_size_option == LevelshotLevelData.ImageSizeOptions.SCALEWITHMAXSIZE
	_scale.value = level_data.scale
	_size_x.value = level_data.size.x
	_size_y.value = level_data.size.y
	_level_extent_calc_cb.pressed = level_data.level_boundary_option == LevelshotLevelData.LevelBoundaryOptions.CALCULATE
	_level_extent_use_ref_rect_cb.pressed = level_data.level_boundary_option == LevelshotLevelData.LevelBoundaryOptions.LEVELSHOTREFRECT
	_excluded_node_groups.text = level_data.excluded_node_groups
	_include_canvas_layers.pressed = level_data.include_canvas_layers
	_disabled.pressed = level_data.disabled
	_level_setings.visible = true
	_none_selected.visible = false


func update_data():
	if current_level_data == null:
		return
	if _image_size_scale_cb.pressed:
		current_level_data.image_size_option = LevelshotLevelData.ImageSizeOptions.SCALE
	elif _image_size_max_size_cb.pressed:
		current_level_data.image_size_option = LevelshotLevelData.ImageSizeOptions.MAXSIZE
	elif _image_size_scale_with_max_size_cb.pressed:
		current_level_data.image_size_option = LevelshotLevelData.ImageSizeOptions.SCALEWITHMAXSIZE
	else:
		printerr("LevelSettingsControl: cannot set image size option!")
	current_level_data.scale = int(_scale.value)
	current_level_data.size.x = _size_x.value
	current_level_data.size.y = _size_y.value
	if _level_extent_calc_cb.pressed:
		current_level_data.level_boundary_option = LevelshotLevelData.LevelBoundaryOptions.CALCULATE
	elif _level_extent_use_ref_rect_cb.pressed:
		current_level_data.level_boundary_option = LevelshotLevelData.LevelBoundaryOptions.LEVELSHOTREFRECT
	else:
		printerr("LevelSettingsControl: cannot set level boundary option!")
	current_level_data.excluded_node_groups = _excluded_node_groups.text
	current_level_data.include_canvas_layers = _include_canvas_layers.pressed
	current_level_data.disabled = _disabled.pressed


func _on_RemoveLevelBtn_pressed():
	emit_signal("remove_level_requested")


func _on_DisableLevelshotCheckBox_toggled(button_pressed):
	emit_signal("level_disabled_toggled", button_pressed)


func _on_ScaleSpinBox_value_changed(value):
	var percentage = int(100.0/float(value))
	_scale_helper_lbl.text = SCALE_HELPER_TEXT_STRING_FORMAT % percentage


func _on_ScaleSpinBox_line_edit_text_changed(new_text: String):
	new_text = new_text.strip_edges()
	if !new_text.is_valid_integer():
		return
	
	var percentage = int(100.0/float(new_text))
	_scale_helper_lbl.text = SCALE_HELPER_TEXT_STRING_FORMAT % percentage
	


