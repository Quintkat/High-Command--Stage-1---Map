extends Node
class_name Grid

var width : int = 0
var height : int = 0
var grid : Array = []


func setSize(w : int, h : int):
	width = w
	height = h
	for x in range(w):
		grid.append([])
		for y in range(h):
			grid[x].append(null)


func addTile(pos : Vector2, tile : Tile):
	if posValid(pos):
		grid[pos[0]][pos[1]] = tile
	else:
		print("Error: Trying to add tile at invalid grid position")


# Info retrieving functions
# On grid space
func getTile(pos : Vector2) -> Tile:
	if !posValid(pos):
		return null
	return grid[pos[0]][pos[1]]



#######################
# Neighbour functions #
#######################

# Returns dict with the north, east, south and west neighbours of tile at pos
func getNeighbours(pos : Vector2) -> Dictionary:
	var neighbours = {}
	var nsV = Vector2(0, 1)
	var ewV = Vector2(1, 0)
	neighbours["North"] = getTile(pos - nsV)
	neighbours["South"] = getTile(pos + nsV)
	neighbours["East"] = getTile(pos + ewV)
	neighbours["West"] = getTile(pos - ewV)
	
	return neighbours


# Returns dict with positions of the NESW neighbours of the tile
func getNeighboursPos(pos : Vector2) -> Dictionary:
	var neighbours = {}
	var nsV = Vector2(0, 1)
	var ewV = Vector2(1, 0)
	neighbours["North"] = pos - nsV
	neighbours["South"] = pos + nsV
	neighbours["East"] = pos + ewV
	neighbours["West"] = pos - ewV
	
	return neighbours


func getNeighboursPosSquare(pos : Vector2, d : float, includePos : bool = false) -> Array:
	var positions = []
	var x = pos[0]
	var y = pos[1]
	for i in range(int(x - d), int(x + d + 1)):
		for j in range(int(y - d), int(y + d + 1)):
			if !includePos and i == x and j == y:
				continue
			
			var testPos = Vector2(i, j)
			if posValid(testPos):
				positions.append(testPos)
				
	return positions


func getNeighboursSquare(pos : Vector2, d : float, includePos : bool = false) -> Array:
	var neighbours = []
	for nPos in getNeighboursPosSquare(pos, d, includePos):
		neighbours.append(getTile(nPos))
	
	return neighbours


func getNeighboursPosDistance(pos: Vector2, d : float, includePos : bool = false) -> Array:
	var positions = []
	for nPos in getNeighboursPosSquare(pos, d, includePos):
		if pos.distance_to(nPos) <= d:
			positions.append(nPos)
	
	return positions


# Returns an array with all tiles within a certain distance of the position
func getNeighboursDistance(pos: Vector2, d : float, includePos : bool = false) -> Array:
	var neighbours = []
	for nPos in getNeighboursPosDistance(pos, d, includePos):
		neighbours.append(getTile(nPos))
	
	return neighbours
#	var neighbours = []
#	var x = pos[0]
#	var y = pos[1]
#	for i in range(int(x - d), int(x + d + 1)):
#		for j in range(int(y - d), int(y + d + 1)):
#			# Can't include the tile itself
#			if !includePos and i == x and j == y:
#				continue
#
#			var testPos = Vector2(i, j)
#			if pos.distance_to(testPos) <= d:
#				if posValid(testPos):
#					neighbours.append(getTile(testPos))
#
#	return neighbours
	

# Returns an array with all tiles within a certain distance of the position that are of that position's nationality
func getNeighboursDistanceNationality(pos : Vector2, d : float, includePos : bool = false) -> Array:
	var neighbours = getNeighboursDistance(pos, d, includePos)
	var tile = getTile(pos)
	if tile == null:
		return []
	
	var final = []
	for n in neighbours:
		if n.getNationality() == tile.getNationality():
			final.append(n)
	
	return final


func getNeighboursPosManhattan(pos : Vector2, d : float, includePos : bool = false) -> Array:
	var positions = []
	for nPos in getNeighboursPosSquare(pos, d, includePos):
		if distManhattan(pos, nPos) <= d:
			positions.append(nPos)
	
	return positions


func getNeighboursManhattan(pos : Vector2, d : float, includePos : bool = false) -> Array:
	var neighbours = []
	for nPos in getNeighboursPosManhattan(pos, d, includePos):
		neighbours.append(getTile(nPos))
	
	return neighbours


func distManhattan(a : Vector2, b : Vector2) -> float:
	return abs(a[0] - b[0]) + abs(a[1] - b[1])


func isTileCoastal(pos : Vector2) -> bool:
	var neighbours = getNeighbours(pos)
	for dir in neighbours:
		if neighbours[dir] != null:
			if neighbours[dir].getTerrain() == Terrain.WATER:
				return true
	
	return false


# Grid validity functions
# On grid space
func posValid(pos : Vector2) -> bool:
	return !(pos[0] < 0 || pos[0] >= width || pos[1] < 0 || pos[1] >= height)


func getVerticalSlice(x : int, y1 : int, y2 : int) -> Array:
	return grid[x].slice(y1, y2 + 1)



########################################################################################################
# Map editing functions, SHOULD NOT BE USED OUTSIDE OF MAP EDITOR, AND ARE DANGEROUS TO GRID INTEGRITY #
########################################################################################################

# This function is purely to update the variables, updating the 
func updateSize(w : int, h : int):
	width = w
	height = h


func getSize() -> Vector2:
	return Vector2(width, height)


# Column needs to be pre-filled with tiles
func addTileColumn(column : Array):
	width += 1
	grid.append(column)
	for i in range(len(column)):
		var tile = column[i]
		tile.init(Vector2(width - 1, i))


func removeTileColumn():
	width -= 1
	var popped = grid.pop_back()
	for tile in popped:
		tile.queue_free()
	


# Row needs to be pre-filled with tiles
func addTileRow(row : Array):
	height += 1
	for i in range(len(row)):
		grid[i].append(row[i])
		var tile = row[i]
		tile.init(Vector2(i, height - 1))


func removeTileRow():
	height -= 1
	for i in range(width):
		var popped = grid[i].pop_back()
		popped.queue_free()




