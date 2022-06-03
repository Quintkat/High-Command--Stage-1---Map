extends CanvasLayer


func updateInteraction(vis : bool):
	$Panel/VBoxContainer/Save.disabled = !vis
	$Panel/VBoxContainer/Settings.disabled = !vis
	$Panel/VBoxContainer/QuitMenu.disabled = !vis
	$Panel/VBoxContainer/QuitSave.disabled = !vis


func visible(vis : bool):
	$Panel.visible = vis
