class_name LevelshotNodeUtil
extends Object

static func is_node_in_group(n: Node, node_groups: Array) -> bool:
	for node_group in node_groups:
		if n.is_in_group(node_group):
			return true
	
	return false
