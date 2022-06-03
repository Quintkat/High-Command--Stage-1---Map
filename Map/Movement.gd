extends Node


const INFINITY : int = 10000000000
const DEFAULT : int = 3

const MOTORISED = "Motorised"
const NON_MOTORISED = "Non"
const UNALTERED = ""


const terrainCost = {
	Terrain.WATER		:	INFINITY,
	Terrain.LAKE		:	INFINITY,
	Terrain.MOUNTAINS	:	4,
	Terrain.HILLS		:	2,
	Terrain.FOREST		:	2,
	Terrain.TAIGA		:	2,
	Terrain.MARSH		:	4,
	Terrain.RAINFOREST	:	4,
}


func terrain(t : String) -> int:
	if t in terrainCost:
		return terrainCost[t]*DEFAULT
	else:
		return DEFAULT


func tileCost(tile : Tile, movementType : String) -> int:
	var cost : int = 0
	cost += terrain(tile.getTerrain())
	if movementType == MOTORISED and (tile.hasRoad() or tile.hasSmallRoad()):
		cost /= DEFAULT
	if movementType == NON_MOTORISED and tile.hasRailroad():
		cost /= DEFAULT
	
	return cost
	
