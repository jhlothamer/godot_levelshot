tool
extends PanelContainer


const LEVEL_CAPTURE_SCENE = "res://addons/levelshot/levelshot_capture.tscn"
const REMOVE_LVL_CONF_MSG = "Are you sure you want to remove\r\n%s\r\nfrom Levelshot?"
const DISABLED_LEVEL_LIST_ITEM_COLOR = Color.gray
const ENABLED_LEVEL_LIST_ITEM_COLOR = Color.white


var editor_interface: EditorInterface


onready var _levels_file_dlg: FileDialog = $LevelsFileDialog
onready var _level_list: ItemList = $MarginContainer/HSplitContainer/LevelsVBoxContainer/levelsItemList
onready var _level_settings = get_node("%LevelSettings")
onready var _general_settings = get_node("%GeneralSettings")
onready var _capture_current_lvl_btn: Button = get_node("%CaptureCurrentLevelBtn")
onready var _capture_all_lvl_btn: Button = get_node("%CaptureAllLevelsBtn")
onready var _remove_lvl_conf_dlg: ConfirmationDialog = get_node("%RemoveLevelConfirmationDialog")
onready var _remove_lvl_conf_lbl: Label = get_node("%RemoveLevelConfirmationLabel")


var _level_data: LevelshotData


func _ready():
	_level_data = LevelshotData.new()
	_level_data.load()
	_refresh_level_list()
	_general_settings.level_data = _level_data
	_capture_all_lvl_btn.disabled = _level_data.levels.size() == 0


func _get_selected_level() -> LevelshotLevelData:
	var selected_items := _level_list.get_selected_items()
	if selected_items.empty():
		return null
	
	var selected_index = selected_items[0]
	
	return _level_list.get_item_metadata(selected_index)


func _refresh_level_list() -> void:
	var selected_level := _get_selected_level()
	_level_list.clear()
	_level_settings.clear()
	for i in _level_data.get_levels():
		var l:LevelshotLevelData = i
		var index = _level_list.get_item_count()
		_level_list.add_item(l.display_name)
		_level_list.set_item_metadata(index, l)
		if l.disabled:
			_level_list.set_item_custom_fg_color(index, DISABLED_LEVEL_LIST_ITEM_COLOR)
		else:
			_level_list.set_item_custom_fg_color(index, ENABLED_LEVEL_LIST_ITEM_COLOR)
		
	_level_list.sort_items_by_text()
	if selected_level == null:
		if _level_list.get_item_count() == 0:
			_capture_current_lvl_btn.disabled = true
		else:
			_capture_current_lvl_btn.disabled = false
			_level_list.select(0)
			_on_levelsItemList_item_selected(0)
		return

	_capture_current_lvl_btn.disabled = false
	for index in _level_list.get_item_count():
		if selected_level == _level_list.get_item_metadata(index):
			_level_list.select(index)
			_on_levelsItemList_item_selected(index)

func _update_data() -> void:
	_level_settings.update_data()
	_general_settings.update_data()
	_level_data.save()


func _on_AddLevelsBtn_pressed():
#	_levels_file_dlg.show()
	_levels_file_dlg.popup_centered()
	_levels_file_dlg.invalidate()


func _on_LevelsFileDialog_files_selected(paths):
	_update_data()
	if _level_data.add_levels(paths):
		_refresh_level_list()
		_capture_all_lvl_btn.disabled = _level_data.levels.size() == 0
		_level_data.save()


func _on_levelsItemList_item_selected(index):
	var level = _level_list.get_item_metadata(index)
	_level_settings.display(level)
	_capture_current_lvl_btn.disabled = level.disabled


func _save_capture_data(level_scene_paths: Array) -> void:
	var capture_data := LevelshotCaptureData.new()
	capture_data.level_scene_paths = level_scene_paths
	capture_data.save()


func _get_all_level_scene_paths() -> Array:
	var level_scene_paths := []
	for i in _level_data.get_levels():
		var l: LevelshotLevelData = i
		if l.disabled:
			continue
		level_scene_paths.append(l.level_scene_path)
	return level_scene_paths


func _on_CaptureCurrentLevelBtn_pressed():
	_update_data()
	_save_capture_data([_level_settings.current_level_data.level_scene_path])
	if editor_interface != null:
		editor_interface.play_custom_scene(LEVEL_CAPTURE_SCENE)


func _on_CaptureAllLevelsBtn_pressed():
	_update_data()
	var level_scene_paths = _get_all_level_scene_paths()
	if level_scene_paths.empty():
		return
	_save_capture_data(level_scene_paths)
	if editor_interface != null:
		editor_interface.play_custom_scene(LEVEL_CAPTURE_SCENE)


func _on_LevelSettings_remove_level_requested():
	_remove_lvl_conf_lbl.text = REMOVE_LVL_CONF_MSG % _level_settings.current_level_data.level_scene_path
	_remove_lvl_conf_dlg.popup_centered()


func _on_RemoveLevelConfirmationDialog_confirmed():
	_level_data.remove_level(_level_settings.current_level_data.level_scene_path)
	_refresh_level_list()





func _on_LevelSettings_level_disabled_toggled(disabled):
	pass # Replace with function body.
	var selected_items := _level_list.get_selected_items()
	var index = selected_items[0]
	if disabled:
		_level_list.set_item_custom_fg_color(index, DISABLED_LEVEL_LIST_ITEM_COLOR)
	else:
		_level_list.set_item_custom_fg_color(index, ENABLED_LEVEL_LIST_ITEM_COLOR)
	_capture_current_lvl_btn.disabled = disabled
