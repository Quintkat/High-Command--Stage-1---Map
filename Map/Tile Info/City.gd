extends Label


func upd(tile : Tile):
	if tile.hasCity():
		visible = true
		var city = tile.getCity()
		text = "City:\n" + city.getName()
	else:
		visible = false
