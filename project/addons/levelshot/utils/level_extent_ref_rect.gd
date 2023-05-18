class_name LevelshotLevelExtentFromRefRect
extends LevelshotLevelExtentBase

func _get_level_extents(level_node: Node) -> Array:
	var ref_rects := []
	_get_level_extent_from_levelshot_ref_rects_rec(level_node, ref_rects)
	return ref_rects


func _get_level_extent_from_levelshot_ref_rects_rec(n: Node, ref_rects: Array) -> void:
	if _is_node_skipped(n):
		return

	if n is LevelshotReferenceRect:
		var rr: LevelshotReferenceRect = n
		ref_rects.append(rr.get_global_rect())
	
	for c in n.get_children():
		_get_level_extent_from_levelshot_ref_rects_rec(c, ref_rects)
