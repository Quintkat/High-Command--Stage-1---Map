extends Node


func getTypeCount(node, type, c = 1) -> int:
	var count = 0
	for child in node.get_children():
		if child is type:
			count += c
		count += getTypeCount(child, type, c)
	
	return count


func getControlCount(node) -> int:
	return getTypeCount(node, Control)
