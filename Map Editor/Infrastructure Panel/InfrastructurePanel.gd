extends PanelContainer


onready var Warning = $VBox/Warning
onready var SelectedLabel = $VBox/Label

var selected = Infrastructure.NONE


func getInfrastructureSelected() -> String:
	return selected



###############################
# Button connection functions #
###############################

func updateLabel():
	SelectedLabel.text = "Infrastructure selected: " + str(selected)


func _on_Road_pressed():
	selected = Infrastructure.ROAD
	updateLabel()


func _on_SmallRoad_pressed():
	selected = Infrastructure.SMALLROAD
	updateLabel()


func _on_Railroad_pressed():
	selected = Infrastructure.RAILROAD
	updateLabel()


func _on_Airbase_pressed():
	selected = Infrastructure.AIRBASE
	updateLabel()


###########################
# Miscellaneous functions #
###########################

func giveLayerVisibility(vis : bool):
	Warning.visible = !vis




