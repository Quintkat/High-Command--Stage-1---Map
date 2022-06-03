extends Node
class_name Subtile

var riverSize : String = Rivers.NONE
var riverDir : String = Rivers.NONE


func select():
	pass


func deselect():
	pass


func setRiver(size, dir):
	riverSize = size
	riverDir = dir


func hasRiver():
	return riverSize != Rivers.NONE


func getRiverSize():
	return riverSize


func getRiverDir():
	return riverDir

