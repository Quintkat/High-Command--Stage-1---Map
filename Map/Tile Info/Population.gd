extends Label


func upd(tile : Tile):
	text = "Population: " + Misc.commaSep(tile.getPopulation())
