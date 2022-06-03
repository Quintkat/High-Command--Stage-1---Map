extends ColorRect

const sizePresets = {
	"small"		:	1.0/6,
	"medium"	:	2.0/6,
	"large"		:	1.0/2
}


func init(tw : int, size : String, length : int, endSegment : bool = false):
	var width = tw*sizePresets[size]
	if endSegment:
		rect_size = Vector2(width, length*tw + tw/2 + tw/3/2)
	else:
		rect_size = Vector2(width, length*tw + tw/3/2)
