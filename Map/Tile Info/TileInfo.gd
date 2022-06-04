extends CanvasLayer

onready var Title = $Title
onready var Flag = $Basic/HBoxContainer/Flag
onready var Ter = $Basic/HBoxContainer/VBoxContainer/Terrain
onready var Pop = $Basic/HBoxContainer/VBoxContainer/Population
onready var CityL = $Features/City
onready var IndCap = $Features/IndustrialCapacity
onready var Res = $Features/Resource
onready var Riv = $Features2/River

var children


func _ready():
	children = [Title, Flag, Ter, Pop, CityL, IndCap, Res, Riv]


func show(tile : Tile):
	for child in children:
		child.upd(tile)
