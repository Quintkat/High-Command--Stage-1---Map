extends Node

const DEFAULT = "default"
const BOGARDIA = "Bogardia"
const DELUGIA = "Delugia"
const FLUSSLAND = "Flussland"
const SASBYRG = "Sasbyrg-Tylos"
const TISGYAR = "Tisgyar"
const TROPODEIA = "Tropodeia"
const ZUMOLAIA = "Zumolaia"

var all = []

# Used for seeing what colour is associated with a nationality
var colours = {}

var flags = {}

var govFullName = {}

# Used for seeing what nationality something is based on a colour (for reading a map image)
var nationalities = {}

# The sprites that each tile will display if it is showing its nationality on the map
var sprites = {}


func loadFromFile():
	# First, clear all dicts, since someone might be loading a different save in the same run
	clearData()
	
	# Open file and read json
	var data = Loading.loadDictFromJSON(LoadInfo.getGamedataLocation() + "nationality.json")
	
	# Load the data into the dicts
	for n in data:
		var nationData = data[n]
		colours[n] = Color(nationData["Colour"])
		nationalities[colours[n]] = n
		sprites[n] = Loading.loadImage(LoadInfo.getGraphicsLocation() + "Nationality/" + n + ".png")
		if sprites[n] == null:
			sprites[n] = createColourTexture(colours[n])
		
		govFullName[n] = nationData["Full Names"]
		flags[n] = Loading.loadImage(LoadInfo.getGraphicsLocation() + "Flags/" + n + ".png")
		all.append(n)
	
	# Add entry for default
	colours[DEFAULT] = Color("#FFFFFF")
	sprites[DEFAULT] = Loading.loadImage(LoadInfo.getGraphicsLocation() + "Nationality/" + DEFAULT + ".png")
	flags[DEFAULT] = Loading.loadImage(LoadInfo.getGraphicsLocation() + "Flags/" + DEFAULT + ".png")


func clearData():
	colours = {}
	nationalities = {}
	sprites = {}
	govFullName = {}
	flags = {}
	all = []
	

func createColourTexture(c : Color) -> ImageTexture:
	var img = Image.new()
	var size = TileConstants.SIZE
	img.create(size*3, size, false, Image.FORMAT_RGBA8)
	img.lock()
	
	var c0 = c
	var c1 = Color(c.r, c.g, c.b, 0.666)
	var c2 = Color(c.r, c.g, c.b, 0.333)
	for x in range(size):
		for y in range(size):
			img.set_pixel(x, y, c0)
			img.set_pixel(x + size, y, c1)
			img.set_pixel(x + 2*size, y, c2)
	
	var texture = ImageTexture.new()
	texture.create_from_image(img)
	return texture


func colour(n) -> Color:
	if !(n in colours):
		return colours[DEFAULT]
	return colours[n]


func nationality(c) -> String:
	if !(c in nationalities):
		return DEFAULT
	return nationalities[c]


func sprite(n) -> Color:
	if !(n in sprites):
		return sprites[DEFAULT]
	return sprites[n]


func getGovNameLineBreakThe(nat : String, gf : String) -> String:
	if !(gf in govFullName[nat]):
		return nat
	elif govFullName[nat][gf] == "":
		return nat
	return govFullName[nat][gf]


func getGovNameLineBreak(nat : String, gf : String) -> String:
	var full = getGovNameLineBreakThe(nat, gf)
	if full.substr(0, 4) == "The ":
		return full.substr(4, len(full))
	
	return full


func getGovNameThe(nat : String, gf : String) -> String:
	return getGovNameLineBreakThe(nat, gf).replace("\n", " ")


func getGovName(nat : String, gf : String) -> String:
	var full = getGovNameLineBreak(nat, gf)
	return full.replace("\n", " ")
	

func getAll() -> Array:
	return all


func getFlag(nat : String) -> Texture:
	return flags[nat]



################################
# Functions for the map editor #
################################

func saveToFile(path : String):
	var filePath = path + "nationality.json"
	var dict = {}
	for nat in getAll():
		dict[nat] = {
			"Colour"		:	colours[nat].to_html(false),
			"Full Names"	:	govFullName[nat]
		}
		
	Saving.saveDictToJSON(filePath, dict)


func addNationality(nat : String, col : Color):
	if nat == DEFAULT:
		return
	colours[nat] = col
	nationalities[col] = nat
	sprites[nat] = sprite(DEFAULT)
	govFullName[nat] = {}
	flags[nat] = null
	all.append(nat)


func overwriteSprite(nat : String, texture : ImageTexture):
	if nat == DEFAULT:
		return
	sprites[nat] = texture


func overwriteFullNames(nat : String, names : Dictionary):
	govFullName[nat] = names


func editColour(nat : String, col : Color):
	if nat == DEFAULT:
		return
	nationalities.erase(colours[nat])
	colours[nat] = col
	nationalities[col] = nat


func removeNationality(nat : String):
	if nat == DEFAULT:
		return
	nationalities.erase(colours[nat])
	colours.erase(nat)
	sprites.erase(nat)
	govFullName.erase(nat)
	flags.erase(nat)
	all.erase(nat)


func getColours() -> Array:
	return colours.values()


func getFullNames(nat : String):
	return govFullName[nat]








