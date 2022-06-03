extends PanelContainer


onready var Top = $VBox/Top
onready var Opacity = $VBox/Bottom/HSlider
onready var OpacityLabel = $VBox/Bottom/Label
onready var Scale = $VBox/Top/SpinBox
onready var Vis = $VBox/Bottom/CheckBox


func _process(delta):
	if Input.is_action_just_pressed("map_editor_toggle_overlay"):
		Vis.pressed = !Vis.pressed


func giveSettings(settings : Dictionary):
	Scale.value = settings["scale"]
	Opacity.value = settings["opacity"]*255


########################
# Visibility functions #
########################

func _on_CheckBox_toggled(button_pressed):
	Top.visible = button_pressed
	Opacity.visible = button_pressed
	OpacityLabel.visible = button_pressed
