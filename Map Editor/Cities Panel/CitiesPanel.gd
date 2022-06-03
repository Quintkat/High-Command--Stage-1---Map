extends PanelContainer

onready var NoSelection = $NoSelection
onready var Edit = $EditCity
onready var EditButton = $EditCity/Edit
onready var Name = $EditCity/Name/TextEdit
onready var Pop = $EditCity/Population/SpinBox
onready var IC = $EditCity/IC/SpinBox
onready var RemoveButton = $EditCity/Remove
onready var Warning = $EditCity/Warning
onready var MediumCity = $EditScale/Medium/SpinBox
onready var LargeCity = $EditScale/Large/SpinBox

var selected : Tile = null
var position : Vector2
var city : City = null

const cityScene = preload("res://Map/Tile/City/City.tscn")

signal cityAdded(city)
signal cityEdited(city)
signal cityRemoved(cityName)
signal popScaleUpdated()


func _ready():
	MediumCity.value = Population.getCityGraphicsMedium()
	LargeCity.value = Population.getCityGraphicsLarge()


func giveTile(tile : Tile, pos : Vector2):
	selected = tile
	position = pos
	if selected == null:
		NoSelection.visible = true
		Edit.visible = false
	else:
		NoSelection.visible = false
		Edit.visible = true
		loadInfo()


func loadInfo():
	if selected.hasCity():
		city = selected.getCity()
		EditButton.text = "Save Edit to City"
		Name.text = city.getName()
		Pop.value = city.getPopulation()
		IC.value = city.getIC()
		RemoveButton.visible = true
	else:
		city = null
		EditButton.text = "Create City"
		Name.text = ""
		Pop.value = 0
		IC.value = 0
		RemoveButton.visible = false


func saveCity():
	city = getCity()
	city.updateName(Name.text)
	city.updatePopulation(Pop.value)
	city.updateIC(IC.value)
	loadInfo()
	emit_signal("cityEdited", city)


func removeCity():
	emit_signal("cityRemoved", city)
	selected.removeCity()
	loadInfo()


func getCity() -> City:
	if selected.hasCity():
		return selected.getCity()
	else:
		var newCity : City = cityScene.instance()
		selected.addCity(newCity)
		newCity.init(Name.text, Pop.value, IC.value, position)
		selected.updateOrder()
		emit_signal("cityAdded", selected.getCity())
		return newCity


func _on_Edit_pressed():
	saveCity()


func _on_Remove_pressed():
	removeCity()



##############################
# Population threshold functions #
##############################


func _on_MediumCity_value_changed(value):
	Population.setCityGraphicsMedium(MediumCity.value)
	emit_signal("popScaleUpdated")


func _on_LargeCity_value_changed(value):
	Population.setCityGraphicsLarge(LargeCity.value)
	emit_signal("popScaleUpdated")



###########################
# Miscellaneous functions #
###########################

func getEntryBoxes():
	return [
		Name,
		IC
	]


func giveLayerVisibility(vis : bool):
	Warning.visible = !vis








