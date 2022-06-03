extends Node2D
class_name Map

# Map children info
onready var CameraMap = $CameraMap
#onready var LFPS = $CanvasLayer/LFPS
onready var ClCityLabels = $ClCityLabels
onready var GridOverlay = $GridOverlay
onready var NationLabelManager = $NationLabelManager
onready var MapModeManager = $MapModeManager
onready var TileInfo = $TileInfoCanvas

# Necessary for instancing tiles
const tileScene = preload("res://Map/Tile/Tile.tscn")
const cityScene = preload("res://Map/Tile/City/City.tscn")
const cityLabelScene = preload("res://Map/City Label/CityLabel.tscn")

# The grid data
#var gridSize = Vector2(96, 54)
var gridSize : Vector2
var subgridSize = 3
var grid : Grid # Visual x, then visual y
var subgrid # Visual x, then visual y
const cardinals = ["North", "East", "South", "West"]

# Other map data
var cities = {}
var cityLabels = {}
var rivers = {}

# Map Loading filepaths
var imgLoadTerrain = "mapTerrain.png"
var imgLoadNationality = "mapNationality.png"
var jsonLoadCities = "cities.json"
var jsonLoadRivers = "rivers.json"
var imgLoadRoads = "mapRoads.png"
var imgLoadSmallRoads = "mapSmallRoads.png"
var imgLoadRailroads = "mapRailroads.png"
var imgLoadAirbases = "mapAirbases.png"
var imgLoadResources = "mapResources.png"
var imgLoadCulture = "mapCulture.png"

# Selection data
var selectionEnabled = true
var selectedPos : Vector2 = Vector2(-1, -1)
var selectedTile : Tile = null
var selectedSubtile : Subtile = null
var dragSelecting : bool = false
var dragSelectOrigin : Vector2 = Vector2(0, 0)
const dragSelectMargin = 1

# Nations
const jsonLoadNations = "nations.json"
var nations = {}

# Other
var previousZoomGradient = 0
var showGridOverlay = false

# Loading variables
var loadingFinished = false

# Test variables
var testCount = 0


func _ready():
	# Load certain auto-loaded scripts' data from files
	LoadInfo.loadAutoloaded()
	
	# Create and load map
	readMapProperties()
	fillTileGrid()
	cameraSetup()
	loadMap()
	updateBordersMap()
	updateNationalityVisibility(CameraMap.getZoomGradient())
	mapModeManagerSetup()
	loadingFinished = true
	updateTileOrderMap()
	setupNations()
	initNationCalculations()
	cameraZoomEvent(true)
	
	updateCultureVisibility(false)
	
	LoadInfo.setSavegameLocation(Directories.LOC_SAVEGAME)
	var path
	var time = OS.get_system_time_msecs()
#	path = Pathfinder.calcPath(grid, Vector2(35, 22), Vector2(44, 26), Movement.NON_MOTORISED)
#	path = Pathfinder.calcPath(grid, Vector2(56, 34), Vector2(56, 31), Movement.NON_MOTORISED)
#	path = Pathfinder.calcPath(grid, Vector2(61, 42), Vector2(64, 42), Movement.NON_MOTORISED)
#	path = Pathfinder.calcPath(grid, Vector2(72, 42), Vector2(66, 6), Movement.NON_MOTORISED)
#	path = Pathfinder.calcPath(grid, Vector2(72, 42), Vector2(66, 6), Movement.MOTORISED)
#	path = Pathfinder.calcPath(grid, Vector2(28, 39), Vector2(53, 37), Movement.NON_MOTORISED)
#	path = Pathfinder.calcPath(grid, Vector2(41, 18), Vector2(29, 16), Movement.MOTORISED)
#	path = Pathfinder.calcPath(grid, Vector2(41, 18), Vector2(29, 16), Movement.NON_MOTORISED)
#	path = Pathfinder.calcPath(grid, Vector2(41, 22), Vector2(51, 31), Movement.NON_MOTORISED)
#	path = Pathfinder.calcPath(grid, Vector2(19, 49), Vector2(26, 28), Movement.NON_MOTORISED)
#	path = Pathfinder.calcPath(grid, Vector2(19, 49), Vector2(26, 28), Movement.MOTORISED)
#	path = Pathfinder.calcPath(grid, Vector2(19, 49), Vector2(38, 30), Movement.MOTORISED)
	print("Pathfinding test time: " + str(OS.get_system_time_msecs() - time) + "ms")
#	for pos in path:
#		getTile(pos).select()

#	print("Total control nodes: ", Debug.getControlCount(self))
#	print("River control nodes: ", Debug.getTypeCount(self, RiverTile, 6))
#	print("City labels: ", Debug.getTypeCount(self, CityLabel))
#	var tileControlCount = 0
#	for x in gridSize[0]:
#		for y in gridSize[1]:
#			tileControlCount += Debug.getControlCount(getTile(Vector2(x, y)))
#	print("Controls under tiles: ", tileControlCount)
#	print("Border control nodes: ", Debug.getTypeCount(self, Borders, 5))


func readMapProperties():
	var data = Loading.loadDictFromJSON(LoadInfo.getGamedataLocation() + "properties.json")
	gridSize = Vector2(data["width"], data["height"])
	
	if "tilePopulation" in data:
		Population.setTilePopulation(data["tilePopulation"])
	
	if "cityMedium" in data:
		Population.setCityGraphicsMedium(data["cityMedium"])
	
	if "cityLarge" in data:
		Population.setCityGraphicsLarge(data["cityLarge"])
	


###############
# Map Loading #
###############

# Fill the grid and subgrid variables with the necessary data
func fillTileGrid():
	# Filling of the normal grid
	grid = Grid.new()
	grid.setSize(gridSize[0], gridSize[1])
	for x in range(gridSize[0]):
		for y in range(gridSize[1]):
			var tileNew = tileScene.instance()
			add_child(tileNew)
			var pos = Vector2(x, y)
			tileNew.init(pos)
			grid.addTile(pos, tileNew)
	
	# Filling of the subgrid
	subgrid = []
	for sx in range(gridSize[0]*subgridSize):
		subgrid.append([])
		for sy in range(gridSize[1]*subgridSize):
			subgrid[sx].append(Subtile.new())
	
	# Sizing the grid overaly correctly
	GridOverlay.rect_size = getTileSize()*gridSize
	move_child(GridOverlay, get_child_count())


# Set up the camera
func cameraSetup():
	CameraMap.init(gridSize)
	previousZoomGradient = CameraMap.getZoomGradient()


func fontSetup():
	Fonts.init(CameraMap)


func getTileSize() -> int:
	return getTile(Vector2(0, 0)).getSize()


func getSubtileSize() -> int:
	return getTile(Vector2(0, 0)).getSubtileSize()


# Loads map data from a set of images
func loadMap():
	loadImgs()
	updateAllInfrastructure()
	loadCities()
	loadRivers()


func loadImage(path):
	return Loading.loadImage(path)


func loadImgs():
	var imgTerrain = loadImage(LoadInfo.getGamedataLocation() + imgLoadTerrain).get_data()
	var imgNationality = loadImage(LoadInfo.getSavegameLocation() + imgLoadNationality).get_data()
	var imgRoads = loadImage(LoadInfo.getSavegameLocation() + imgLoadRoads).get_data()
	var imgSmallRoads = loadImage(LoadInfo.getSavegameLocation() + imgLoadSmallRoads).get_data()
	var imgRailroads = loadImage(LoadInfo.getSavegameLocation() + imgLoadRailroads).get_data()
	var imgAirbases = loadImage(LoadInfo.getSavegameLocation() + imgLoadAirbases).get_data()
	var imgResources = loadImage(LoadInfo.getGamedataLocation() + imgLoadResources).get_data()
	var imgCulture = loadImage(LoadInfo.getGamedataLocation() + imgLoadCulture).get_data()
	imgTerrain.lock()
	imgNationality.lock()
	imgRoads.lock()
	imgSmallRoads.lock()
	imgRailroads.lock()
	imgAirbases.lock()
	imgResources.lock()
	imgCulture.lock()
	
	# Load all the initial tile features
	for x in range(gridSize[0]):
		for y in range(gridSize[1]):
			# Read terrain
			var tile = getTile(Vector2(x, y))
			var terrain = Terrain.terrain(imgTerrain.get_pixel(x, y))
			tile.updateTerrain(terrain)
			if terrain == Terrain.WATER || terrain == Terrain.LAKE:
				continue
			
			# Read nationality
			var nationality = Nationality.nationality(imgNationality.get_pixel(x, y))
			tile.updateNationality(nationality)
			
			# Read infrastructure
			if imgRailroads.get_pixel(x, y) == Infrastructure.railroadColour:
				tile.addRailroad()

			if imgRoads.get_pixel(x, y) == Infrastructure.roadColour:
				tile.addRoad()
				
			if imgSmallRoads.get_pixel(x, y) == Infrastructure.smallRoadColour:
				tile.addSmallRoad()
			
			if imgAirbases.get_pixel(x, y) == Infrastructure.airbaseColour:
				tile.addAirbase()

			# Read resources
			var resource = Resources.resource(imgResources.get_pixel(x, y))
			if resource != Resources.NONE:
				tile.addResource(resource)
			
			# Read Culture
			var culture = Cultures.culture(imgCulture.get_pixel(x, y))
			tile.updateCulture(culture)
			
			# Set Population
			tile.setPopulation(Population.getTilePopulation(tile))


func loadCities():
	# Load in the city file and populate a 2d array with the data
	var cityFile = File.new()
	var cityX = "x"
	var cityY = "y"
	var cityIC = "ic"
	var emptySign = "!"
	var emptyName = "Industrial Zone"
	
	# Populate the grid with the actual cities
	cityFile.open(LoadInfo.getSavegameLocation() + jsonLoadCities, File.READ)
	var cityData = JSON.parse(cityFile.get_as_text()).result
	cityFile.close()
	
	for c in cityData:
		var city = cityData[c]
		var cityName = c
		if c[0] == emptySign:
			cityName = emptyName
		
		var cityGridPos = Vector2(city[cityX], city[cityY])
		var cityNew = cityScene.instance()
		var tile : Tile = getTile(cityGridPos)
		tile.addCity(cityNew)
		var pop = 0
		if "pop" in city:
			pop = city["pop"]
		cityNew.init(cityName, pop, city[cityIC], cityGridPos)
		cities[cityName] = cityNew
		
		if cityName != emptyName:
			createCityLabel(cityNew)
			
	updateCityLabels()


func createCityLabel(city : City):
	var label = cityLabelScene.instance()
	var textWidth = Fonts.fontCityConstant.get_string_size(city.cityName)[0]
	ClCityLabels.add_child(label)
	label.init(city.cityName, city.gridPos)
	label.position = label.gridPos*getTileSize() + Vector2(getTileSize()/2, -15)
	cityLabels[city] = label


func loadRivers():
	var riverData = Loading.loadDictFromJSON(LoadInfo.getGamedataLocation() + jsonLoadRivers)
	
	for rName in riverData:
		var info = riverData[rName]
		var startPos = Vector2(int(info["startX"]), int(info["startY"]))
		var landFinish = false
		if "landFinish" in info:
			landFinish = info["landFinish"]
			
		var segmentDict = {}
		for size in Rivers.sizes:
			if size in info:
				segmentDict[size] = info[size]
		
		var river = River.new()
		add_child(river)
		river.init(rName, startPos, segmentDict, landFinish, grid)
		rivers[rName] = river
	
	addRiverToSubTiles()


func addRiverToSubTiles():
	var subVectors = {
		"North"	:	Vector2(1, 0),
		"East"	:	Vector2(2, 1),
		"South"	:	Vector2(1, 2),
		"West"	:	Vector2(0, 1),
	}
	var centerVector = Vector2(1, 1)
	
	for r in rivers:
		var river = rivers[r]
		var positions = river.getPositions()
		
		for pos in positions:
			var tile = getTile(pos)
			var riverTile = tile.getRiver()
			var riverTileDirs = riverTile.getDirsVisible()
			var subPos = pos*subgridSize
			
			# The cardinal directions
			for dir in riverTileDirs:
				var subPosDir = subPos + subVectors[dir]
				var subTile = getSubtile(subPosDir)
				subTile.setRiver(riverTile.getDirSize(dir), Rivers.getVH(dir))
			
			# Center tile
			var centerSubTile = getSubtile(subPos + centerVector)
			centerSubTile.setRiver(riverTile.getMaxSize(), riverTile.getDirection())


func mapModeManagerSetup():
	MapModeManager.init(self)


func setupNations():
	NationLabelManager.init(150, grid)
	move_child(NationLabelManager, get_child_count())
	loadNations()
	
	for c in cities:
		var city = cities[c]
		var cityTile = getTile(city.getPos())
		var nation = nations[cityTile.getNationality()]
		nation.addCity(city)
	
	for x in range(gridSize[0]):
		for y in range(gridSize[1]):
			var pos = Vector2(x, y)
			var tile = getTile(pos)
			var nationality = tile.getNationality()
			if tile != null and nationality != Nationality.DEFAULT:
				var nation = nations[nationality]
				nation.addTile(tile, pos)
	
	printNationResources()
	print()
	printNationIC()
	print()
	printNationPopulation()
				
	var time = OS.get_system_time_msecs()
	for n in nations:
		NationLabelManager.addLabel(nations[n])
	print("Nationlabel time: ", OS.get_system_time_msecs() - time, "ms")


func loadNations():
	var nationFile = File.new()
	nationFile.open(LoadInfo.getSavegameLocation() + jsonLoadNations, File.READ)
	var nationData = JSON.parse(nationFile.get_as_text()).result
	nationFile.close()
	
	for n in nationData:
		var nation = Nation.new()
		var data = nationData[n]
		var gov = data["Government"]
		var cap = cities[data["Capital"]]
		var access = data["Access"]
		nation.init(n, gov, cap)
		nation.setAccess(access)
		nations[n] = nation
		cityLabels[cap].updateCapital(true)


func getMaxLengthNation() -> int:
	var maxLength = 0
	for n in nations:
		maxLength = max(maxLength, len(n))
	
	return maxLength


func printNationResources():
	for n in nations:
		print(n, Misc.repeatString(" ", getMaxLengthNation() - len(n)),": ", nations[n].getResourceReach())


func printNationIC():
	for n in nations:
		print(n, Misc.repeatString(" ", getMaxLengthNation() - len(n)),": ", nations[n].getIC())


func printNationPopulation():
	for n in nations:
		print(n, Misc.repeatString(" ", getMaxLengthNation() - len(n)),": ", 
			Misc.commaSep(nations[n].getPopulation()), 
			"\t(Urban: ", Misc.commaSep(nations[n].getUrbanPopulation()),
			", Rural: ", Misc.commaSep(nations[n].getRuralPopulation()), ")")



##############
# Map Saving #
##############

func saveGame():
	var saveLocation = LoadInfo.getSavegameLocation()
	# Make sure the directory exists
	var saveDir = Directory.new()
	if !saveDir.dir_exists(saveLocation):
		saveDir.make_dir_recursive(saveLocation)
	
	saveMap(saveLocation)
	saveCities(saveLocation)
	saveNations(saveLocation)
	saveLoadInfo(saveLocation)


func saveMap(saveLocation : String):
	# Saving map images on grid space
	var width = gridSize[0]
	var height = gridSize[1]
	var format = Image.FORMAT_RGBA8
	var defaultColour = Color("#FFFFFF")
	var imgNationality = Image.new()
	imgNationality.create(width, height, false, format)
	imgNationality.lock()
	var imgRoads = Image.new()
	imgRoads.create(width, height, false, format)
	imgRoads.lock()
	var imgRailroads = Image.new()
	imgRailroads.create(width, height, false, format)
	imgRailroads.lock()
	var imgSmallRoads = Image.new()
	imgSmallRoads.create(width, height, false, format)
	imgSmallRoads.lock()
	var imgAirbases = Image.new()
	imgAirbases.create(width, height, false, format)
	imgAirbases.lock()
	
	for x in range(width):
		for y in range(height):
			var pos = Vector2(x, y)
			var tile : Tile = getTile(pos)
			imgNationality.set_pixelv(pos, Nationality.colour(tile.getNationality()))
			
			if tile.hasRoad():
				imgRoads.set_pixelv(pos, Infrastructure.roadColour)
			else:
				imgRoads.set_pixelv(pos, defaultColour)
			
			if tile.hasRailroad():
				imgRailroads.set_pixelv(pos, Infrastructure.railroadColour)
			else:
				imgRailroads.set_pixelv(pos, defaultColour)
			
			if tile.hasSmallRoad():
				imgSmallRoads.set_pixelv(pos, Infrastructure.smallRoadColour)
			else:
				imgSmallRoads.set_pixelv(pos, defaultColour)
			
			if tile.hasAirbase():
				imgAirbases.set_pixelv(pos, Infrastructure.airbaseColour)
			else:
				imgAirbases.set_pixelv(pos, defaultColour)
	
	imgNationality.save_png(saveLocation + "mapNationality.png")
	imgRoads.save_png(saveLocation + "mapRoads.png")
	imgRailroads.save_png(saveLocation + "mapRailroads.png")
	imgSmallRoads.save_png(saveLocation + "mapSmallRoads.png")
	imgAirbases.save_png(saveLocation + "mapAirbases.png")
	
	imgNationality.unlock()
	imgRoads.unlock()
	imgRailroads.unlock()
	imgSmallRoads.unlock()
	imgAirbases.unlock()
			

func saveCities(saveLocation : String):
	var cityDict = {}
	for c in cities:
		cityDict[c] = cities[c].getSaveData()
	
	Saving.saveDictToJSON(saveLocation + "cities.json", cityDict)


func saveNations(saveLocation : String):
	var nationDict = {}
	for n in nations:
		nationDict[n] = nations[n].getSaveData()
	
	Saving.saveDictToJSON(saveLocation + "nations.json", nationDict)


func saveLoadInfo(saveLocation : String):
	var loadInfoDict = {
		"name"			:	LoadInfo.getGameName(),
		"gamedata"		:	LoadInfo.getGamedataLocation(),
		"lastModified"	:	OS.get_unix_time()
	}
	Saving.saveDictToJSON(saveLocation + "info.json", loadInfoDict)
	


############################
# Tile info state updating #
############################

# Update the borders of all tiles in the map
func updateBordersMap():
	for x in range(gridSize[0]):
		for y in range(gridSize[1]):
			updateBorders(Vector2(x, y))

# Update the borders of a tile at a position
# On grid space
func updateBorders(pos : Vector2):
	var tile = getTile(pos)
	var diffNats = []
	var neighbours = getNeighbours(pos)
	
	if tile == null:
		return
	
	if tile.terrain == Terrain.WATER || tile.terrain == Terrain.LAKE:
		return
	
	for dir in cardinals:
		var neighbour = neighbours[dir]
		if neighbour == null:
			continue
		
		if neighbour.nationality != tile.nationality && neighbour.isLand():
			diffNats.append(dir)
	
	tile.updateBorders(diffNats)


func updateAllInfrastructure():
	for x in range(gridSize[0]):
		for y in range(gridSize[1]):
			if getTile(Vector2(x, y)) == null:
				continue
			
			updateInfrastructure(Vector2(x, y))


func updateInfrastructure(pos: Vector2):
	var tile = getTile(pos)
	var neighbours = getNeighbours(pos)
	tile.updateRoads(neighbours)
	tile.updateRailroads(neighbours)
	tile.updateSmallRoads(neighbours)



###########
# Process #
###########

func _process(delta):
	inputs()
	$SelectLayer/SelectButton.visible = !GuiInfo.guiFocus


func inputs():
	if Input.is_action_just_released("game_end"):
		get_tree().quit()
	
	if Input.is_action_just_pressed("toggleGridOverlay"):
		showGridOverlay = !showGridOverlay
		GridOverlay.visible = showGridOverlay
	
	if Input.is_action_just_pressed("save"):
		saveGame()


func _on_SelectButton_button_down():
	dragSelectOrigin = mouseGridPosition()


func _on_SelectButton_pressed():
	if detectDragSelecting(dragSelectOrigin):
		dragSelecting = true


func _on_SelectButton_button_up():
	if !dragSelecting:
		if !isSubtileSelecting():
			deselectSubtile()
			var previousSelected = selectedTile
			if previousSelected != null:
				deselectTile()

			selectTile(mouseGridPosition())
			if previousSelected == selectedTile:
				deselectTile()

		else:
			deselectTile()
			var previousSelected = selectedSubtile
			if previousSelected != null:
				deselectSubtile()

			selectSubtile(mouseSubgridPosition())
			if previousSelected == selectedSubtile:
				deselectSubtile()	
	else:
		dragSelecting = false



#############
# Selection #
#############

# On grid space
func detectDragSelecting(origin : Vector2):
	var diff = origin - mouseGridPosition()
	return abs(diff[0]) >= dragSelectMargin || abs(diff[1]) >= dragSelectMargin


# On grid space
func selectTile(pos : Vector2):
	selectedTile = getTile(pos)
	if selectedTile != null:
		selectedPos = pos
		selectedTile.select()
		print(pos)
		showTileInfo(selectedTile)


# On subgrid space
func selectSubtile(pos : Vector2):
	selectedSubtile = getSubtile(pos)
	if selectedSubtile != null:
		selectedPos = pos
		selectedSubtile.select()
		
		# The super tile only handles the visual aspect of the selection box)
		var superTile = getSuperTile(pos)
		superTile.selectSubtile(VectorMath.mod(pos, subgridSize))
		showTileInfo(superTile)
	

# On grid space
func deselectTile():
	hideTileInfo()
	if selectedTile != null:
		selectedTile.deselect()
		resetSelectedTile()


# On subgrid space
func deselectSubtile():
	hideTileInfo()
	if selectedSubtile != null:
		selectedSubtile.deselect()
		getSuperTile(selectedPos).deselect()
		resetSelectedSubtile()


func resetSelectedTile():
	selectedTile = null
	selectedPos = Vector2(-1, -1)


func resetSelectedSubtile():
	selectedSubtile = null
	selectedPos = Vector2(-1, -1)


func isSubtileSelecting():
	return !Input.is_action_pressed("select_modifier") && CameraMap.getZoomPercentage() >= 0.8


func showTileInfo(tile : Tile):
	TileInfo.layer = GuiInfo.LAYER_TILEINFO
	TileInfo.show(tile)


func hideTileInfo():
	TileInfo.layer = GuiInfo.IDLELAYER_TILEINFO
	

func tempDisableSelecting():
	selectionEnabled = false



###################
# Info retrieving #
###################

# On grid space
func getTile(pos : Vector2) -> Tile:
	return grid.getTile(pos)


# On subgrid space
func getSubtile(pos : Vector2) -> Subtile:
	if !posValidSubgrid(pos):
		return null
	return subgrid[pos[0]][pos[1]]


# On subgrid space
func getSuperTile(pos : Vector2) -> Tile:
	return getTile(VectorMath.vectInt(pos/subgridSize))


# Returns dict with the north, east, south and west neighbours of tile at pos
func getNeighbours(pos : Vector2) -> Dictionary:
	return grid.getNeighbours(pos)


# Returns dict with positions of the NESW neighbours of the tile
func getNeighboursPos(pos : Vector2) -> Dictionary:
	return grid.getNeighboursPos(pos)


# Returns an array with all tiles within a certain distance of the position
func getNeighboursDistance(pos: Vector2, d : float) -> Array:
	return grid.getNeighboursDistance(pos, d)
	

# Returns an array with all tiles within a certain distance of the position that are of that position's nationality
func getNeighboursDistanceNationality(pos : Vector2, d : float) -> Array:
	return grid.getNeighboursDistanceNationality(pos, d)


# Grid validity functions
# On grid space
func posValid(pos : Vector2) -> bool:
	return !(pos[0] < 0 || pos[0] >= gridSize[0] || pos[1] < 0 || pos[1] >= gridSize[1])


# On subgrid space
func posValidSubgrid(pos : Vector2) -> bool:
	return !(pos[0] < 0 || pos[0] >= gridSize[0]*subgridSize || pos[1] < 0 || pos[1] >= gridSize[1]*subgridSize)


# Mouse conversion functions
func mouseGridPosition() -> Vector2:
	return VectorMath.vectInt(get_global_mouse_position()/getTileSize())


func mouseSubgridPosition() -> Vector2:
	return VectorMath.vectInt(get_global_mouse_position()/getSubtileSize())


func getCityNationality(city : City) -> String:
	var tile = getTile(city.getPos())
	if tile == null:
		return Nationality.DEFAULT
	
	return tile.getNationality()


func isTileCoastal(pos : Vector2) -> bool:
	var neighbours = getNeighbours(pos)
	for dir in neighbours:
		if neighbours[dir] != null:
			if neighbours[dir].getTerrain() == Terrain.WATER:
				return true
	
	return false



###############
# Map Editing #
###############

func editTerrainMouse(terrain):
	editTerrain(mouseGridPosition(), terrain)

func editTerrain(pos, terrain):
	getTile(pos).updateTerrain(terrain)

func editNationalityMouse(nationality):
	editNationality(mouseGridPosition(), nationality)

func editNationality(pos, nationality):
	getTile(pos).updateNationality(nationality)



###############
# Map display #
##############

# Listener functions
# Effectively a listener for the camera
func cameraZoomEvent(force : bool = false):
	var zoomGradient = CameraMap.getZoomGradient()
	
	if force:
		updateCultureVisibility(false)
		updateBorderVisibility(true)
	
	# These things only have to change in case the zoom level on the default map mode changes zones
	if force or (MapModeManager.isDefault() and zoomGradient != previousZoomGradient):
		previousZoomGradient = zoomGradient
		var zoomedIn = zoomGradient == 0
		var zoomedOut = zoomGradient == 1
		
		var time = OS.get_system_time_msecs()
		updateNationLabelVisibility(zoomedOut)
		updateAllTilesDefault(zoomGradient)
		updateCityLabelVisibility(zoomedIn)
		updateRiverVisibility(zoomedIn)
		print("Zooming time: ", OS.get_system_time_msecs() - time, "ms")
		
	if loadingFinished:
		updateCityLabels()
	
	updateCityLabelsLayer()


func cameraMoveEvent():
	updateCityLabelsLayer()


func updateCityLabels():
	ClCityLabels.scale = Vector2(1, 1)/CameraMap.getZoom()
	for label in ClCityLabels.get_children():
		label.scale = CameraMap.zoom


func updateCityLabelsLayer():
	ClCityLabels.offset = -CameraMap.position/CameraMap.getZoom() + CameraMap.displaySize/2


func updateCityLabelVisibilityAuto():
	updateCityLabelVisibility(CameraMap.getZoomGradient() == 0)


func updateCityLabelVisibility(vis : bool):
	for label in ClCityLabels.get_children():
		label.visible = vis
		

func updateAllTilesDefault(zoomGradient : float):
	var zoomedIn = zoomGradient == 0
	for nation in nations.values():
		for tile in nation.getTiles():
			tile.updateNationalityVisibility(zoomGradient)
			tile.updateFeatureVisibility(zoomedIn)
	

func updateNationLabelVisibility(vis : bool):
	NationLabelManager.visible = vis


# Update the nationality opacity of all tiles on the map
func updateNationalityVisibility(nat : float):
	for x in range(gridSize[0]):
		for y in range(gridSize[1]):
			updateNationalityVisibilityTile(Vector2(x, y), nat)


func updateNationaltityVisibilityBool(vis : bool):
	for x in range(gridSize[0]):
		for y in range(gridSize[1]):
			var tile = getTile(Vector2(x, y))
			if tile != null:
				tile.updateNationalityVisibilityBool(vis)
	

# Update the nationality opacity of a tile at a position
# On grid space
func updateNationalityVisibilityTile(pos : Vector2, nat : float):
	var tile = getTile(pos)
	tile.updateNationalityVisibility(nat)
	tile.updateBorderVisibility(true)


func updateTileFeatureVisibility(vis : bool):
	for x in range(gridSize[0]):
		for y in range(gridSize[1]):
			var tile = getTile(Vector2(x, y))
			if tile != null:
				tile.updateFeatureVisibility(vis)


func updateCityVisibility(vis : bool):
	for x in range(gridSize[0]):
		for y in range(gridSize[1]):
			var tile = getTile(Vector2(x, y))
			if tile != null:
				tile.updateCityVisibility(vis)
	

func updateRoadVisibility(vis : bool):
	for x in range(gridSize[0]):
		for y in range(gridSize[1]):
			var tile = getTile(Vector2(x, y))
			if tile != null:
				tile.updateRoadVisibility(vis)
	

func updateSmallRoadVisibility(vis : bool):
	for x in range(gridSize[0]):
		for y in range(gridSize[1]):
			var tile = getTile(Vector2(x, y))
			if tile != null:
				tile.updateSmallRoadVisibility(vis)
	

func updateRailroadVisibility(vis : bool):
	for x in range(gridSize[0]):
		for y in range(gridSize[1]):
			var tile = getTile(Vector2(x, y))
			if tile != null:
				tile.updateRailroadVisibility(vis)
	

func updateAirbaseVisibility(vis : bool):
	for x in range(gridSize[0]):
		for y in range(gridSize[1]):
			var tile = getTile(Vector2(x, y))
			if tile != null:
				tile.updateAirbaseVisibility(vis)
	


func updateResourceVisibility(vis : bool):
	for x in range(gridSize[0]):
		for y in range(gridSize[1]):
			var tile = getTile(Vector2(x, y))
			if tile != null:
				tile.updateResourceVisibility(vis)


func updateBorderVisibility(vis : bool):
	for x in range(gridSize[0]):
		for y in range(gridSize[1]):
			var tile = getTile(Vector2(x, y))
			if tile != null:
				tile.updateBorderVisibility(vis)


func updateRiverVisibility(vis : bool):
	for r in rivers:
		var river = rivers[r]
		river.updateVisibility(vis)


func updateCultureVisibility(vis : bool):
	for x in range(gridSize[0]):
		for y in range(gridSize[1]):
			updateCultureVisibilityTile(Vector2(x, y), vis)


func updateCultureVisibilityTile(pos : Vector2, vis : bool):
	getTile(pos).updateCultureVisibility(vis)


func updateTileOrderMap():
	for x in range(gridSize[0]):
		for y in range(gridSize[1]):
			var tile = getTile(Vector2(x, y))
			if tile != null:
				tile.updateOrder()


func updateTileOrder(tile : Tile):
	if tile != null:
		tile.updateOrder()



####################
# Nation Functions #
####################

func initNationCalculations():
#	calcNationsResourceReach()
#	calcNationsPopulation()
	pass


func calcNationsResourceReach():
	# Get the resource reach from going over each city
	var reaches = calcNationsResourceReachCities()
	
	# Go over food, the one passive resource
	for x in range(gridSize[0]):
		for y in range(gridSize[1]):
			var tile = getTile(Vector2(x, y))
			var nationality = tile.getNationality()
			if nationality != Nationality.DEFAULT:
				reaches[tile.getNationality()][Resources.FOOD] += Resources.getTerrainFood(tile.getTerrain())
	
	# Make sure the food amount is an int
	for n in nations:
		reaches[n][Resources.FOOD] = int(reaches[n][Resources.FOOD])
	
	# Add to nations
	for n in reaches:
		print(n, " ", reaches[n])
		nations[n].setResourceReach(reaches[n])


func calcNationsResourceReachCities():
	# Setup the resource lists for each nation
	var resourceList = Resources.getCountingList()
	var reaches = {}
	for n in nations:
		reaches[n] = resourceList.duplicate()
		
	# Go over all extracted resources ("city resources")
	for c in cities:
		var city : City = cities[c]
		if !cityPathCapital(city):
			continue
			
		var nationality = getCityNationality(city)
		if nationality == Nationality.DEFAULT:
			continue
		
		var cityResources = calcCityResourceReach(city)
		for resource in cityResources:
			var amount = cityResources[resource]
			reaches[nationality][resource] += amount
	
	return reaches
	

# Returns a dictionary with resoures as keys, and the amount of them in the reach of the city as values
func calcCityResourceReach(city : City):
	var pos = city.getPos()
	var tile = getTile(pos)
	var resources = {}
	# See if tile itself has resource
	if tile.hasResource():
		var resource = tile.getResource()
		if !resources.has(resource):
			resources[resource] = 1
		else:
			resource[resource] += 1
	
	# Check it's neighbours
	var cityReach = city.getResourceReach()
	var neighboursReach = getNeighboursDistanceNationality(pos, cityReach)
	for neighbour in neighboursReach:
		if neighbour.hasResource():
			var resource = neighbour.getResource()
			if !resources.has(resource):
				resources[resource] = 1
			else:
				resources[resource] += 1
	
	return resources


func calcNationsFoodReach():
	pass


func calcNationsPopulation():
	for x in range(gridSize[0]):
		for y in range(gridSize[1]):
			var tile = getTile(Vector2(x, y))
			tile.setPopulation(Population.getTilePopulation(tile))
			
	for n in nations:
		print(Misc.commaSep(nations[n].getPopulation()), " ", n)
				

func transferTileOwnership(pos : Vector2, newNationality : String):
	var tile = getTile(pos)
	if tile == null:
		print("Invalid position ", pos, " in transferTileOwnership")
		return
	
	var oldNationality = tile.getNationality()
	var oldNation = nations[oldNationality]
	var newNation = nations[newNationality]
	tile.updateNationality(newNationality)
	
	# Update tile ownership
	oldNation.removeTile(tile)
	newNation.addTile(tile)
	
	# Update borders
	var neighboursPos = getNeighboursPos(pos)
	for dir in neighboursPos:
		var neighbourPos = neighboursPos[dir]
		if !posValid(neighbourPos):
			continue
		
		updateBorders(neighbourPos)
	
	
#	# Update resource stuff for nations
#	if tile.hasResource():
#		var resource = tile.getResource()
#		var oldNationCities = oldNation.getCities()
#		var newNationCities = newNation.getCities()
#		for city in oldNationCities:
#			if pos.distance_to(city.getPos()) <= city.getResourceReach():
#				oldNation.addResourceReach(resource, -1)
#		for city in newNationCities:
#			if pos.distance_to(city.getPos()) <= city.getResourceReach():
#				newNation.addResourceReach(resource, 1)
	
	# Update city ownership
	if tile.hasCity():
		var city = tile.getCity()
		oldNation.removeCity(city)
		newNation.addCity(city)
		# TODO: look at the resource implications of this, and the best way to update it, 
		# because calling calcNationsResourceReach() might be too slow
	pass


func cityPathCapital(city : City) -> bool:
	var origin = city.getPos()
	if !getTile(origin).hasInfrastructure():
		return isTileCoastal(origin)
	
	var target = nations[getCityNationality(city)].getCapital().getPos()
	if !getTile(target).hasInfrastructure():
		return isTileCoastal(target)
	
	var nation = nations[getCityNationality(city)]
	return hasPathInfrastructure(origin, target, nation.getAccess())



###############
# Pathfinding #
###############

func hasPathInfrastructure(origin : Vector2, target : Vector2, nationalities = Nationality.getAll()) -> bool:
	if origin == target:
		return true
	return len(Pathfinder.calcPath(grid, origin, target, Movement.UNALTERED, nationalities, true)) > 0

#	var originTile = getTile(origin)
#	var targetTile = getTile(target)
#	if originTile == null or targetTile == null:
#		if !originTile.hasInfrastructure() or !targetTile.hasInfrastructure():
#			return false
#
#	# Using bfs
#	var queue = [origin]
#	var visited = []
#	while !queue.empty():
#		if queue.has(target):
#			return true
#
#		var currentPos = queue.pop_front()
#		visited.append(currentPos)
#		var neighbours = getNeighboursPos(currentPos)
#		for dir in neighbours:
#			var neighbourPos = neighbours[dir]
#			if neighbourPos in visited:
#				continue 
#
#			var neighbour = getTile(neighbourPos)
#			if neighbour == null:
#				continue
#
#			if neighbour.hasInfrastructure():
#				if nationalities == Nationality.getAll():
#					queue.append(neighbourPos)
#				else:
#					if neighbour.getNationality() in nationalities:
#						queue.append(neighbourPos)
#
#	return false


















