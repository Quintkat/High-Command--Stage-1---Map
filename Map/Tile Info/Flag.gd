extends TextureRect


func upd(tile : Tile):
	if tile.getNationality() == Nationality.DEFAULT:
		visible = false
	else:
		visible = true
		texture = Nationality.getFlag(tile.getNationality())
