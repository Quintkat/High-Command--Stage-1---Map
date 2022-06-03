extends Node

var config

const SEC_GRAPHICS = "Graphics"
const GRAPHICS_LOC = "location"


func _ready():
	config = ConfigFile.new()
	var file = File.new()
	if !file.file_exists(Directories.LOC_SETTINGS):
		config.set_value(SEC_GRAPHICS, GRAPHICS_LOC, LoadInfo.getGraphicsLocation())
		save()
	
	if config.load(Directories.LOC_SETTINGS) != OK:
		return
	
	LoadInfo.setGraphicsLocation(config.get_value(SEC_GRAPHICS, GRAPHICS_LOC))


func save():
	config.save(Directories.LOC_SETTINGS)


func updateGraphicsLocation(loc : String):
	config.set_value(SEC_GRAPHICS, GRAPHICS_LOC, loc)
	save()

