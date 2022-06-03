extends Node
class_name Nation

# Basic information
var nName : String
var governmentForm : String
var culture : String = Cultures.DEFAULT

# Resources and population
var resourceTiles = []
var resourceReach = {}
var food = 0	# Keep food seperate since it would be cumbersome to keep track of in the resourceTile method
var population = 0

# Tiles associated with it
var cities = []
var tiles = []
var capital : City
var xCounts = {}
var yCounts = {}

# Diplomacy
var access = []		# Will be reworked entirely later on 


func init(n : String, gf : String, cap : City):
	nName = n
	governmentForm = gf
	capital = cap


func getName() -> String:
	return nName


func fullName() -> String:
	return Nationality.getGovName(nName, governmentForm)


func updateGovernmentForm(gf : String):
	governmentForm = gf


func getGovernmentForm() -> String:
	return governmentForm


func addResourceTile(tile : Tile, pos : Vector2):
	for city in cities:
		if city.getPos().distance_to(pos) <= city.getResourceReach():
			resourceTiles.append(tile)
	
	calcResourceReach()


func removeResourceTile(tile : Tile):
	while tile in resourceTiles:
		resourceTiles.erase(tile)
	
	calcResourceReach()


func calcResourceReach():
	resourceReach = Resources.getCountingList()
	resourceReach[Resources.FOOD] = food
	for tile in resourceTiles:
		resourceReach[tile.getResource()] += 1


func getResourceReach() -> Dictionary:
	return resourceReach


func clearResourceReach():
	resourceReach = Resources.getCountingList()


func getFood() -> int:
	return food


func setPopulation(pop : int):
	population = pop


func addPopulation(pop : int):
	population += pop
	

func getRuralPopulation() -> int:
	var amount = 0
	for tile in tiles:
		amount += tile.getPopulation()
	
	return amount


func getUrbanPopulation() -> int:
	var amount = 0
	for city in cities:
		amount += city.getPopulation()
	
	return amount


func getPopulation() -> int:
	return getRuralPopulation() + getUrbanPopulation()


func addCity(city : City):
	cities.append(city)


func removeCity(city : City):
	if city in cities:
		cities.erase(city)


func getCities() -> Array:
	return cities


func getIC() -> int:
	var total = 0
	for city in cities:
		total += city.getIC()
	
	return total


func addTile(tile : Tile, pos : Vector2):
	tiles.append(tile)
	food += Resources.getTerrainFood(tile.getTerrain())
	if tile.hasResource():
		addResourceTile(tile, pos)
	addCounts(pos)


func removeTile(tile : Tile, pos : Vector2):
	tiles.erase(tile)
	food -= Resources.getTerrainFood(tile.getTerrain())
	if tile.hasResource():
		removeResourceTile(tile)
	removeCounts(pos)


func getTiles() -> Array:
	return tiles


func clearTiles():
	tiles = []
	food = 0


func addCounts(pos : Vector2):
	var x = pos[0]
	var y = pos[1]
	
	if x in xCounts:
		xCounts[x] += 1
	else:
		xCounts[x] = 1
	
	if y in yCounts:
		yCounts[y] += 1
	else:
		yCounts[y] = 1


func removeCounts(pos : Vector2):
	var x = pos[0]
	var y = pos[1]
	
	if x in xCounts:
		xCounts[x] -= 1
	else:
		print("Huh, that's odd (in Nation.removeCounts x section with" + str(pos) + ")")
	
	if y in yCounts:
		yCounts[y] -= 1
	else:
		print("Huh, that's odd (in Nation.removeCounts y section with" + str(pos) + ")")


func getBoundingRectangle() -> Rect2:
	var xKeys = xCounts.keys()
	xKeys.sort()
	var yKeys = yCounts.keys()
	yKeys.sort()
	var xMin = 0
	var yMin = 0
	var xMax = 0
	var yMax = 0
	
	for x in xKeys:
		if xCounts[x] > 0:
			xMin = x
			break
	
	for y in yKeys:
		if yCounts[y] > 0:
			yMin = y
			break
	
	xKeys.invert()
	yKeys.invert()
	for x in xKeys:
		if xCounts[x] > 0:
			xMax = x
			break
	
	for y in yKeys:
		if yCounts[y] > 0:
			yMax = y
			break
	
	var pos = Vector2(xMin, yMin)
	var size = Vector2(xMax, yMax) - pos
	return Rect2(pos, size)


func updateCapital(city : City):
	capital = city


func getCapital() -> City:
	return capital


func setAccess(a : Array):
	access = a


func hasAccess(nationality : String) -> bool:
	return nationality in access


func getAccess() -> Array:
	return access + [nName]


func setCulture(c : String):
	culture = c


func getCulture() -> String:
	return culture


func getSaveData() -> Dictionary:
	var dict = {}
	dict["Government"] = governmentForm
	dict["Culture"] = culture
	if capital == null:
		dict["Capital"] = ""
	else:
		dict["Capital"] = capital.getName()
	dict["Access"] = access
	return dict





