extends Node2D
class_name Tile

# Tile children info
onready var RTerrain = $Terrain
onready var RNationality = $Nationality
onready var RCulture = $Culture
var selection
const selectionScene = preload("res://Map/Tile/Selection.tscn")
const selectionImgPath = "res://Map/Tile/Selection.png"
const selectionSubgribImgPath = "res://Map/Tile/SelectionSubgrid.png"

# Tile size info
const subgridSize = 3
onready var size : int = TileConstants.SIZE

# Borders
const bordersScene = preload("res://Map/Tile/Borders.tscn")
var borders : Borders = null
const borderDarkenAmount = 0.25
const borderOpacityOffset = 0.75

# City
var city : City = null

# River
var river : RiverTile = null

# Infrastructure
const roadScene = preload("res://Map/Tile/Infrastructure/Road.tscn")
const roadSmallScene = preload("res://Map/Tile/Infrastructure/SmallRoad.tscn")
const railroadScene = preload("res://Map/Tile/Infrastructure/Railroad.tscn")
const airbaseScene = preload("res://Map/Tile/Infrastructure/Airbase.tscn")
var road = null
var railroad = null
var roadSmall = null
var airbase = null

# Resource
const resourceScene = preload("res://Map/Tile/Resource/Resource.tscn")
var resource = null

# Tile info
var terrain : String
var nationality : String
var culture : String
var population : int = 0

# Misc
const cardinals = ["North", "East", "South", "West"]


# The initialisation of each tile
func init(pos : Vector2):
	position = pos*size


# The starting procedure for each tile after initialisation (eg. this procedure is the exact same for every tile)
func _ready():
	updateTerrain(Terrain.WATER)
	updateNationality(Nationality.DEFAULT)


func updateTerrain(t : String):
	terrain = t
	RTerrain.texture = Terrain.sprite(terrain)


func updateNationality(n : String):
	nationality = n
	RNationality.texture = Nationality.sprite(n)
#	if nationality == Nationality.DEFAULT:
#		RNationality.visible = false


func updateCulture(c : String):
	culture = c
	RCulture.texture = Cultures.sprite(culture)
#	if culture == Cultures.DEFAULT:
#		RCulture.visible = false


func reloadGraphics():
	RTerrain.texture = Terrain.sprite(terrain)
	RNationality.texture = Nationality.sprite(nationality)
	RCulture.texture = Cultures.sprite(culture)


# Pass a list to this function of borders the tile should display
func updateBorders(borderList : Array):
	if len(borderList) > 0:
		if borders == null:
			addBorders()
		borders.updateState(borderList)
	else:
		if borders == null:
			return
		borders.queue_free()
		borders = null


func updateCultureVisibility(vis : bool):
	if !isLand():
		RCulture.visible = false
	else:
		RCulture.visible = vis


func updateNationalityVisibility(nat : float):
	if !isLand():
		RNationality.visible = false
	else:
		if nat == 0:
			RNationality.visible = false
		else:
			RNationality.visible = true
			RNationality.frame = 3 - 3*nat
		
		if borders != null:
			borders.updateWidth(nat*0.5 + 0.5)


func updateNationalityVisibilityBool(vis : bool):
	if !isLand():
		RNationality.visible = false
	elif vis:
		RNationality.visible = true
		RNationality.frame = 0
	else:
		RNationality.visible = false


func isLand():
	return Terrain.land(terrain)


func colourOpacity(c : Color, a : float):
	return Color(c.r, c.g, c.b, a)


# Used by updateBorders()
func addBorders():
	borders = bordersScene.instance()
	add_child(borders)
	borders.init(size, subgridSize, Nationality.colour(nationality).darkened(borderDarkenAmount))


func getSize():
	return size


func getSubgridSize():
	return subgridSize


func getSubtileSize():
	return size/subgridSize


func getTerrain():
	return terrain


func getNationality():
	return nationality


func getCulture():
	return culture


func updateBorderColour(c : Color):
	if borders != null:
		borders.updateColour(c)


func updateBorderVisibility(vis : bool):
	if borders != null:
		borders.visible = vis


func updateOrder():
	var cc = get_child_count()
	# The basic things of a tile
	moveToFront(RTerrain, cc)
	moveToFront(RCulture, cc)
	moveToFront(RNationality, cc)
	
	# Specific features
	moveToFront(borders, cc)
	moveToFront(river, cc)
	moveToFront(roadSmall, cc)
	moveToFront(road, cc)
	moveToFront(railroad, cc)
	moveToFront(airbase, cc)
	moveToFront(resource, cc)
	moveToFront(city, cc)
	moveToFront(selection, cc)


func moveToFront(child, cc : int):
	if child != null:
		move_child(child, cc)


func select():
	if selection != null:
		return	# In this case, there is already a selection tile instanced
	
	selection = selectionScene.instance()
	add_child(selection)
	moveToFront(selection, get_child_count())


func selectSubtile(pos : Vector2):
	select()
	selection.rect_position = pos*size/subgridSize
	selection.rect_scale = Vector2(1, 1)/subgridSize


func deselect():
	if selected():
		remove_child(selection)
		selection.queue_free()
		selection = null


func selected() -> bool:
	return selection != null


func addCity(c : City):
	city = c
	add_child(city)


func removeCity():
	remove_child(city)
	city.queue_free()
	city = null


func getCityName() -> String:
	if city == null:
		return ""
	else:
		return city.cityName


func hasCity() -> bool:
	return city != null


func getCity() -> City:
	return city


func updateCityVisibility(vis : bool):
	if hasCity():
		city.visible = vis


func addRoad():
	if road == null:
		road = roadScene.instance()		# widepeepoHappy
		add_child(road)


func removeRoad():
	if road != null:
		remove_child(road)
		road.queue_free()
		road = null


func hasRoad() -> bool:
	return road != null


func updateRoads(neighbours : Dictionary):
	if !hasRoad():
		return
	
	var nVis = 0
	for dir in cardinals:
		if neighbours[dir] != null:
			road.get_node(dir).visible = neighbours[dir].hasRoad()
			if neighbours[dir].hasRoad():
				nVis += 1
		else:
			road.get_node(dir).visible = false
	
	# So if no neighbours are infrastructure, all directions are shown so that this isn't invisible
	if nVis == 0:
		for dir in cardinals:
			road.get_node(dir).visible = true


func updateRoadVisibility(vis : bool):
	if hasRoad():
		road.visible = vis


func addSmallRoad():
	if roadSmall == null:
		roadSmall = roadSmallScene.instance()		# widepeepoHappy
		add_child(roadSmall)


func removeSmallRoad():
	if roadSmall != null:
		remove_child(roadSmall)
		roadSmall.queue_free()
		roadSmall = null


func hasSmallRoad() -> bool:
	return roadSmall != null


func updateSmallRoads(neighbours : Dictionary):
	if !hasSmallRoad():
		return
	
	var nVis = 0
	for dir in cardinals:
		if neighbours[dir] != null:
			roadSmall.get_node(dir).visible = neighbours[dir].hasSmallRoad()
			if neighbours[dir].hasSmallRoad():
				nVis += 1
		else:
			roadSmall.get_node(dir).visible = false
	
	# So if no neighbours are infrastructure, all directions are shown so that this isn't invisible
	if nVis == 0:
		for dir in cardinals:
			roadSmall.get_node(dir).visible = true


func updateSmallRoadVisibility(vis : bool):
	if hasSmallRoad():
		roadSmall.visible = vis


func addRailroad():
	if railroad == null:
		railroad = railroadScene.instance()		# widepeepoHappy
		add_child(railroad)


func removeRailroad():
	if railroad != null:
		remove_child(railroad)
		railroad.queue_free()
		railroad = null


func hasRailroad() -> bool:
	return railroad != null


func updateRailroads(neighbours : Dictionary):
	if !hasRailroad():
		return
	
	var nVis = 0
	for dir in cardinals:
		if neighbours[dir] != null:
			railroad.get_node(dir).visible = neighbours[dir].hasRailroad()
			if neighbours[dir].hasRailroad():
				nVis += 1
		else:
			railroad.get_node(dir).visible = false
	
	# So if no neighbours are infrastructure, all directions are shown so that this isn't invisible
	if nVis == 0:
		for dir in cardinals:
			railroad.get_node(dir).visible = true


func updateRailroadVisibility(vis : bool):
	if hasRailroad():
		railroad.visible = vis


func hasInfrastructure() -> bool:
	return hasRoad() or hasRailroad() or hasSmallRoad()


func updateFeatureVisibility(vis : bool):
	if hasCity():
		city.visible = vis
	
	if hasRoad():
		road.visible = vis
	
	if hasRailroad():
		railroad.visible = vis
	
	if hasSmallRoad():
		roadSmall.visible = vis
	
	if hasResource():
		resource.visible = false
	
	if hasAirbase():
		airbase.visible = vis


func addResource(r : String):
	if r == Resources.NONE:
		removeResource()
	elif resource == null:
		resource = resourceScene.instance()
		add_child(resource)
		resource.init(r)
	else:
		resource.init(r)


func removeResource():
	if resource != null:
		remove_child(resource)
		resource.queue_free()
		resource = null


func hasResource() -> bool:
	return resource != null


func getResource() -> String:
	if resource == null:
		return Resources.NONE
	else:
		return resource.rName


func updateResourceVisibility(vis : bool):
	if hasResource():
		resource.visible = vis


func setPopulation(amount : int):
	population = amount


func addPopulation(amount : int):
	population += amount
	

func getPopulation() -> int:
	return population


func addRiver(instance : RiverTile):
	river = instance
	add_child(river)


func hasRiver() -> bool:
	return river != null


func getRiver() -> RiverTile:
	return river


func getRiverName() -> String:
	if hasRiver():
		return river.riverName
	else:
		return "none"


func updateRiverVisibility(vis : bool):
	if hasRiver():
		river.visible = vis


func addAirbase():
	if !hasAirbase():
		airbase = airbaseScene.instance()
		add_child(airbase)


func removeAirbase():
	if hasAirbase():
		remove_child(airbase)
		airbase.queue_free()
		airbase = null


func hasAirbase() -> bool:
	return airbase != null


func getAirbase() -> Airbase:
	return airbase


func updateAirbaseVisibility(vis : bool):
	if hasAirbase():
		airbase.visible = vis






