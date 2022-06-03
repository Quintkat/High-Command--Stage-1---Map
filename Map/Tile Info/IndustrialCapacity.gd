extends Label


func upd(tile : Tile):
	if tile.hasCity():
		visible = true
		var city = tile.getCity()
		text = "Industry:\n" + str(city.getIC())
	else:
		visible = false
