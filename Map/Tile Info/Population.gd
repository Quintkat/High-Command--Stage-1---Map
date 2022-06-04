extends Label


func upd(tile : Tile):
	var pop = tile.getPopulation()
	if tile.hasCity():
		pop += tile.getCity().getPopulation()
	text = "Population: " + Misc.commaSep(pop)
