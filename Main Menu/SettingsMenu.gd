extends Control


onready var ListPopup = $ListPopup

var graphicsSelectionPaths = {}


func _on_Graphics_button_up():
	var gpStandard = Directories.getSubDirectories(Directories.LOC_SPRITES)
	var gpModded = Directories.getSubDirectories(Directories.LOC_CUSTOM_SPRITES)
	var graphicsPacks = []
	graphicsSelectionPaths = {}
	for i in range(len(gpStandard)):
		graphicsSelectionPaths[i] = Directories.LOC_SPRITES + gpStandard[i]
		graphicsPacks.append(gpStandard[i])
	for i in range(len(gpModded)):
		graphicsSelectionPaths[i + len(gpStandard)] = Directories.LOC_CUSTOM_SPRITES + gpModded[i]
		graphicsPacks.append(gpModded[i])
	
	populateListPopup(graphicsPacks)
	if !ListPopup.visible:
		ListPopup.popup()


func _on_PopupMenu_id_pressed(id):
	LoadInfo.setGraphicsLocation(graphicsSelectionPaths[id])
	Settings.updateGraphicsLocation(graphicsSelectionPaths[id])
	print(graphicsSelectionPaths[id])


func populateListPopup(dirs : Array):
	ListPopup.clear()
	for i in range(len(dirs)):
		var dir = dirs[i]
		ListPopup.add_item(dir, i)


func _on_UserFolder_pressed():
	var userPath = ProjectSettings.globalize_path("user://")
	print(userPath)
	OS.shell_open("file://" + userPath)


func _on_Back_button_up():
	get_tree().change_scene("res://Main Menu/Main Menu.tscn")




