extends Node
class_name River

# Constants
#const RiverSegment = preload("res://Map/River/RiverSegment.tscn")
const RiverTile = preload("res://Map/River/RiverTile.tscn")
const dirs = {
	"N" : "North",
	"E" : "East",
	"S" : "South",
	"W" : "West"
}
const dirVectors = {
	"North"	:	Vector2(0, -1),
	"East"	:	Vector2(1, 0),
	"South"	:	Vector2(0, 1),
	"West"	:	Vector2(-1, 0)
}
const counterpart = {
	"North"	:	"South",
	"East"	:	"West",
	"South"	:	"North",
	"West"	:	"East"
}

# River info
var rName = ""
var startPos : Vector2

# River actualisation
var tileWidth : int = TileConstants.SIZE
var riverTiles = []
var positions = []
var directions = []
var landFinish : bool

# Map editor variables
var extendsIntoWater : bool = false
var largestSize : String = Rivers.SMALL

# Misc
var grid : Grid


func init(n : String, sp : Vector2, r : Dictionary, lf : bool, g : Grid):
	rName = n
	startPos = sp
	landFinish = lf
	grid = g
	extendsIntoWater = !lf
	setup(r)
	

func setup(segments : Dictionary):
	var cPos = startPos
	var maxSize = "small"		# The max size of the river, necessary to see where the cutoff is
	for size in Rivers.sizes:
		if size in segments:
			if len(segments[size]) > 0:
				maxSize = size
				largestSize = size
	
	for size in Rivers.sizes:
		if !(size in segments):
			continue
		
		for i in range(len(segments[size])):
			var segment = segments[size][i]
			var dir = dirs[segment[0]]	# The "N" in "N3"
			var scalar = int(segment.right(1))	# The 3 in "N3"
			for j in range(scalar):
				# Add segment "leaving" the current tile
				var riverTileCurrent = getRiverTile(cPos)
				riverTileCurrent.addDir(dir, size)
				
				# Add segment on the counterpart side of the next tile
				cPos += dirVectors[dir]
				directions.append(dir)
				var riverTileNext = getRiverTile(cPos)
				riverTileNext.addDir(counterpart[dir], size)
				
			if i == len(segments[size]) - 1 and size == maxSize and !landFinish:
				var riverTileLast = getRiverTile(cPos)
				riverTileLast.addDir(dir, size)
	

func getRiverTile(pos : Vector2):
	var tile = grid.getTile(pos)
	var riverTile
	if tile.hasRiver():
		riverTile = tile.getRiver()
		if !(riverTile in riverTiles):
			riverTiles.append(riverTile)
		if !(pos in positions):
			positions.append(pos)
	else:
		riverTile = RiverTile.instance()
		riverTile.riverName = rName
		riverTiles.append(riverTile)
		tile.addRiver(riverTile)
		positions.append(pos)
	
	return riverTile


func updateVisibility(vis : bool):
	for riverTile in riverTiles:
		riverTile.visible = vis


func getName() -> String:
	return rName


func getRiverTiles() -> Array:
	return riverTiles


func getPositions() -> Array:
	return positions



########################
# Map editor functions #
########################

func customInit(n : String, sp : Vector2, g : Grid):
	rName = n
	startPos = sp
	grid = g
	getRiverTile(startPos)


func delete():
	while getLength() > 1:
		shorten()
	queue_free()


func extend(direction : String, size : String):
	var lastRiverTile : RiverTile = riverTiles.back()
	var lastPosition : Vector2 = positions.back()
	
	var newPosition : Vector2 = lastPosition + dirVectors[direction]
	if !grid.posValid(newPosition):
		return
	
	var newRiverTile : RiverTile = getRiverTile(newPosition)
	lastRiverTile.addDir(direction, size)
	newRiverTile.addDir(counterpart[direction], size)
	directions.append(direction)
	
	var lastTile = grid.getTile(lastPosition)
	var newTile = grid.getTile(newPosition)
	lastTile.deselect()
	newTile.select()
	newTile.updateOrder()
	
	largestSize = size


func extendIntoWater(size : String):
	var lastRiverTile : RiverTile = riverTiles.back()
	lastRiverTile.addDir(directions.back(), size)
	extendsIntoWater = true


func shorten():
	var lastRiverTile : RiverTile = riverTiles.pop_back()
	var lastDir = directions.pop_back()
	lastRiverTile.removeDir(counterpart[lastDir])
	
	var lastTile = grid.getTile(positions.pop_back())
	lastTile.deselect()
	var previousTile = grid.getTile(positions.back())
	previousTile.select()
	
	var previousRiverTile : RiverTile = riverTiles.back()
	previousRiverTile.removeDir(lastDir)
	
	if extendsIntoWater:
		extendsIntoWater = false
		lastRiverTile.removeDir(lastDir)
	
	var previousDir = directions.back()
	if previousDir == null:
		largestSize = Rivers.SMALL
	else:
		largestSize = previousRiverTile.getDirSize(counterpart[directions.back()])
		

func getLastDirection() -> String:
	return directions.back()


func getSaveDict() -> Dictionary:
	var dict = {}
	dict["startX"] = startPos[0]
	dict["startY"] = startPos[1]
	var abbreviations = {
		"North"	:	"N",
		"East"	:	"E",
		"South"	:	"S",
		"West"	:	"W"
	}
	dict["landFinish"] = !extendsIntoWater
	dict[Rivers.SMALL] = []
	dict[Rivers.MEDIUM] = []
	dict[Rivers.LARGE] = []
	
	var currentDir = "none"
	var currentCount = 0
	var currentSize = "none"
	for i in range(len(directions)):
		var rt : RiverTile = riverTiles[i]
		var dir : String = directions[i]
		var size : String = rt.getDirSize(dir)
		var lastHook = false
		currentCount += 1
		
		if dir != currentDir or size != currentSize or i == len(directions) - 1:
			# Since the directions array is always 1 shorter than the rest
			if i == len(directions) - 1:
				# This means that there is one last direction change that would otherwise not be noted
				if dir != currentDir or size != currentSize:
					lastHook = true
				else:
					currentCount += 1
			
			if i > 0:
				var entry = str(abbreviations[currentDir]) + str(currentCount)
				dict[currentSize].append(entry)
			
			currentDir = dir
			currentCount = 0
			currentSize = size
			
			if lastHook:
				var entry = str(abbreviations[currentDir]) + "1"
				dict[currentSize].append(entry)
	
	return dict


func selectLastTile():
	var lastPos = positions.back()
	if lastPos != null:
		grid.getTile(lastPos).select()


func getLargestSize():
	return largestSize


func getLength() -> int:
	return len(positions)













