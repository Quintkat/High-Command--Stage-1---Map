extends Node

const NONE = "none"
const VERTICAL = "North-South"
const HORIZONTAL = "East-West"
const BOTH = "Both"

const SMALL = "small"
const MEDIUM = "medium"
const LARGE = "large"
const sizes = [SMALL, MEDIUM, LARGE]

const sizePresets = {
	"small"		:	1.0/6,
	"medium"	:	2.0/6,
	"large"		:	1.0/2
}

var colour : Color = Terrain.colour(Terrain.LAKE)


func getWidthFactor(size : String):
	return sizePresets[size]


func getVH(dir : String) -> String:
	if dir == "North" or dir == "South":
		return VERTICAL
	if dir == "East" or dir == "West":
		return HORIZONTAL
	return NONE
