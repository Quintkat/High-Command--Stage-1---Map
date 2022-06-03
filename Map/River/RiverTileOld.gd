extends Control
class_name RiverTileOld


#onready var North = $North
#onready var East = $East
#onready var South = $South
#onready var West = $West
onready var RiverJoint = $Joint

const cardinals = ["North", "East", "South", "West"]
const HORIZONTAL = ["East", "West"]
const VERTICAL = ["North", "South"]
const NONE = "none"
var dirSizes = {}
var subtileWidth
var riverName : String = ""


func _ready():
	subtileWidth = $North.rect_size[0]
	for dir in cardinals:
		dirSizes[dir] = NONE


func addDir(dir : String, size : String):
	var node = get_node(dir)
	node.visible = true
	node.rect_scale[0] = Rivers.getWidthFactor(size)
	dirSizes[dir] = size
	resolveJoint()


func removeDir(dir : String):
	var node = get_node(dir)
	node.visible = false
	dirSizes.erase(dir)
	resolveJoint()
	if len(getDirsVisible()) == 0:
		RiverJoint.visible = false


func getSize(dir : String):
	return dirSizes[dir]


func resolveJoint():
	var dirsVisible = getDirsVisible()
	if len(dirsVisible) == 2:
		if Misc.arrayCompare(dirsVisible, HORIZONTAL) or Misc.arrayCompare(dirsVisible, VERTICAL):
			return
		
		RiverJoint.visible = true
		for dir in dirsVisible:
			if dir in HORIZONTAL:
				RiverJoint.rect_scale[1] = Rivers.getWidthFactor(dirSizes[dir])
			
			if dir in VERTICAL:
				RiverJoint.rect_scale[0] = Rivers.getWidthFactor(dirSizes[dir])
				

func getDirsVisible() -> Array:
	var vis = []
	for dir in cardinals:
		if get_node(dir).visible:
			vis.append(dir)
	
	return vis


func getDirection() -> String:
	var dirsVisible = getDirsVisible()
	var hor = isHorizontal()
	var vert = isVertical()
	if hor and vert:
		return Rivers.BOTH
	elif hor:
		return Rivers.HORIZONTAL
	else:
		return Rivers.VERTICAL


func isVertical():
	var dirsVisible = getDirsVisible()
	return "North" in dirsVisible or "South" in dirsVisible


func isHorizontal():
	var dirsVisible = getDirsVisible()
	return "East" in dirsVisible or "West" in dirsVisible
	

func getDirSize(dir : String) -> String:
	return dirSizes[dir]


func getMaxSize() -> String:
	if "large" in dirSizes.values():
		return "large"
	if "medium" in dirSizes.values():
		return "medium"
	return "small"


