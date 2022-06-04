extends Label


func upd(tile : Tile):
	if tile.hasRiver():
		visible = true
		text = "River:\n" + tile.getRiverName()
	else:
		visible = false
