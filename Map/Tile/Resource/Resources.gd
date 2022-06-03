extends Node

const OIL = "Oil"
const STEEL = "Steel"
const SULPHUR = "Sulphur"
const ALUMINIUM = "Aluminium"
const FOOD = "Food"
const NONE = "None"

const all = [OIL, STEEL, SULPHUR, ALUMINIUM, FOOD]
const tiled = [OIL, STEEL, SULPHUR, ALUMINIUM]

var textures = {}
var defaultTexture = ImageTexture.new()

const colours = {
	NONE		:	Color("#FFFFFF"),
	OIL			: 	Color("#000000"),
	STEEL		: 	Color("#000CFF"),
	SULPHUR		: 	Color("#FFE100"),
	ALUMINIUM	: 	Color("#FF0010"),
}

var resources = {}

var food = {
	Terrain.FARMLAND	:	3,
	Terrain.PLAINS		:	1,
#	Terrain.SAVANNA		:	0,
}


func loadFromFile():
	# Since the resources are pre-defined, only the textures have to be reloaded
	textures = {}
	for r in tiled:
		var t = Loading.loadImage(LoadInfo.getGraphicsLocation() + "Resources/" + r + ".png")
		
		# If the texture could not be loaded, load a standard one
		if t == null:
			t = Loading.loadImage(Directories.LOC_SPRITES + "Base Sprites/Resources/" + r + ".png")
		textures[r] = t


func _init():
	for r in colours:
		resources[colours[r]] = r


func colour(r : String):
	if !(r in colours):
		return colours[NONE]
	return colours[r]


func resource(c : Color):
	if !(c in resources):
		return NONE
	return resources[c]


func texture(r):
	if !(r in textures):
		return defaultTexture
	return textures[r]


func getCountingList() -> Dictionary:
	var result = {}
	for r in all:
		result[r] = 0
	
	return result
	

func getTerrainFood(terrain : String):
	if !(terrain in food):
		return 0
	else:
		return food[terrain]

