extends Node

const DEFAULT = "default"

var colours = {}
var cultures = {}
var sprites = {}
var all = []


func loadFromFile():
	# First, clear both dicts, since someone might be loading a different save in the same run
	clearData()
	
	# Open file and read json
	var data = Loading.loadDictFromJSON(LoadInfo.getGamedataLocation() + "cultures.json")
#	var path = LoadInfo.getGamedataLocation() + "cultures.json"
#	var file = File.new()
#	file.open(path, File.READ)
##	var data = JSON.parse(file.get_as_text()).result
#	file.close()
	
#	# Add entry for default
#	data[DEFAULT] = Color("#FFFFFF")
	
	# Load the data into the dicts
	for c in data:
		colours[c] = Color(data[c])
		cultures[colours[c]] = c	# The data given is the string which is used for making the colour :>
		sprites[c] = Loading.loadImage(LoadInfo.getGraphicsLocation() + "Culture/" + c + ".png")
		all.append(c)
	
	colours[DEFAULT] = Color("#FFFFFF")
	sprites[DEFAULT] = Loading.loadImage(LoadInfo.getGraphicsLocation() + "Culture/" + DEFAULT + ".png")


func clearData():
	colours = {}
	cultures = {}
	sprites = {}
	all = []


func colour(c : String) -> Color:
	if !(c in colours):
		return colours[DEFAULT]
	return colours[c]


# Returns the culture associated with a certain colour
func culture(color : Color) -> String:
	if !(color in cultures):
		return DEFAULT
	return cultures[color]


# Returns the sprite associated with a certain culture
func sprite(c : String) -> ImageTexture:
	if !(c in sprites):
		return sprites[DEFAULT]
	return sprites[c]


func getAll():
	return all



################################
# Functions for the map editor #
################################

func saveToFile(path : String):
	var filePath = path + "cultures.json"
	var dict = {}
	for culture in getAll():
		dict[culture] = colours[culture].to_html(false)
		
	Saving.saveDictToJSON(filePath, dict)


func addCulture(culture : String, col : Color):
	if culture == DEFAULT:
		return
	colours[culture] = col
	cultures[col] = culture
	sprites[culture] = sprite(DEFAULT)
	all.append(culture)


func overwriteSprite(culture : String, texture : ImageTexture):
	if culture == DEFAULT:
		return
	sprites[culture] = texture



func editColour(culture : String, col : Color):
	if culture == DEFAULT:
		return
	cultures.erase(colours[culture])
	colours[culture] = col
	cultures[col] = culture


func removeCulture(culture : String):
	if culture == DEFAULT:
		return
	cultures.erase(colours[culture])
	colours.erase(culture)
	sprites.erase(culture)
	all.erase(culture)


func getColours() -> Array:
	return colours.values()



