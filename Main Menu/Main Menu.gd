extends Control


onready var NewGame = $Buttons/NewGame
onready var NewModdedGame = $Buttons/NewModdedGame
onready var LoadGame = $Buttons/LoadGame
onready var NewGameNamePopup = $NewGameName
onready var PopupMenuList = $PopupMenu

var mode = ""
var gameName : String = ""
var selectedGamedataLocation : String = ""
var selectedSavegameLocation : String = ""


func getDirectories(path : String) -> Array:
	return Directories.getSubDirectories(path)


func _on_PopupMenu_id_pressed(id):
	if mode == "load":
		gameName = PopupMenuList.get_item_text(id)
		LoadInfo.setGameName(gameName)
		LoadInfo.setSavegameLocation(Directories.LOC_SAVEGAME)
		loadLoadInfo()
		initialiseGame()
	elif mode == "new":
		selectedGamedataLocation = Directories.LOC_GAMEDATA + PopupMenuList.get_item_text(id)
		NewGameNamePopup.popup()
	elif mode == "new modded":
		selectedGamedataLocation = Directories.LOC_CUSTOM_GAMEDATA + PopupMenuList.get_item_text(id)
		NewGameNamePopup.popup()
		

func _on_Quit_button_up():
	get_tree().quit()


func _on_LoadGame_button_up():
	mode = "load"
	var saveFiles = getDirectories(Directories.LOC_SAVEGAME)
	saveFiles.sort_custom(self, "sortSaveFiles")
	populateMenuList(saveFiles)
	if !PopupMenuList.visible:
		PopupMenuList.popup()


func sortSaveFiles(a : String, b : String) -> bool:
	var ia = Loading.loadDictFromJSON(Directories.LOC_SAVEGAME + a + "/info.json")
	var ib = Loading.loadDictFromJSON(Directories.LOC_SAVEGAME + b + "/info.json")
	var last = "lastModified"
	var aValid = ia.has(last)
	var bValid = ib.has(last)
	
	if !aValid:
		if !bValid:
			return a < b
		return false
	
	if !bValid:
		if !aValid:
			return a < b
		return true
	
	return ia[last] > ib[last]


func _on_NewModdedGame_button_up():
	mode = "new modded"
	populateMenuList(getDirectories(Directories.LOC_CUSTOM_GAMEDATA))
	if !PopupMenuList.visible:
		PopupMenuList.popup()


func _on_NewGame_button_up():
	mode = "new"
	populateMenuList(getDirectories(Directories.LOC_GAMEDATA))
	if !PopupMenuList.visible:
		PopupMenuList.popup()


func _on_NewGameName_confirmed():
	gameName = NewGameNamePopup.getText()
	initialiseGame()


func populateMenuList(dirs : Array):
	PopupMenuList.clear()
	for i in range(len(dirs)):
		var dir = dirs[i]
		PopupMenuList.add_item(dir, i)


func initialiseGame():
	if mode == "load":
		pass
	elif mode == "new":
		LoadInfo.setGameName(gameName)
		LoadInfo.setGamedataLocation(selectedGamedataLocation)
		LoadInfo.setSavegameLocationAsGameData()
	elif mode == "new modded":
		LoadInfo.setGameName(gameName)
		LoadInfo.setGamedataLocation(selectedGamedataLocation)
		LoadInfo.setSavegameLocationAsGameData()
	
	get_tree().change_scene("res://Game/Game.tscn")


func loadLoadInfo():
	var file = File.new()
	file.open(LoadInfo.getSavegameLocation() + "info.json", File.READ)
	var data = JSON.parse(file.get_as_text()).result
	file.close()
	LoadInfo.setGamedataLocation(data["gamedata"])


func _on_MapEditor_button_up():
	get_tree().change_scene("res://Main Menu/MapEditorPreMenu.tscn")


func _on_Settings_button_up():
	get_tree().change_scene("res://Main Menu/SettingsMenu.tscn")


func _on_Credits_button_up():
	get_tree().change_scene("res://Main Menu/CreditsMenu.tscn")







