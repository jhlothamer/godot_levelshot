tool
extends VBoxContainer

const HEADER_LABEL_STRING_FORMAT = "Level Settings (%s)"

signal remove_level_requested()
signal level_disabled_toggled(disabled)

onready var _level_setings:VBoxContainer = $LevelSettingsVBoxContainer
onready var _none_selected: Control = $NoLevelSelectedCenterContainer

onready var _header_lbl: Label = get_node("%LevelSettingsHeaderLabel")
onready var _size_x:SpinBox = get_node("%SizeXSpinBox")
onready var _size_y:SpinBox = get_node("%SizeYSpinBox")
onready var _level_extent_calc_cb:CheckBox = get_node("%LevelExtentsCalculateCheckBox")
onready var _level_extent_use_ref_rect_cb:CheckBox = get_node("%LevelExtentsLevelshotRefRectCheckBox")
onready var _excluded_node_groups: TextEdit = get_node("%ExcludedNodeGroupsTextEdit")
onready var _include_canvas_layers: CheckBox = get_node("%IncludeCanvasLayersCheckBox")
onready var _disabled:CheckBox = get_node("%DisableLevelshotCheckBox")


var current_level_data: LevelshotLevelData


func _ready():
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
	current_level_data.size.x = _size_x.value
	current_level_data.size.y = _size_y.value
	if _level_extent_calc_cb.pressed:
		current_level_data.level_boundary_option = LevelshotLevelData.LevelBoundaryOptions.CALCULATE
	if _level_extent_use_ref_rect_cb.pressed:
		current_level_data.level_boundary_option = LevelshotLevelData.LevelBoundaryOptions.LEVELSHOTREFRECT
	current_level_data.excluded_node_groups = _excluded_node_groups.text
	current_level_data.include_canvas_layers = _include_canvas_layers.pressed
	current_level_data.disabled = _disabled.pressed


func _on_RemoveLevelBtn_pressed():
	emit_signal("remove_level_requested")


func _on_DisableLevelshotCheckBox_toggled(button_pressed):
	emit_signal("level_disabled_toggled", button_pressed)
