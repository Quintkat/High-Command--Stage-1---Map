extends Node2D
class_name EditorMap

onready var Cam = $MapCamera
onready var GridOverlay = $GridOverlay
onready var BrushCursor = $BrushCursor
onready var CityLabels = $CityLabels

const standardCamMapSize = Vector2(48, 27)

var grid : Grid

const standardTerrain = Terrain.WATER
const standardNationality = Nationality.DEFAULT
const standardCulture = Cultures.DEFAULT
const standardGovernmentForm = GovForm.REPUBLIC
const standardResource = Resources.NONE

const tileScene = preload("res://Map/Tile/Tile.tscn")
const cityScene = preload("res://Map/Tile/City/City.tscn")
const cityLabelScene = preload("res://Map/City Label/CityLabel.tscn")

var selectedTile : Tile = null

var cities = []
var cityLabels = {}

var nations = {}

var rivers = {}


func _ready():
	LoadInfo.loadAutoloaded()
	initialiseGrid()
	loadMap()
	Cam.init(standardCamMapSize)
	Cam.widerMovement = true
	Cam.moveWithKeyboard = false


func initialiseGrid():
	grid = Grid.new()
	grid.setSize(1, 1)
	grid.addTile(Vector2(0, 0), createStandardTile())


func getControlCount(control):
	var count = 0
	for child in control.get_children():
		if child is Control:
			count += 1
		count += getControlCount(child)
	
	return count


#####################################
# Changing map properties functions #
#####################################

func changeGridSize(size : Vector2):
	Cam.init(Vector2(max(standardCamMapSize[0], size[0]), max(standardCamMapSize[1], size[1])))
	var oldSize = grid.getSize()
	
	# If the width is changed
	if oldSize[0] != size[0]:
		# Column removed
		if size[0] < oldSize[0]:
			for i in range(oldSize[0] - size[0]):
				grid.removeTileColumn()
		# Column added
		else:
			for i in range(size[0] - oldSize[0]):
				grid.addTileColumn(createNewTileList(oldSize[1]))
	
	# If the height is changed
	oldSize = grid.getSize()
	if oldSize[1] != size[1]:
		# Row removed
		if size[1] < oldSize[1]:
			for i in range(oldSize[1] - size[1]):
				grid.removeTileRow()
		# Row added
		else:
			for i in range(size[1] - oldSize[1]):
				grid.addTileRow(createNewTileList(oldSize[0]))
	
	GridOverlay.rect_size = getGridSize()*TileConstants.SIZE
	move_child(GridOverlay, get_child_count())
			

func createNewTileList(length : int) -> Array:
	var list = []
	for i in range(length):
		list.append(createStandardTile())
	
	return list


func createStandardTile() -> Tile:
	var tile : Tile = tileScene.instance()
	add_child(tile)
	tile.updateTerrain(standardTerrain)
	tile.updateNationality(standardNationality)
	tile.updateCulture(standardCulture)
	return tile



#########################
# Map loading functions #
#########################

func loadMap():
	var savePath = LoadInfo.getGamedataLocation()
	loadProperties(savePath)
	loadTerrain(savePath)
	loadNationality(savePath)
	loadCulture(savePath)
	loadResources(savePath)
	loadInfrastructure(savePath)
	loadCities(savePath)
	loadNations(savePath)
	loadRivers(savePath)
	updateAllTileOrder()


func loadProperties(path : String):
	var filePath = path + "properties.json"
	if Loading.exists(filePath):
		var properties = Loading.loadDictFromJSON(filePath)
		var size = Vector2(properties["width"], properties["height"])
		changeGridSize(size)
		
		if "tilePopulation" in properties:
			Population.setTilePopulation(properties["tilePopulation"])
		
		if "cityMedium" in properties:
			Population.setCityGraphicsMedium(properties["cityMedium"])
		
		if "cityLarge" in properties:
			Population.setCityGraphicsLarge(properties["cityLarge"])


func loadTerrain(path : String):
	var terrainPath = path + "mapTerrain.png"
	if Loading.exists(terrainPath):
		var imgTerrain = Loading.loadImage(terrainPath).get_data()
		imgTerrain.lock()
	
		for x in range(getGridSize()[0]):
			for y in range(getGridSize()[1]):
				var pos = Vector2(x, y)
				var tile = grid.getTile(pos)
				
				var terrain = Terrain.terrain(imgTerrain.get_pixelv(pos))
				tile.updateTerrain(terrain)
		
		imgTerrain.unlock()


func loadNationality(path : String):
	var filePath = path + "mapNationality.png"
	if Loading.exists(filePath):
		var img = Loading.loadImage(filePath).get_data()
		img.lock()
		
		for x in range(getGridSize()[0]):
			for y in range(getGridSize()[1]):
				var pos = Vector2(x, y)
				var tile = grid.getTile(pos)
				
				var nat = Nationality.nationality(img.get_pixelv(pos))
				tile.updateNationality(nat)
		
		img.unlock()


func loadCulture(path : String):
	var filePath = path + "mapCulture.png"
	if Loading.exists(filePath):
		var img = Loading.loadImage(filePath).get_data()
		img.lock()
		
		for x in range(getGridSize()[0]):
			for y in range(getGridSize()[1]):
				var pos = Vector2(x, y)
				var tile = grid.getTile(pos)
				
				var culture = Cultures.culture(img.get_pixelv(pos))
				tile.updateCulture(culture)
		
		img.unlock()


func loadResources(path : String):
	var filePath = path + "mapResources.png"
	if Loading.exists(filePath):
		var img = Loading.loadImage(filePath).get_data()
		img.lock()
		
		for x in range(getGridSize()[0]):
			for y in range(getGridSize()[1]):
				var pos = Vector2(x, y)
				var tile = grid.getTile(pos)
				
				var res = Resources.resource(img.get_pixelv(pos))
				tile.addResource(res)
		
		img.unlock()


func loadInfrastructure(path : String):
	var filePathRoads = path + "mapRoads.png"
	var filePathSmallRoads = path + "mapSmallRoads.png"
	var filePathRailroads = path + "mapRailroads.png"
	var filePathAirbases = path + "mapAirbases.png"
	
	if (Loading.exists(filePathRoads) and Loading.exists(filePathRailroads) 
	and Loading.exists(filePathSmallRoads) and Loading.exists(filePathAirbases)):
		var imgRoads = Loading.loadImage(filePathRoads).get_data()
		var imgSmallRoads = Loading.loadImage(filePathSmallRoads).get_data()
		var imgRailroads = Loading.loadImage(filePathRailroads).get_data()
		var imgAirbases = Loading.loadImage(filePathAirbases).get_data()
		imgRoads.lock()
		imgSmallRoads.lock()
		imgRailroads.lock()
		imgAirbases.lock()

		for x in range(getGridSize()[0]):
			for y in range(getGridSize()[1]):
				var pos = Vector2(x, y)
				var tile = grid.getTile(pos)
				
				if imgRoads.get_pixelv(pos) == Infrastructure.roadColour:
					tile.addRoad()
				
				if imgSmallRoads.get_pixelv(pos) == Infrastructure.smallRoadColour:
					tile.addSmallRoad()
				
				if imgRailroads.get_pixelv(pos) == Infrastructure.railroadColour:
					tile.addRailroad()
				
				if imgAirbases.get_pixelv(pos) == Infrastructure.airbaseColour:
					tile.addAirbase()
				
				tile.updateOrder()
		
		for x in range(getGridSize()[0]):
			for y in range(getGridSize()[1]):
				var pos = Vector2(x, y)
				var tile = grid.getTile(pos)
				var neighbours = grid.getNeighbours(pos)
				tile.updateRoads(neighbours)
				tile.updateSmallRoads(neighbours)
				tile.updateRailroads(neighbours)

		imgRoads.unlock()
		imgSmallRoads.unlock()
		imgRailroads.unlock()
		imgAirbases.unlock()
	

func loadCities(path : String):
	var filePath = path + "cities.json"
	if Loading.exists(filePath):
		var data = Loading.loadDictFromJSON(filePath)
		for c in data:
			var city = data[c]
			
			var pos = Vector2(city["x"], city["y"])
			var newCity = cityScene.instance()
			var tile : Tile = grid.getTile(pos)
			tile.addCity(newCity)
			newCity.init(c, city["pop"], city["ic"], pos)
			cities.append(newCity)
			
			addCityLabel(newCity)


func loadNations(path : String):
	var filePath = path + "nations.json"
	if Loading.exists(filePath):
		var data = Loading.loadDictFromJSON(filePath)
		for n in data:
			var nationData = data[n]
			var nation = Nation.new()
			var capital
			if nationData["Capital"] == "":
				capital = null
			else:
				capital = null
				for city in cities:
					if city.getName() == nationData["Capital"]:
						capital = city
						break
				
			nation.init(n, nationData["Government"], capital)
			nation.setCulture(nationData["Culture"])
			nations[n] = nation
		
		assignCitiesToNations()


func loadRivers(path : String):
	var filePath = path + "rivers.json"
	if Loading.exists(filePath):
		var riverData = Loading.loadDictFromJSON(filePath)
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


func updateAllTileOrder():
	for x in range(getGridSize()[0]):
		for y in range(getGridSize()[1]):
			var tile = grid.getTile(Vector2(x, y))
			tile.updateOrder()



########################
# Map saving functions #
########################

func saveMap():
	var savePath = LoadInfo.getGamedataLocation()
	
	# Make sure the directory exists
	var saveDir = Directory.new()
	if !saveDir.dir_exists(savePath):
		saveDir.make_dir_recursive(savePath)
	
	saveProperties(savePath)
	saveImages(savePath)
	saveCities(savePath)
	saveNations(savePath)
	Nationality.saveToFile(savePath)
	Cultures.saveToFile(savePath)
	saveRivers(savePath)


func saveProperties(path : String):
	var properties = {
		"width"				:	getGridSize()[0],
		"height"			:	getGridSize()[1],
		"cityMedium"		:	Population.getCityGraphicsMedium(),
		"cityLarge"			:	Population.getCityGraphicsLarge(),
		"tilePopulation"	:	Population.getTilePopulationStandard(),
	}
	Saving.saveDictToJSON(path + "properties.json", properties)


func saveImages(path : String):
	var width = getGridSize()[0]
	var height = getGridSize()[1]
	var format = Image.FORMAT_RGB8
	var imgTerrain = createImage()
	var imgNationality = createImage()
	var imgCulture = createImage()
	var imgResources = createImage()
	var imgRoads = createImage()
	var imgSmallRoads = createImage()
	var imgRailroads = createImage()
	var imgAirbases = createImage()
	
	for x in range(width):
		for y in range(height):
			var pos = Vector2(x, y)
			var tile = grid.getTile(pos)
			
			imgTerrain.set_pixelv(pos, Terrain.colour(tile.getTerrain()))
			imgNationality.set_pixelv(pos, Nationality.colour(tile.getNationality()))
			imgCulture.set_pixelv(pos, Cultures.colour(tile.getCulture()))
			imgResources.set_pixelv(pos, Resources.colour(tile.getResource()))
			if tile.hasRoad():
				imgRoads.set_pixelv(pos, Infrastructure.roadColour)
			if tile.hasRailroad():
				imgRailroads.set_pixelv(pos, Infrastructure.railroadColour)
			if tile.hasSmallRoad():
				imgSmallRoads.set_pixelv(pos, Infrastructure.smallRoadColour)
			if tile.hasAirbase():
				imgAirbases.set_pixelv(pos, Infrastructure.airbaseColour)
	
	imgTerrain.save_png(path + "mapTerrain.png")
	imgNationality.save_png(path + "mapNationality.png")
	imgCulture.save_png(path + "mapCulture.png")
	imgResources.save_png(path + "mapResources.png")
	imgRoads.save_png(path + "mapRoads.png")
	imgSmallRoads.save_png(path + "mapSmallRoads.png")
	imgRailroads.save_png(path + "mapRailroads.png")
	imgAirbases.save_png(path + "mapAirbases.png")
	imgTerrain.unlock()
	imgNationality.unlock()
	imgCulture.unlock()
	imgResources.unlock()


func createImage() -> Image:
	var width = getGridSize()[0]
	var height = getGridSize()[1]
	var format = Image.FORMAT_RGB8
	var img = Image.new()
	img.create(width, height, false, format)
	img.lock()
	return img


func saveCities(path : String):
	var cityDict = {}
	for city in cities:
		cityDict[city.getName()] = city.getSaveData()
	
	Saving.saveDictToJSON(path + "cities.json", cityDict)


func saveNations(path : String):
	var dict = {}
	for n in nations:
		dict[n] = nations[n].getSaveData()
	
	Saving.saveDictToJSON(path + "nations.json", dict)


func saveRivers(path : String):
	var dict = {}
	for r in rivers:
		if rivers[r].getLength() > 1:
			dict[r] = rivers[r].getSaveDict()
	
	Saving.saveDictToJSON(path + "rivers.json", dict)



#########################
# Tile editing functions #
#########################

func editTerrain(pos : Vector2, terrain : String):
	var tile = grid.getTile(pos)
	if tile != null:
		tile.updateTerrain(terrain)
		if !tile.isLand():
			tile.updateNationality(Nationality.DEFAULT)
			tile.updateCulture(Cultures.DEFAULT)
			if tile.hasResource():
				tile.removeResource()


func editNationality(pos : Vector2, nat : String):
	var tile = grid.getTile(pos)
	if tile != null:
		var oldNat = tile.getNationality()
		if tile.isLand():
			tile.updateNationality(nat)
		if tile.hasCity():
			if oldNat != Nationality.DEFAULT:
				nations[oldNat].removeCity(tile.getCity())
			if nat != Nationality.DEFAULT:
				nations[nat].addCity(tile.getCity())


func removeNationality(nat : String):
	for x in range(getGridSize()[0]):
		for y in range(getGridSize()[1]):
			var tile = grid.getTile(Vector2(x, y))
			if tile.getNationality() == nat:
				tile.updateNationality(standardNationality)


func editCulture(pos : Vector2, culture : String):
	var tile = grid.getTile(pos)
	if tile != null:
		if tile.isLand():
			tile.updateCulture(culture)


func removeCulture(culture : String):
	for x in range(getGridSize()[0]):
		for y in range(getGridSize()[1]):
			var tile = grid.getTile(Vector2(x, y))
			if tile.getCulture() == culture:
				tile.updateCulture(standardCulture)


func editResource(pos : Vector2, resource : String):
	var tile = grid.getTile(pos)
	if tile != null:
		if tile.isLand():
			tile.addResource(resource)
		tile.updateOrder()


func addInfrastructure(pos : Vector2, infr : String):
	var tile = grid.getTile(pos)
	if tile == null:
		return
	if !tile.isLand():
		return
	
	if infr == Infrastructure.ROAD:
		tile.addRoad()
	elif infr == Infrastructure.RAILROAD:
		tile.addRailroad()
	elif infr == Infrastructure.SMALLROAD:
		tile.addSmallRoad()
	elif infr == Infrastructure.AIRBASE:
		tile.addAirbase()
		
	updateInfrastructure(pos)
	for nPos in grid.getNeighboursPos(pos).values():
		updateInfrastructure(nPos)
	tile.updateOrder()


func removeInfrastructure(pos : Vector2, infr : String):
	var tile = grid.getTile(pos)
	if tile == null:
		return
	if !tile.isLand():
		return
	
	if infr == Infrastructure.ROAD:
		tile.removeRoad()
	elif infr == Infrastructure.RAILROAD:
		tile.removeRailroad()
	elif infr == Infrastructure.SMALLROAD:
		tile.removeSmallRoad()
	elif infr == Infrastructure.AIRBASE:
		tile.removeAirbase()
	
	updateInfrastructure(pos)
	for nPos in grid.getNeighboursPos(pos).values():
		updateInfrastructure(nPos)
	tile.updateOrder()


func updateInfrastructure(pos : Vector2):
	var tile = grid.getTile(pos)
	if tile != null:
		var neighbours = grid.getNeighbours(pos)
		tile.updateRoads(neighbours)
		tile.updateSmallRoads(neighbours)
		tile.updateRailroads(neighbours)



##################
# City functions #
##################

func addCity(city : City):
	cities.append(city)
	var nat = getCityNationality(city)
	if nat != Nationality.DEFAULT:
		nations[nat].addCity(city)
	
	addCityLabel(city)


func editCity(city : City):
	updateCityLabelText(city)


func removeCity(city : City):
	if city != null:
		for n in nations:
			nations[n].removeCity(city)
		cities.erase(city)
		CityLabels.remove_child(cityLabels[city])
		cityLabels[city].queue_free()
		cityLabels.erase(city)


func addCityLabel(city : City):
	var newCL = cityLabelScene.instance()
	CityLabels.add_child(newCL)
	newCL.init(city.getName(), city.getPos())
	newCL.position = newCL.gridPos*TileConstants.SIZE + Vector2(TileConstants.SIZE/2, -15)
	cityLabels[city] = newCL


func updateCityLabelText(city : City):
	cityLabels[city].text = city.getName()


func _on_Cities_popScaleUpdated():
	for i in range(len(cities)):
		var city : City = cities[i]
		city.updateGraphics()



####################
# Nation functions #
####################

func createNewNation(nat : String) -> Nation:
	var new = Nation.new()
	new.init(nat, standardGovernmentForm, null)
	nations[nat] = new
	return new


func removeNation(nat : String):
	nations.erase(nat)


func getNations() -> Array:
	return nations.values()


func getNationsDict() -> Dictionary:
	return nations


func getNation(nat : String):
	return nations[nat]


func getCityNationality(city : City):
	return grid.getTile(city.getPos()).getNationality()


func assignCitiesToNations():
	for city in cities:
		var nat = getCityNationality(city)
		if nat != Nationality.DEFAULT:
			nations[nat].addCity(city)



###################
# River functions #
###################

func createRiver(n : String, pos : Vector2):
	var river = River.new()
	river.customInit(n, pos, grid)
	rivers[n] = river


func removeRiver(r : River):
	rivers.erase(r.getName())



########################
# Visibility functions #
########################

func updateNationalityVisibility(vis : bool):
	for x in range(getGridSize()[0]):
		for y in range(getGridSize()[1]):
			grid.getTile(Vector2(x, y)).updateNationalityVisibilityBool(vis)


func updateCulturesVisibility(vis : bool):
	for x in range(getGridSize()[0]):
		for y in range(getGridSize()[1]):
			grid.getTile(Vector2(x, y)).updateCultureVisibility(vis)


func updateCityVisibility(vis : bool):
	for x in range(getGridSize()[0]):
		for y in range(getGridSize()[1]):
			grid.getTile(Vector2(x, y)).updateCityVisibility(vis)
	
	for city in cities:
		cityLabels[city].visible = vis


func updateResourcesVisibility(vis : bool):
	for x in range(getGridSize()[0]):
		for y in range(getGridSize()[1]):
			grid.getTile(Vector2(x, y)).updateResourceVisibility(vis)


func updateInfrastructureVisibility(vis : bool):
	for x in range(getGridSize()[0]):
		for y in range(getGridSize()[1]):
			var tile = grid.getTile(Vector2(x, y))
			tile.updateRailroadVisibility(vis)
			tile.updateSmallRoadVisibility(vis)
			tile.updateRoadVisibility(vis)


func updateRiversVisibility(vis : bool):
	for x in range(getGridSize()[0]):
		for y in range(getGridSize()[1]):
			grid.getTile(Vector2(x, y)).updateRiverVisibility(vis)


func updateGridOverlayVisibility(vis : bool):
	GridOverlay.visible = vis


func getGridOverLayVisibility() -> bool:
	return GridOverlay.visible


func reloadGraphics():
	for x in range(getGridSize()[0]):
		for y in range(getGridSize()[1]):
			grid.getTile(Vector2(x, y)).reloadGraphics()



########################
# City label functions #
########################

func updateCityLabels():
	CityLabels.scale = Vector2(1, 1)/Cam.getZoom()
	for label in CityLabels.get_children():
		label.scale = Cam.zoom


func updateCityLabelsLayer():
	CityLabels.offset = -Cam.position/Cam.getZoom() + Cam.displaySize/2



###########################
# Miscellaneous functions #
###########################

func getGridSize() -> Vector2:
	return grid.getSize()


func getGrid() -> Grid:
	return grid


func getRivers() -> Dictionary:
	return rivers


func cameraMoveEvent():
	updateCityLabelsLayer()


func cameraZoomEvent():
	updateCityLabels()
	updateCityLabelsLayer()


func selectTile(pos : Vector2) -> Tile:
	var tile = grid.getTile(pos)
	if tile == null:
		return null
		
	if selectedTile != null and tile == selectedTile:
		selectedTile = null
		tile.deselect()
		return selectedTile
	elif selectedTile != null:
		selectedTile.deselect()
		selectedTile = tile
		tile.select()
		return selectedTile
	else:
		selectedTile = tile
		selectedTile.select()
		return selectedTile


func getSelected() -> Tile:
	return selectedTile


func _process(delta):
	BrushCursor.position = get_global_mouse_position()


func updateBrushCursor(newTexture : StreamTexture, size : int):
	BrushCursor.texture = newTexture
	BrushCursor.scale = Vector2(size, size)


func updateBrushCursorVisibility(vis : bool):
	BrushCursor.visible = vis



