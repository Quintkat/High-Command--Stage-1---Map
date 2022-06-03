extends Node


# PQ moved into its own class, not necessary anymore
class PriorityQueue:
	var queue : Dictionary = {}
	var vectors : Dictionary = {}
	var keyList : Array = []


	func addPos(pos : Vector2, distance : int):
		if !(distance in queue):
			queue[distance] = []
			keyList.append(distance)
			keyList.sort()

		queue[distance].append(pos)
		vectors[pos] = distance


	func getVecDist(pos : Vector2):
		return vectors[pos]


	func updateDistance(pos : Vector2, distance : int):
		queue[vectors[pos]].erase(pos)
		addPos(pos, distance)


	func getNext():
		for distance in keyList:
			if len(queue[distance]) > 0:
				return queue[distance].pop_front()

		return null


	func printQueue():
		for distance in keyList:
			print(distance, ":\t", queue[distance])



func calcPath(
		grid : Grid, 
		startPos : Vector2, 
		endPos : Vector2, 
		moveType : String = Movement.UNALTERED, 
		nationalities : Array = Nationality.getAll(), 
		infrastructureOnly : bool = false, 
		debug : bool = false
		) -> Array:
	
	var Q = VectorPriorityQueue.new()
	Q.addPos(startPos, 0)
	var predecessor = {}
	predecessor[startPos] = null
	var costSoFar = {}
	costSoFar[startPos] = 0
	
	# A* algorithm
	var current = Q.getNext()
	while current != null:
		if current == endPos:
			break
		
		var neighbours = grid.getNeighboursPos(current)
		for neighbour in neighbours.values():
			# If the position is off the grid
			if !grid.posValid(neighbour):
				continue
			
			# Check for nationality
			if nationalities != Nationality.getAll():
				if !(grid.getTile(neighbour).getNationality() in nationalities):
					continue

			# Check for infrastructure
			if infrastructureOnly:
				if !grid.getTile(neighbour).hasInfrastructure():
					continue
			
			# Check if new way of getting here is shorter than old one, if so, update predecessor
			var costNew = costSoFar[current] + Movement.tileCost(grid.getTile(neighbour), moveType)
			if costNew >= Movement.INFINITY:
				continue
			if !(neighbour in costSoFar) or costNew < costSoFar[neighbour]:
				costSoFar[neighbour] = costNew
				Q.addPos(neighbour, costNew + heuristic(neighbour, endPos))
				predecessor[neighbour] = current
		
		current = Q.getNext()
		if debug:
			grid.getTile(current).select()
		
	# Form path from predecessors
	var path = []
	if !(endPos in predecessor):
		return path
	
	var previous = predecessor[endPos]
	if previous != null:
		path.append(endPos)
	
	while previous != null:
		path.append(previous)
		previous = predecessor[previous]
	path.invert()
	
	return path


func heuristic(a : Vector2, b : Vector2):
	return int(Movement.DEFAULT*a.distance_to(b))

#func getTile(grid : Array, pos : Vector2) -> Tile:
#	if !posValid(grid, pos):
#		return null
#	return grid[pos[0]][pos[1]]
#
#
#func posValid(grid : Array, pos : Vector2) -> bool:
#	return pos[0] >= 0 and pos[1] >= 0 and pos[0] < len(grid) and pos[1] < len(grid[0])
#func _ready():
#	var pq : PriorityQueue = PriorityQueue.new()
#	pq.addPos(Vector2(0, 1), 9)
#	pq.addPos(Vector2(0, 2), 5)
#	pq.addPos(Vector2(0, 3), 4)
#	pq.addPos(Vector2(0, 4), 7)
#	pq.addPos(Vector2(0, 5), 1)
#	pq.addPos(Vector2(0, 6), 15)
#
#	var next = pq.getNext()
#	while next != null:
#		print(next)
#		next = pq.getNext()
