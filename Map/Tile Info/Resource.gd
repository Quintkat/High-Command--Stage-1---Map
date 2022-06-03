extends Label


func upd(tile : Tile):
	if tile.hasResource():
		visible = true
		text = "Resource:\n" + tile.getResource()
	else:
		visible = false
