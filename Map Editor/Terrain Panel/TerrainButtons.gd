extends VBoxContainer


const TerrainSelectionScene = preload("res://Map Editor/Terrain Panel/TerrainSelection.tscn")
var selected = Terrain.WATER


func _ready():
	onTerrainSelection(selected)
	var allTerrainTypes = Terrain.getAll()
	for type in allTerrainTypes:
		var button = TerrainSelectionScene.instance()
		$TerrainButtons.add_child(button)
		var texture = Terrain.sprite(type)
		var image : Image = texture.get_data()
		image.shrink_x2()
		var newTexture = ImageTexture.new()
		newTexture.create_from_image(image)
		var popFactor = Population.terrainFactor[type]*100
		button.texture_normal = newTexture
		button.terrain = type
		button.hint_tooltip = type + "\nPopulation factor: " + str(popFactor) + "%"
		button.connect("terrainSelected", self, "onTerrainSelection")
		

func onTerrainSelection(type : String):
	selected = type
	$Label.text = "Terrain Selected: " + selected
