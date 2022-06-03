extends Node

var gameName : String = "editor testing"
#var gamedataLocation : String = Directories.LOC_GAMEDATA + "Base/"
#var savegameLocation : String = Directories.LOC_GAMEDATA + "Base/"
#var graphicsLocation : String = Directories.LOC_SPRITES + "Base Sprites/"

var gamedataLocation : String = Directories.LOC_CUSTOM_GAMEDATA + gameName + "/"
var savegameLocation : String = Directories.LOC_GAMEDATA + "Base/"
var graphicsLocation : String = Directories.LOC_SPRITES + "Base Sprites/"

# Only used for map editor
var mapEditorLoading : bool = true


func setGameName(n : String):
	gameName = n


func getGameName() -> String:
	return gameName


func setGamedataLocation(path : String):
	gamedataLocation = path
	if gamedataLocation[-1] != "/":
		gamedataLocation += "/"


func getGamedataLocation() -> String:
	return gamedataLocation


func setSavegameLocationAsGameData():
	savegameLocation = gamedataLocation


func setSavegameLocation(path : String):
	savegameLocation = path + gameName + "/"


func getSavegameLocation() -> String:
	return savegameLocation


func setGraphicsLocation(path : String):
	graphicsLocation = path
	if graphicsLocation[-1] != "/":
		graphicsLocation += "/"
		

func getGraphicsLocation() -> String:
	return graphicsLocation


func setMapEditorLoading(b : bool):
	mapEditorLoading = b


func isMapEditorLoading() -> bool:
	return mapEditorLoading


func loadAutoloaded():
	Cultures.loadFromFile()
	Nationality.loadFromFile()
	Resources.loadFromFile()
	Terrain.loadSprites()
	Population.resetRNG()
