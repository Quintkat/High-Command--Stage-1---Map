extends Node
class_name VectorPriorityQueue


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

