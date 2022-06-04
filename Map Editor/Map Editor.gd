extends Node2D


onready var EditorMap = $EditorMap
onready var Overlay = $Overlay
onready var OverlayFile = $GUILayer/OverlayFileDialog
onready var OverlayShortcutLabel = $ShortCutLayer/Overlay
onready var GUILayer = $GUILayer
onready var propertiesPanel = $GUILayer/EditPanels/Properties
onready var terrainPanel = $GUILayer/EditPanels/Terrain
onready var nationalityPanel = $GUILayer/EditPanels/Nationalities
onready var citiesPanel = $GUILayer/EditPanels/Cities
onready var resourcesPanel = $GUILayer/EditPanels/Resources
onready var nationsPanel = $GUILayer/EditPanels/Nations
onready var infrastructurePanel = $GUILayer/EditPanels/Infrastructure
onready var riversPanel = $GUILayer/EditPanels/Rivers
onready var culturesPanel = $GUILayer/EditPanels/Cultures
onready var panels = {
	$GUILayer/ButtonGrid/Properties			:	propertiesPanel,
	$GUILayer/ButtonGrid/Terrain			:	terrainPanel,
	$GUILayer/ButtonGrid/Nationalities		:	nationalityPanel,
	$GUILayer/ButtonGrid/Cities				:	citiesPanel,
	$GUILayer/ButtonGrid/Resources			:	resourcesPanel,
	$GUILayer/ButtonGrid/Nations			:	nationsPanel,
	$GUILayer/ButtonGrid/Infrastructure		:	infrastructurePanel,
	$GUILayer/ButtonGrid/Rivers				:	riversPanel,
	$GUILayer/ButtonGrid/Cultures			:	culturesPanel
}
var brushPanel : Brush
onready var VisPanel = $GUILayer/VisibilityPanel
onready var TileInfoPanel = $GUILayer/TileInfoPanel
onready var OverlayMenu = $GUILayer/OverlayMenu
onready var StatisticsPanel = $GUILayer/Statistics


var showUI = true

const NONE = "none"
const TERRAIN = "terrain"
const NATIONALITY = "nationality"
const CULTURE = "culture"
const RESOURCE = "resource"
const INFRASTRUCTURE = "infrastructure"
var clickMode = NONE

var overlayAmount : int = 5
var overlayPaths : Array = []
var overlayTextures : Array = []
var overlayScales : Array = []
var overlayOpacities : Array = []
var currentOverlay = 0

var visSettings = {
	"Nationality"		:	false,
	"Cultures"			:	false,
	"Cities"			:	true,
	"Resources"			:	false,
	"Infrastructure"	:	true,
	"Rivers"			:	true
}


func _ready():
	for panel in panels.values():
		panel.visible = false
	panels[$GUILayer/ButtonGrid/Properties].visible = true
	$GUILayer/ButtonGrid/Properties.pressed = true
	if !LoadInfo.isMapEditorLoading():
		_on_SpinBoxWidth_value_changed($GUILayer/EditPanels/Properties/VBox/Width/SpinBoxWidth.value)
		_on_SpinBoxHeight_value_changed($GUILayer/EditPanels/Properties/VBox/Height/SpinBoxHeight.value)

	if LoadInfo.isMapEditorLoading():
		setSizeUIValues(EditorMap.getGridSize())
	
	setPopulationUIValues(Population.getTilePopulationStandard())
	
	reloadVisibility()
	EditorMap.reloadGraphics()

	# Prepare brush scene
	brushPanel = load("res://Map Editor/Brush/Brush.tscn").instance()
	brushPanel.connect("sizeChanged", self, "_onBrushSizeChanged")

	# Prepare cities panel signals
	citiesPanel.connect("cityAdded", self, "_onCityAdded")
	citiesPanel.connect("cityEdited", self, "_onCityEdited")
	citiesPanel.connect("cityRemoved", self, "_onCityRemoved")

	# Prepare nationalities panel signals
	nationalityPanel.connect("nationalityCreated", self, "_onNationalityCreated")
	nationalityPanel.connect("nationalityEdited", self, "_onNationalityEdited")
	nationalityPanel.connect("nationalityRemoved", self, "_onNationalityRemoved")

	# Prepare cultures panel signals
	culturesPanel.connect("cultureCreated", self, "_onCultureCreated")
	culturesPanel.connect("cultureEdited", self, "_onCultureEdited")
	culturesPanel.connect("cultureRemoved", self, "_onCultureRemoved")

	loadNationsIntoPanel()
	
	riversPanel.giveEditorMap(EditorMap)
	riversPanel.populateSelect()
	
	loadOverlay()
	
	StatisticsPanel.init(EditorMap.getNationsDict(), EditorMap.getGrid())


func _process(delta):
	if Input.is_action_just_released("game_end"):
		get_tree().quit()

	if clickMode == NONE:
		EditorMap.updateBrushCursorVisibility(false)
	else:
		EditorMap.updateBrushCursorVisibility(!Input.is_action_pressed("map_editor_select_tile"))

	if Input.is_action_just_released("toggleGridOverlay"):
		EditorMap.updateGridOverlayVisibility(!EditorMap.getGridOverLayVisibility())
		$GUILayer/VisibilityPanel/HBox/GridOverlay.pressed = EditorMap.getGridOverLayVisibility()

	if Input.is_action_just_pressed("map_editor_toggle_ui"):
		toggleUIVisibility()

	if Input.is_action_just_pressed("map_editor_toggle_nationality_visibility"):
		VisPanel.manualToggle(VisPanel.NATIONALITY)

	if Input.is_action_just_pressed("map_editor_toggle_cultures_visibility"):
		VisPanel.manualToggle(VisPanel.CULTURES)

	if Input.is_action_just_pressed("map_editor_toggle_cities_visibility"):
		VisPanel.manualToggle(VisPanel.CITIES)

	if Input.is_action_just_pressed("map_editor_toggle_resources_visibility"):
		VisPanel.manualToggle(VisPanel.RESOURCES)

	if Input.is_action_just_pressed("map_editor_toggle_infrastructure_visibility"):
		VisPanel.manualToggle(VisPanel.INFRASTRUCTURE)

	if Input.is_action_just_pressed("map_editor_toggle_rivers_visibility"):
		VisPanel.manualToggle(VisPanel.RIVERS)
	
#	if Input.is_action_just_pressed("map_editor_toggle_overlay"):
#		Overlay.visible = !Overlay.visible



####################################
# Change map editor mode functions #
####################################

func changeEditMode(buttonPressed : Button):
	for button in panels:
		if button != buttonPressed:
			button.pressed = false
			panels[button].visible = false
	panels[buttonPressed].visible = true


func _on_Properties_button_down():
	changeEditMode($GUILayer/ButtonGrid/Properties)
	clickMode = NONE


func _on_Terrain_button_down():
	changeEditMode($GUILayer/ButtonGrid/Terrain)
	clickMode = TERRAIN
	terrainPanel.addBrush(brushPanel)


func _on_Nationalities_button_down():
	changeEditMode($GUILayer/ButtonGrid/Nationalities)
	clickMode = NATIONALITY
	nationalityPanel.addBrush(brushPanel)


func _on_Cities_button_down():
	changeEditMode($GUILayer/ButtonGrid/Cities)
	clickMode = NONE


func _on_Resources_button_down():
	changeEditMode($GUILayer/ButtonGrid/Resources)
	clickMode = RESOURCE


func _on_Nations_button_down():
	changeEditMode($GUILayer/ButtonGrid/Nations)
	clickMode = NONE


func _on_Infrastructure_button_down():
	changeEditMode($GUILayer/ButtonGrid/Infrastructure)
	clickMode = INFRASTRUCTURE


func _on_Rivers_button_down():
	changeEditMode($GUILayer/ButtonGrid/Rivers)
	clickMode = NONE


func _on_Cultures_button_down():
	changeEditMode($GUILayer/ButtonGrid/Cultures)
	clickMode = CULTURE
	culturesPanel.addBrush(brushPanel)



########################
# Properties functions #
########################

func _on_SpinBoxWidth_value_changed(value):
	var newSize = Vector2(value, EditorMap.getGridSize()[1])
	EditorMap.changeGridSize(newSize)
	reloadVisibility()


func _on_SpinBoxHeight_value_changed(value):
	var newSize = Vector2(EditorMap.getGridSize()[0], value)
	EditorMap.changeGridSize(newSize)
	reloadVisibility()


func setSizeUIValues(size : Vector2):
	$GUILayer/EditPanels/Properties/VBox/Width/SpinBoxWidth.value = size[0]
	$GUILayer/EditPanels/Properties/VBox/Height/SpinBoxHeight.value = size[1]


func _on_StandardPopulation_value_changed(value):
	Population.setTilePopulation(value)


func setPopulationUIValues(pop : int):
	$GUILayer/EditPanels/Properties/VBox/Population/SpinBox.value = pop



####################
# Saving functions #
####################

func saveProject():
	EditorMap.saveMap()
	saveOverlay()


func _on_Save_Menu_button_up():
	saveProject()
	get_tree().change_scene("res://Main Menu/Main Menu.tscn")


func _on_Save_button_up():
	saveProject()



########################
# Visibility functions #
########################

func toggleUIVisibility():
	showUI = !showUI
	GUILayer.updateVisibility(showUI)


func reloadVisibility():
	EditorMap.updateNationalityVisibility(visSettings["Nationality"])
	EditorMap.updateCulturesVisibility(visSettings["Cultures"])
	EditorMap.updateCityVisibility(visSettings["Cities"])
	EditorMap.updateInfrastructureVisibility(visSettings["Infrastructure"])
	EditorMap.updateResourcesVisibility(visSettings["Resources"])
	EditorMap.updateRiversVisibility(visSettings["Rivers"])


func _on_VisNationality_toggled(button_pressed):
	EditorMap.updateNationalityVisibility(button_pressed)
	visSettings["Nationality"] = button_pressed
	nationalityPanel.giveLayerVisibility(button_pressed)


func _on_VisCultures_toggled(button_pressed):
	EditorMap.updateCulturesVisibility(button_pressed)
	visSettings["Cultures"] = button_pressed
	culturesPanel.giveLayerVisibility(button_pressed)


func _on_VisCities_toggled(button_pressed):
	EditorMap.updateCityVisibility(button_pressed)
	visSettings["Cities"] = button_pressed
	citiesPanel.giveLayerVisibility(button_pressed)


func _on_VisResources_toggled(button_pressed):
	EditorMap.updateResourcesVisibility(button_pressed)
	visSettings["Resources"] = button_pressed
	resourcesPanel.giveLayerVisibility(button_pressed)


func _on_VisInfrastructure_toggled(button_pressed):
	EditorMap.updateInfrastructureVisibility(button_pressed)
	visSettings["Infrastructure"] = button_pressed
	infrastructurePanel.giveLayerVisibility(button_pressed)


func _on_VisRivers_toggled(button_pressed):
	EditorMap.updateRiversVisibility(button_pressed)
	visSettings["Rivers"] = button_pressed


func _on_GridOverlay_toggled(button_pressed):
	EditorMap.updateGridOverlayVisibility(button_pressed)



#############################
# Map interaction functions #
#############################

func _on_MapInteractButton_button_down():
	if Input.is_action_pressed("map_editor_select_tile"):
		var pos = mouseGridPosition()
		var tile = EditorMap.selectTile(pos)
		citiesPanel.giveTile(tile, pos)
		if tile == null:
			TileInfoPanel.hide()
			riversPanel.givePos(riversPanel.NOPOS)
		else:
			TileInfoPanel.showTile(tile, pos)
			riversPanel.givePos(pos)


func _on_MapInteractButton_holdDown():
	if !Input.is_action_pressed("map_editor_select_tile"):
		match clickMode:
			TERRAIN:
				var brushPositions = brushPanel.getPositionsUnderBrush(mouseGridPosition(), EditorMap)
				var terrain
				if Input.is_action_pressed("right_mouse"):
					terrain = EditorMap.standardTerrain
				else:
					terrain = terrainPanel.getTerrainType()
				
				for pos in brushPositions:
					EditorMap.editTerrain(pos, terrain)
					
			NATIONALITY:
				var brushPositions = brushPanel.getPositionsUnderBrush(mouseGridPosition(), EditorMap)
				var nationality
				if Input.is_action_pressed("right_mouse"):
					nationality = EditorMap.standardNationality
				else:
					nationality = nationalityPanel.getNationalitySelected()
					
				for pos in brushPositions:
					EditorMap.editNationality(pos, nationality)
					
			CULTURE:
				var brushPositions = brushPanel.getPositionsUnderBrush(mouseGridPosition(), EditorMap)
				var culture
				if Input.is_action_pressed("right_mouse"):
					culture = EditorMap.standardCulture
				else:
					culture = culturesPanel.getCultureSelected()
					
				for pos in brushPositions:
					EditorMap.editCulture(pos, culture)
					
			RESOURCE:
				var resource
				if Input.is_action_pressed("right_mouse"):
					resource = EditorMap.standardResource
				else:
					resource = resourcesPanel.getResourceSelected()
					
				EditorMap.editResource(mouseGridPosition(), resource)
					
			INFRASTRUCTURE:
				var infrastructure = infrastructurePanel.getInfrastructureSelected()
				if Input.is_action_pressed("right_mouse"):
					EditorMap.removeInfrastructure(mouseGridPosition(), infrastructure)
				else:
					EditorMap.addInfrastructure(mouseGridPosition(), infrastructure)
			_:
				pass


func _on_MapInteractButton_button_up():
	if clickMode == TERRAIN or clickMode == NATIONALITY:
		nationsPanel.reset()


# Mouse conversion functions
func mouseGridPosition() -> Vector2:
	return VectorMath.vectInt(get_global_mouse_position()/TileConstants.SIZE)


func _onBrushSizeChanged(size):
	EditorMap.updateBrushCursor(brushPanel.getCursorTexture(), size)



##########################
# Cities Panel functions #
##########################

func _onCityAdded(city : City):
	EditorMap.addCity(city)
	nationsPanel.reset()


func _onCityEdited(city : City):
	nationsPanel.reset()


func _onCityRemoved(city : City):
	EditorMap.removeCity(city)
	nationsPanel.reset()



#################################
# Nationalities Panel functions #
#################################

func _onNationalityCreated(nationality : String):
	EditorMap.createNewNation(nationality)
	nationsPanel.addNation(EditorMap.getNation(nationality))
	

func _onNationalityEdited(nationality : String):
	EditorMap.reloadGraphics()


func _onNationalityRemoved(nationality : String):
	nationsPanel.removeNation(EditorMap.getNation(nationality))
	EditorMap.removeNationality(nationality)



###########################
# Nations Panel functions #
###########################

func loadNationsIntoPanel():
	for nation in EditorMap.getNations():
		nationsPanel.addNation(nation)



############################
# Cultures Panel functions #
############################

func _onCultureCreated(culture : String):
	nationsPanel.reset()


func _onCultureEdited(culture : String):
	EditorMap.reloadGraphics()


func _onCultureRemoved(culture : String):
	EditorMap.removeCulture(culture)
	nationsPanel.reset()



##########################
# Rivers Panel functions #
##########################

func _on_Rivers_riverCreated(riverName, pos):
	EditorMap.createRiver(riverName, pos)


func _on_Rivers_riverEdited(river):
	pass # Replace with function body.


func _on_Rivers_riverRemoved(river):
	EditorMap.removeRiver(river)



#########################
# Map Overlay functions #
#########################

func setOverlayTexture(path : String):
	Overlay.texture = overlayTextures[currentOverlay]


func setOverlayOpacity(value : float):
	Overlay.modulate = Color(1, 1, 1, value)
	overlayOpacities[currentOverlay] = value


func setOverlayScale(value : float):
	Overlay.scale = Vector2(value, value)
	overlayScales[currentOverlay] = value
	

func _on_OverlayScale_value_changed(value):
	setOverlayScale(value)


func _on_OverlayVis_toggled(button_pressed):
	Overlay.visible = button_pressed
	OverlayShortcutLabel.visible = button_pressed


func _on_OverlayLoad_pressed():
	OverlayFile.popup()
	

func _on_OverlayFileDialog_file_selected(path):
	overlayPaths[currentOverlay] = path
	overlayTextures[currentOverlay] = Loading.loadImage(path)
	setOverlayTexture(path)


func _on_OverlayOpacity_value_changed(value):
	setOverlayOpacity(float(value)/255)


func _on_OverlayMenu_overlaySwitch(overlay):
	switchOverlay(overlay)


func switchOverlay(overlay : int):
	currentOverlay = overlay
	
	Overlay.texture = overlayTextures[currentOverlay]
	Overlay.modulate = Color(1, 1, 1, overlayOpacities[currentOverlay])
	Overlay.scale = overlayScales[currentOverlay]*Vector2(1, 1)
	
	OverlayMenu.giveSettings(overlayScales[currentOverlay], overlayOpacities[currentOverlay])


func loadOverlay():
	for i in range(overlayAmount):
		overlayPaths.append("")
		overlayTextures.append(null)
		overlayOpacities.append(0.5)
		overlayScales.append(1)
	
	var path = LoadInfo.getGamedataLocation() + "overlays.json"
	if Loading.exists(path):
		var overlaySettings = Loading.loadDictFromJSON(path)
		for i in overlaySettings:
			var overlaySetting = overlaySettings[i]
			var ii = int(i)
			overlayPaths[ii] = overlaySetting["filepath"]
			overlayTextures[ii] = Loading.loadImage(overlayPaths[ii])
			overlayOpacities[ii] = overlaySetting["opacity"]
			overlayScales[ii] = overlaySetting["scale"]
		
		switchOverlay(currentOverlay)


func saveOverlay():
	var overlaySettings = {}
	for i in range(overlayAmount):
		var overlaySetting = {
			"filepath"	:	overlayPaths[i],
			"opacity"	:	overlayOpacities[i],
			"scale"		:	overlayScales[i]
		}
		overlaySettings[i] = overlaySetting
	
	Saving.saveDictToJSON(LoadInfo.getGamedataLocation() + "overlays.json", overlaySettings)






