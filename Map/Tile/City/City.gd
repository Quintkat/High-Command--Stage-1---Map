extends Node2D
class_name City


# Children
onready var Road = $Road

# City info
var cityName : String = ""
var IC : int = 0
var population : int = 0
var gridPos : Vector2 = Vector2(0, 0)

# City image filepaths
const imgSmall = "citySmall.png"
const imgMedium = "cityMedium.png"
const imgLarge = "cityLarge.png"
const imgIndustry = "cityIndustry.png"

# IC constants
const icSmall = 3
const icMedium = 7
const icLarge = 20
#const emptyName = "Industrial Zone"

## Population constants
#const popMedium = 100000
#const popLarge = 500000

# Graphics constants
const buildingNodeName = "BuildingSlot"
const maxBuildingSlots = 6
const roads23 = "roads2-3.png"
const roads45 = "roads4-5.png"
const roads6 = "roads6.png"
const buildingSmallNoIC = "buildingSmallNoIC.png"
const buildingSmall = "buildingSmall.png"
const buildingMedium = "buildingMedium.png"
const buildingLarge = "buildingLarge.png"
const buildingIndustry = "buildingIndustry.png"
const popLevels = {
	1 : buildingSmall,
	2 : buildingMedium,
	3 : buildingLarge
}
const radius = 50



func init(n : String, pop : int, ic : int, pos : Vector2):
	updateName(n)
	updatePopulation(pop)
	updateIC(ic)
	gridPos = pos


func updateName(n : String):
	cityName = n


func getName():
	return cityName


func updatePopulation(pop : int):
	population = pop
	updateGraphics()


func updateIC(ic : int):
	IC = ic
	updateGraphics()


func updateGraphics():
	var popLevel = getPopLevel()
	var icLevel = getICLevel()
	var totalLevel = popLevel + icLevel
	clearBuildingGraphics()
	
	if totalLevel == 1:
		Road.texture = null
		var building = get_node(buildingNodeName + "1")
		building.texture = getBuildingTexture(buildingSmallNoIC)
		building.position = TileConstants.SIZE*Vector2(1, 1)/2
		return
	elif totalLevel == 2 or totalLevel == 3:
		Road.texture = getRoadTexture(roads23)
	elif totalLevel == 4 or totalLevel == 5:
		Road.texture = getRoadTexture(roads45)
	else:
		Road.texture = getRoadTexture(roads6)
	
	var i = 1
	while i < icLevel + 1:
		var building = get_node(buildingNodeName + str(i))
		building.texture = getBuildingTexture(buildingIndustry)
		i += 1
	
	while i < icLevel + popLevel + 1:
		var building = get_node(buildingNodeName + str(i))
		building.texture = getBuildingTexture(popLevels[popLevel])
		i += 1
	
	positionBuildings(totalLevel)


func positionBuildings(n : int):
	var center = TileConstants.SIZE*Vector2(1, 1)/2
	for i in range(n):
		var building = get_node(buildingNodeName + str(i + 1))
		building.position = center + radius*Vector2(cos(i*2*PI/n), -sin(i*2*PI/n))


func clearBuildingGraphics():
	for i in range(1, maxBuildingSlots + 1):
		get_node(buildingNodeName + str(i)).texture = null


func getPopLevel() -> int:
	if population < Population.getCityGraphicsMedium():
		return 1
	elif population < Population.getCityGraphicsLarge():
		return 2
	else:
		return 3


func getICLevel() -> int:
	if IC < icSmall:
		return 0
	elif IC < icMedium:
		return 1
	elif IC < icLarge:
		return 2
	else:
		return 3


func getIC():
	return IC


func getBuildingTexture(path : String):
	return Loading.loadImage(LoadInfo.getGraphicsLocation() + "City/Buildings/" + path)
	

func getRoadTexture(path : String):
	return Loading.loadImage(LoadInfo.getGraphicsLocation() + "City/Roads/" + path)


func getTexture(path : String):
	return Loading.loadImage(LoadInfo.getGraphicsLocation() + "City/" + path)


func getResourceReach() -> float:
	if IC < icMedium:
		return 1.0
	elif IC < icLarge:
		return 1.5
	else:
		return 2.25


func getPopulation() -> int:
	return population


func getPos() -> Vector2:
	return gridPos


func getSaveData() -> Dictionary:
	var dict = {}
	dict["x"] = getPos()[0]
	dict["y"] = getPos()[1]
	dict["ic"] = getIC()
	dict["pop"] = getPopulation()
	return dict













