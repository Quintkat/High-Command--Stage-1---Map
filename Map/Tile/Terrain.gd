extends Node

const DEFAULT = "default"
const WATER = "Water"
const LAKE = "Lake"
const PLAINS = "Grassland"
const FOREST = "Forest"
const TAIGA = "Taiga Forest"
const HILLS = "Hills"
const MOUNTAINS = "Mountains"
const SAVANNA = "Savanna"
const DESERT = "Hot Desert"
const FARMLAND = "Farmland"
const CITY = "City"
const BRIDGE = "Bridge"
const ICE = "Ice Sheet"
const RAINFOREST = "Rainforest"
const STEPPES = "Steppes"
const TUNDRA = "Tundra"
const COLDDESERT = "Cold Desert"
const MARSH = "Marsh"

# Used for seeing what colour is associated with a terrain type
const colour = {
	DEFAULT		: Color("#FFFFFF"),
	WATER		: Color("#203165"),
	LAKE		: Color("#487BC2"),
	PLAINS		: Color("#2E7D31"),
	FARMLAND	: Color("#7FC248"),
	MARSH		: Color("#5C5337"),
	CITY		: Color("#ADA08C"),
	BRIDGE		: Color("#494B4A"),
	FOREST		: Color("#155918"),
	RAINFOREST	: Color("#369B3B"),
	HILLS		: Color("#A1BfA2"),
	MOUNTAINS	: Color("#9E9E9E"),
	STEPPES		: Color("#A48458"),
	SAVANNA		: Color("#E0F56C"),
	DESERT		: Color("#FFE999"),
	COLDDESERT	: Color("#D3BCAC"),
	TAIGA		: Color("#435944"),
	TUNDRA		: Color("#A9A4A6"),
	ICE			: Color("#DDE1EC"),
}

# Used for seeing what terrain something is based on a colour (for reading a map image)
var terrain = {}

var sprites = {}

# Used for seeing if a terrain type is land or not
const nonLand = [DEFAULT, WATER, LAKE]


func loadSprites():
	for t in colour:
		sprites[t] = Loading.loadImage(LoadInfo.getGraphicsLocation() + "Terrain/" + t + ".png")
	

func _ready():
	for t in colour:
		terrain[colour[t]] = t


func colour(t : String):
	if !(t in colour):
		return colour[DEFAULT]
	return colour[t]


func terrain(c : Color):
	if !(c in terrain):
		return DEFAULT
	return terrain[c]


func sprite(t : String):
	if !(t in sprites):
		return sprites[DEFAULT]
	return sprites[t]


func land(t : String):
	return !(t in nonLand)


func getAll():
	var list = colour.keys().duplicate()
	list.erase(DEFAULT)
	return list


