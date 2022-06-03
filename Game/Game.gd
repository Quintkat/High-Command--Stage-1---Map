extends Node2D

onready var Map = $Map
onready var EscapeMenu = $EscapeMenu

var escape : bool = false


func _ready():
#	print(Debug.getControlCount(self))
	pass


func _process(delta):
	if Input.is_action_just_pressed("escape_menu"):
		escape = !escape
		EscapeMenu.updateInteraction(escape)
		if escape:
			EscapeMenu.layer = GuiInfo.LAYER_ESCAPEMENU
			EscapeMenu.visible(true)
		else:
			EscapeMenu.layer = GuiInfo.IDLELAYER_ESPACEMENU
			EscapeMenu.visible(false)
	
	updateGuiFocus()


func updateGuiFocus():
	GuiInfo.guiFocus = (
		escape or
		false
	)


func _on_Save_button_up():
	Map.saveGame()


func _on_Settings_button_up():
	pass # Replace with function body.


func _on_QuitMenu_button_up():
	Map.saveGame()
	get_tree().change_scene("res://Main Menu/Main Menu.tscn")


func _on_QuitSave_button_up():
	Map.saveGame()
	get_tree().quit()
