extends Node

var tilePopulation = 10000
var rng
const factorMean = 1
const factorSD = 0.1

var cityGraphicsMedium : int = 100000
var cityGraphicsLarge : int = 500000

const terrainFactor = {
	Terrain.DEFAULT		:	0.0,
	Terrain.WATER		:	0.0,
	Terrain.LAKE		:	0.0,
	Terrain.MARSH		:	0.12,
	Terrain.BRIDGE		:	0.0,
	Terrain.PLAINS		:	0.8,
	Terrain.FOREST		:	0.6,
	Terrain.TAIGA		:	0.12,
	Terrain.HILLS		:	0.8,
	Terrain.MOUNTAINS	:	0.2,
	Terrain.SAVANNA		:	0.22,
	Terrain.DESERT		:	0.04,
	Terrain.FARMLAND	:	1.4,
	Terrain.CITY		:	2.5,
	Terrain.RAINFOREST	:	0.35,
	Terrain.STEPPES		:	0.3,
	Terrain.ICE			:	0.0,
	Terrain.TUNDRA		:	0.04,
	Terrain.COLDDESERT	:	0.1,
}


func _ready():
	resetRNG()


func resetRNG():
	rng = RandomNumberGenerator.new()
	rng.set_seed(hash("Penis"))


func setTilePopulation(p : int):
	tilePopulation = p


func getTilePopulationStandard() -> int:
	return tilePopulation


func setCityGraphicsMedium(t : int):
	cityGraphicsMedium = t


func getCityGraphicsMedium() -> int:
	return cityGraphicsMedium


func setCityGraphicsLarge(t : int):
	cityGraphicsLarge = t


func getCityGraphicsLarge() -> int:
	return cityGraphicsLarge


func getTilePopulation(tile) -> int:
	var factor = rng.randfn(factorMean, factorSD)
	var result = int(factor*tilePopulation*terrainFactor[tile.getTerrain()])
#	if tile.hasCity():
#		result += tile.getCity().getPopulation()
	
	return result


func getCityPopulation(city) -> int:
	var ic = city.IC
	var factor = 71068
	return int(ic*factor)
