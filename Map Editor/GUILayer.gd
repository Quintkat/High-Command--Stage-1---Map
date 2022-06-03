extends CanvasLayer


func updateVisibility(vis : bool):
	var children = get_children()
	for child in children:
		if !(child is Popup):
			child.visible = vis
