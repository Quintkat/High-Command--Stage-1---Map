extends Sprite

var rName : String

func init(resource : String):
	texture = Resources.texture(resource)
	rName = resource
