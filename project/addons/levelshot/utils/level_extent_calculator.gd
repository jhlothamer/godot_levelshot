class_name LevelshotLevelExtentCalculator
extends Reference

const ZERO_RECT = Rect2(Vector2.ZERO, Vector2.ZERO)

var _include_canvas_layer: bool
var _exclude_node_groups := []

func get_level_extent(level_node: Node, include_canvas_layer: bool, exclude_node_groups: Array) -> Rect2:
	
	_include_canvas_layer = include_canvas_layer
	_exclude_node_groups = exclude_node_groups
	
	return _get_node_extent_rec(level_node)


func _is_node_excluded_on_group(n: Node) -> bool:
	for node_group in _exclude_node_groups:
		if n.is_in_group(node_group):
			return true
	
	return false


func _get_node_extent_rec(n: Node) -> Rect2:

	if _is_node_excluded_on_group(n):
		n.visible = false
		return ZERO_RECT
	
	if n is CanvasLayer and !_include_canvas_layer:
		n.visible = false
		return ZERO_RECT
	if n is CanvasItem and !n.visible:
		return ZERO_RECT
	
	if n is Camera2D:
		#n.current = false
		n.queue_free()
		return ZERO_RECT
	
	var extent := _get_node_extent(n)
	
	for c in n.get_children():
		var child_extent := _get_node_extent_rec(c)
		if child_extent.size == Vector2.ZERO:
			continue
		if extent.size == Vector2.ZERO:
			extent = child_extent
		else:
			extent = extent.merge(child_extent)

	return extent


func _get_node_extent(n: Node) -> Rect2:
	if n is Control:
		return _get_node_extent_control(n)
	if n is Polygon2D:
		return _get_node_extent_polygon2d(n)
	if n is Sprite:
		return _get_node_extent_sprite(n)
	if n is TileMap:
		return _get_node_extent_tilemap(n)
	if n is MultiMeshInstance2D:
		return _get_node_extent_multimeshinstance2d(n)

	return ZERO_RECT


func _get_node_extent_control(c: Control) -> Rect2:
	if c is ReferenceRect and c.editor_only:
		return ZERO_RECT
	return Rect2(c.rect_global_position, c.rect_size)


func _get_node_extent_polygon2d(p: Polygon2D) -> Rect2:
	var min_v := Vector2.INF
	var max_v := Vector2.INF
	
	for i in p.polygon:
		var pt: Vector2 = i
		pt = p.to_global(pt)
		if min_v == Vector2.INF:
			min_v = pt
		else:
			if min_v.x > pt.x:
				min_v.x = pt.x
			if min_v.y > pt.y:
				min_v.y = pt.y
		if max_v == Vector2.INF:
			max_v = pt
		else:
			if max_v.x < pt.x:
				max_v.x = pt.x
			if max_v.y < pt.y:
				max_v.y = pt.y
	
	return Rect2(min_v, max_v - min_v)


func _get_node_extent_sprite(s: Sprite) -> Rect2:
	var r = s.get_rect()
	return Rect2(s.to_global(r.position), r.size)


func _get_node_extent_tilemap(t: TileMap) -> Rect2:
	var r = t.get_used_rect()
	return Rect2(t.to_global(r.position), r.size)



func _get_node_extent_multimeshinstance2d(m: MultiMeshInstance2D) -> Rect2:
		var mm := m.multimesh
		var aabb := mm.get_aabb()
		
		var pos = Vector2(aabb.position.x, aabb.position.y)
		pos = m.to_global(pos)
		var size = Vector2(aabb.size.x, aabb.size.y)
	
		return Rect2(pos, size)



