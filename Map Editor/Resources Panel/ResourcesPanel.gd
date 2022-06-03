extends PanelContainer


onready var Warning = $VBox/Warning
onready var SelectedLabel = $VBox/Label

var selected = Resources.NONE


func getResourceSelected() -> String:
	return selected



###############################
# Button connection functions #
###############################

func updateLabel():
	SelectedLabel.text = "Infrastructure selected: " + str(selected)


func _on_Aluminium_pressed():
	selected = Resources.ALUMINIUM
	updateLabel()


func _on_Oil_pressed():
	selected = Resources.OIL
	updateLabel()


func _on_Steel_pressed():
	selected = Resources.STEEL
	updateLabel()


func _on_Sulphur_pressed():
	selected = Resources.SULPHUR
	updateLabel()



###########################
# Miscellaneous functions #
###########################

func giveLayerVisibility(vis : bool):
	Warning.visible = !vis



