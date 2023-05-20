class_name LevelshotLevelExtentBase
extends Reference

var _include_canvas_layer: bool
var _exclude_node_groups := []

func get_level_extents(level_node: Node, include_canvas_layer: bool, exclude_node_groups: Array) -> Array:
	_include_canvas_layer = include_canvas_layer
	_exclude_node_groups = exclude_node_groups
	return _get_level_extents(level_node)

func _get_level_extents(_level_node: Node) -> Array:
	return []


func _is_node_skipped(n: Node) -> bool:
	
	n.pause_mode = Node.PAUSE_MODE_STOP
	
	if LevelshotNodeUtil.is_node_in_group(n, _exclude_node_groups) and (n is CanvasItem or n is Control):
		n.visible = false
		return true
	
	if n is CanvasLayer and !n is ParallaxBackground and !_include_canvas_layer:
		n.visible = false
		return true

	if n is CanvasItem and !n.visible:
		return true
	
	if n is Camera2D:
		n.queue_free()
		return true

	return false
