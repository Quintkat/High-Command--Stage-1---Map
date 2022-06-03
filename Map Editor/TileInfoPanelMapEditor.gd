extends PanelContainer

onready var Position = $HBox/Left/Position
onready var TerrainL = $HBox/Left/Terrain
onready var NationalityL = $HBox/Left/Nationality
onready var Culture = $HBox/Left/Culture
onready var RiverL = $HBox/Left/River
onready var CityL = $HBox/Right/City
onready var IC = $HBox/Right/IC
onready var Road = $HBox/Right/Road
onready var Railroad = $HBox/Right/Railroad
onready var ResourceL = $HBox/Right/Resource


func showTile(tile : Tile, pos : Vector2):
	Position.text = "Position: " + str(pos)
	TerrainL.text = "Terrain: " + str(tile.getTerrain())
	NationalityL.text = "Nationality: " + str(tile.getNationality())
	Culture.text = "Culture: " + str(tile.getCulture())
	RiverL.text = "River: " + str(tile.getRiverName())
	
	CityL.text = "City: "
	IC.text = "City IC: "
	if tile.hasCity():
		var city = tile.getCity()
		CityL.text += str(city.getName())
		IC.text += str(city.getIC())
	else:
		CityL.text += "none"
		IC.text += "none"
	
	Road.text = "Road: "
	if tile.hasRoad():
		Road.text += "yes"
	else:
		Road.text += "no"
	
	Railroad.text = "Railroad: "
	if tile.hasRailroad():
		Railroad.text += "yes"
	else:
		Railroad.text += "no"
	
	ResourceL.text = "Resource: " + str(tile.getResource())


func hide():
	for l in $HBox/Left.get_children():
		l.text = ""
	
	for l in $HBox/Right.get_children():
		l.text = ""

