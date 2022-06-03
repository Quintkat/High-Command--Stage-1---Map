extends Control

onready var ListPopup = $ListPopup
onready var NewMap = $NewMapName

var mode = ""


func _on_New_button_up():
	mode = "new"
	NewMap.popup()
	LoadInfo.setMapEditorLoading(false)


func _on_NewMap_confirmed():
	LoadInfo.setGameName(NewMap.getText())
	initialiseEditor()


func _on_Load_button_up():
	populateListPopup(Directories.getSubDirectories(Directories.LOC_CUSTOM_GAMEDATA))
	ListPopup.popup()
	mode = "load"
	LoadInfo.setMapEditorLoading(true)


func populateListPopup(dirs : Array):
	ListPopup.clear()
	for i in range(len(dirs)):
		var dir = dirs[i]
		ListPopup.add_item(dir, i)


func _on_Back_button_up():
	get_tree().change_scene("res://Main Menu/Main Menu.tscn")


func _on_ListPopup_id_pressed(id):
	LoadInfo.setGameName(ListPopup.get_item_text(id))
	initialiseEditor()


func initialiseEditor():
	LoadInfo.setGamedataLocation(Directories.LOC_CUSTOM_GAMEDATA + LoadInfo.getGameName())
	get_tree().change_scene("res://Map Editor/Map Editor.tscn")







