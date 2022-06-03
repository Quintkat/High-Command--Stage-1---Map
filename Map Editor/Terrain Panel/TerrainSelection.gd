extends TextureButton

var terrain : String = Terrain.DEFAULT

signal terrainSelected(type)


func _pressed():
	emit_signal("terrainSelected", terrain)
