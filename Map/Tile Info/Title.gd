extends Label


func upd(tile : Tile):
	if tile.getNationality() == Nationality.DEFAULT:
		text = tile.getTerrain()
	else:
		text = tile.getTerrain() + " in " + tile.getNationality()
