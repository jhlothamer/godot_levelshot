tool
extends EditorPlugin


const MAIN_SCENE = preload("res://addons/levelshot/levelshot_mgmt.tscn")
const PLUGIN_ICON = preload("res://addons/levelshot/assets/icons/camera.svg")

var _main_scene: Control


func _enter_tree() -> void:
	# force addition of settings
	var _discard = LevelshotSettings.get_data_folder()
	_discard = LevelshotSettings.get_data_file_name_pattern()
	
	_main_scene = MAIN_SCENE.instance()
	var editor_interface := get_editor_interface()
	_main_scene.editor_interface = editor_interface
	editor_interface.get_editor_viewport().add_child(_main_scene)
	make_visible(false)


func _exit_tree() -> void:
	if _main_scene:
		_main_scene.queue_free()
		_main_scene = null


func has_main_screen() -> bool:
	return true


func make_visible(visible: bool) -> void:
	if _main_scene:
		_main_scene.visible = visible


func get_plugin_name() -> String:
	return "Levelshot"


func get_plugin_icon() -> Texture:
	return PLUGIN_ICON
