extends Node


const LOC_GAMEDATA = "res://Map/Map Data/"
const LOC_CUSTOM_GAMEDATA = "user://gamedata/"
const LOC_SAVEGAME = "user://savegame/"
const LOC_SPRITES = "res://Graphics/"
const LOC_CUSTOM_SPRITES = "user://graphics/"
const LOC_SETTINGS = "user://settings.cfg"


func getSubDirectories(path : String) -> Array:
	var dir = Directory.new()
	if !dir.dir_exists(path):
		dir.make_dir_recursive(path)
		return []
		
	var dirs = []
	dir.open(path)
	dir.list_dir_begin(true)
	var next = dir.get_next()
	while next != "":
		dirs.append(next)
		next = dir.get_next()
	
	return dirs
