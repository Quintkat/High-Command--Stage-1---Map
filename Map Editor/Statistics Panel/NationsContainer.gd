extends VBoxContainer


const nationRowScene = preload("res://Map Editor/Statistics Panel/NationRow.tscn")
const font : DynamicFont = preload("res://Fonts/fontMapEditor.tres")

var nationRows = []
onready var HeaderRow = $HeaderRow
var pressedPrevious
var sortColumn = 0


func _process(delta):
	if visible:
		var hc = HeaderRow.get_children()
		for i in range(len(hc)):
			var button : Button = hc[i]
			if button.pressed and !pressedPrevious:
				pressedPrevious = true
				sortColumn = i
				sortRows()
				break
			else:
				pressedPrevious = false
			

func sortRows():
	if sortColumn == 0:
		nationRows.sort_custom(self, "sortRowsString")
	else:
		nationRows.sort_custom(self, "sortRowsInt")
		
	for i in range(len(nationRows)):
		var nr : NationRow = nationRows[i]
		move_child(nr, i + 1)


func sortRowsInt(a : NationRow, b : NationRow):
	return a.getColumnValueInt(sortColumn) > b.getColumnValueInt(sortColumn)


func sortRowsString(a : NationRow, b : NationRow):
	return a.getColumnString(sortColumn) < b.getColumnString(sortColumn)


func clearNations():
	for nr in nationRows:
		remove_child(nr)
		nr.queue_free()
	nationRows = []


func addNation(nation : Nation):
	var newRow = nationRowScene.instance()
	add_child(newRow)
	newRow.giveNation(nation)
	newRow.calculateEntries()
	nationRows.append(newRow)


func resizeColumns():
	if len(nationRows) == 0:
		return
	
	var nColumns = nationRows[0].getColumnsAmount()
	for i in range(nColumns):
		var maxSize = font.get_string_size(HeaderRow.get_children()[i].text)[0]
		for j in range(len(nationRows)):
			var nr : NationRow = nationRows[j]
			maxSize = max(maxSize, font.get_string_size(nr.getColumnString(i))[0])
		
		for j in range(len(nationRows)):
			var nr : NationRow = nationRows[j]
			nr.setColumnMinWidth(i, maxSize*1.5)
		
		HeaderRow.get_children()[i].rect_min_size = Vector2(maxSize*1.5, 0)
	






















