extends PanelContainer


onready var Nations = $VBox/Scroll/Nations

const nationEditScene = preload("res://Map Editor/Nations Panel/NationEdit.tscn")

var nationEdits = []


func _ready():
	pass


func addNation(nation : Nation):
	var newNE = nationEditScene.instance()
	Nations.add_child(newNE)
	newNE.setNation(nation)
	nationEdits.append(newNE)


func removeNation(nation : Nation):
	for ne in nationEdits:
		if ne.getNation() == nation:
			remove_child(ne)
			nationEdits.erase(ne)
			ne.queue_free()


func reset():
	for ne in nationEdits:
		ne.reset()

