extends WindowDialog


var Emap : EditorMap
var nations : Dictionary
var grid : Grid
export var isMapEditing = false
onready var NationsContainer = $ScrollContainer/Nations


func init(ns : Dictionary, g : Grid):
	nations = ns
	grid = g


func _on_Recalculate_pressed():
	if isMapEditing:
		for n in nations:
			var nation : Nation = nations[n]
			nation.clearTiles()
			nation.clearResourceReach()
			# Clearing of cities not necessary, as thpse are already properly bookkept in EditorMap
		
		Population.resetRNG()
		for x in range(grid.getSize()[0]):
			for y in range(grid.getSize()[1]):
				var pos = Vector2(x, y)
				var tile = grid.getTile(pos)
				if tile == null:
					continue
				
				tile.setPopulation(Population.getTilePopulation(tile))
				
				var nat = tile.getNationality()
				if nat != Nationality.DEFAULT:
					var nation : Nation = nations[nat]
					nation.addTile(tile, pos)
	
	NationsContainer.clearNations()
	for nation in nations.values():
		NationsContainer.addNation(nation)
	NationsContainer.resizeColumns()


func _on_ViewStatistics_pressed():
	popup()
	_on_Recalculate_pressed()
