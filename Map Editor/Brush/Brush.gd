extends PanelContainer
class_name Brush


const CIRCLE = "circle"
const SQUARE = "square"
const DIAMOND = "diamond"
const FILL = "fill"

onready var sizeSpinBox = $VBox/Size/SpinBox

var shape : String = CIRCLE
var size : int

const NONE = "none"
const TERRAIN = "terrain"
const NATIONALITY = "nationality"
const CULTURE = "culture"
var mode = NONE

var cursorCircle = load("res://Map Editor/Brush/cursorCircle.png")
var cursorSquare = load("res://Map Editor/Brush/brushSquare.png")
var cursorDiamond = load("res://Map Editor/Brush/cursorDiamond.png")
var cursorFill = load("res://Map Editor/Brush/cursorFill.png")

signal sizeChanged(size)


func _ready():
	size = sizeSpinBox.value


func _process(delta):
	if Input.is_action_pressed("change_brush_size"):
		if Input.is_action_just_released("brush_size_up"):
			size += 1
			sizeSpinBox.value = size
			size = sizeSpinBox.value
			emit_signal("sizeChanged", size)
		
		if Input.is_action_just_released("brush_size_down"):
			size -= 1
			sizeSpinBox.value = size
			size = sizeSpinBox.value
			emit_signal("sizeChanged", size)


func getCursorTexture() -> StreamTexture:
	match shape:
		CIRCLE:
			return cursorCircle
		SQUARE:
			return cursorSquare
		DIAMOND:
			return cursorDiamond
		FILL:
			return cursorFill
		_:
			return cursorCircle


func _on_Circle_pressed():
	shape = CIRCLE
	emit_signal("sizeChanged", size)


func _on_Square_pressed():
	shape = SQUARE
	emit_signal("sizeChanged", size)


func _on_Diamond_pressed():
	shape = DIAMOND
	emit_signal("sizeChanged", size)


func _on_Fill_pressed():
	shape = FILL
	emit_signal("sizeChanged", size)


func _on_SpinBox_value_changed(value):
	size = value
	emit_signal("sizeChanged", size)


func getPositionsUnderBrush(pos: Vector2, eMap : EditorMap) -> Array:
	var grid = eMap.getGrid()
	var radius = (size - 1)/2
	match shape:
		CIRCLE:
			return grid.getNeighboursPosDistance(pos, radius, true)
		SQUARE:
			return grid.getNeighboursPosSquare(pos, radius, true)
		DIAMOND:
			return grid.getNeighboursPosManhattan(pos, radius, true)
		FILL:
			return getPositionsFill(pos, eMap)
		_:
			return []


func getPositionsFill(pos : Vector2, eMap : EditorMap) -> Array:
	var grid = eMap.getGrid()
	var positions = [pos]
	if mode == NONE:
		return []
	if !grid.posValid(pos):
		return []
	
	var value
	var tilePos = grid.getTile(pos)
	match mode:
		TERRAIN:
			value = tilePos.getTerrain()
		NATIONALITY:
			value = tilePos.getNationality()
		CULTURE:
			value = tilePos.getCulture()
	
	# Breadth-First Search
	var queue = [pos]
	var visited = []
	var counter = 0
	while len(queue) > 0:
		var nextPos = queue.pop_back()
		visited.append(nextPos)
		
		var nsPos = grid.getNeighboursPos(nextPos)
		for n in nsPos.values():
			if !grid.posValid(n):
				continue
			
			if n in visited:
				continue
			
			# Does this position match the criteria?
			var tile = grid.getTile(n)
			var matches = false
			match mode:
				TERRAIN:
					matches = value == tile.getTerrain()
				NATIONALITY:
					matches = tile.isLand() and value == tile.getNationality()
				CULTURE:
					matches = tile.isLand() and value == tile.getCulture()
			
			if matches:
				positions.append(n)
				if !(n in queue):
					queue.append(n)

	return positions


func setMode(m : String):
	mode = m


func removeFromParent():
	var parent = get_parent()
	if parent != null:
		parent.remove_child(self)


func getEntryBoxes() -> Array:
	return [$VBox/Size/SpinBox]







