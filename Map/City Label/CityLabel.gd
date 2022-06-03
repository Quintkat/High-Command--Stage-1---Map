extends Node2D
class_name CityLabel

onready var Lab = $Label


# City info
var gridPos


func init(n : String, pos : Vector2, capital : bool = false):
	gridPos = pos
	Lab.text = n
	if capital:
		Lab.theme = load("res://Map/City Label/CapitalTheme.tres")


func updateCapital(capital : bool):
	if capital:
		Lab.theme = load("res://Map/City Label/CapitalTheme.tres")
		z_index = 1
	else:
		Lab.theme = load("res://Map/City Label/CityTheme.tres")
		z_index = 0
		
