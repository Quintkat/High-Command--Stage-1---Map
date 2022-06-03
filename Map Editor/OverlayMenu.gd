extends PanelContainer


onready var Top = $VBox/Top
onready var Opacity = $VBox/Bottom/HSlider
onready var OpacityLabel = $VBox/Bottom/Label
onready var Scale = $VBox/Top/SpinBox
onready var Vis = $VBox/Bottom/CheckBox
onready var Overlay1 = $VBox/Top/Overlay1
onready var Overlay2 = $VBox/Top/Overlay2
onready var Overlay3 = $VBox/Top/Overlay3
onready var Overlay4 = $VBox/Top/Overlay4
onready var Overlay5 = $VBox/Top/Overlay5


signal overlaySwitch(overlay)


func _process(delta):
	if Input.is_action_just_pressed("map_editor_toggle_overlay"):
		Vis.pressed = !Vis.pressed
	
	if Input.is_action_just_pressed("ui_f8"):
		Overlay1.pressed = true
		emit_signal("overlaySwitch", 0)
	
	if Input.is_action_just_pressed("ui_f9"):
		Overlay2.pressed = true
		emit_signal("overlaySwitch", 1)
	
	if Input.is_action_just_pressed("ui_f10"):
		Overlay3.pressed = true
		emit_signal("overlaySwitch", 2)
	
	if Input.is_action_just_pressed("ui_f11"):
		Overlay4.pressed = true
		emit_signal("overlaySwitch", 3)
	
	if Input.is_action_just_pressed("ui_f12"):
		Overlay5.pressed = true
		emit_signal("overlaySwitch", 4)


func _on_Overlay1_pressed():
	emit_signal("overlaySwitch", 0)


func _on_Overlay2_pressed():
	emit_signal("overlaySwitch", 1)


func _on_Overlay3_pressed():
	emit_signal("overlaySwitch", 2)


func _on_Overlay4_pressed():
	emit_signal("overlaySwitch", 3)


func _on_Overlay5_pressed():
	emit_signal("overlaySwitch", 4)


func giveSettings(scale : float, opacity : float):
	Scale.value = scale
	Opacity.value = opacity*255


########################
# Visibility functions #
########################

func _on_CheckBox_toggled(button_pressed):
	Top.visible = button_pressed
	Opacity.visible = button_pressed
	OpacityLabel.visible = button_pressed

