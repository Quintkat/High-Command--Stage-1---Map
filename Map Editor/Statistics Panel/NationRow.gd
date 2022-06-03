extends HBoxContainer
class_name NationRow


onready var Name = $Name
onready var Tiles = $Tiles
onready var Cities = $Cities
onready var Pop = $Population
onready var PopUrban = $PopulationUrban
onready var PopRural = $PopulationRural
onready var IC = $IC
onready var Food = $Food
onready var Aluminium = $Aluminium
onready var Oil = $Oil
onready var Steel = $Steel
onready var Sulphur = $Sulhpur


var nation : Nation = null


func giveNation(n : Nation):
	nation = n


func calculateEntries():
	if nation == null:
		return
	
	Name.text = nation.getName()
	Tiles.text =  Misc.commaSep(len(nation.getTiles()))
	Cities.text =  Misc.commaSep(len(nation.getCities()))
	
	var popU = nation.getUrbanPopulation()
	var popR = nation.getRuralPopulation()
	Pop.text = Misc.commaSep(popU + popR)
	PopUrban.text = Misc.commaSep(popU)
	PopRural.text = Misc.commaSep(popR)
	
	var resources = nation.getResourceReach()
	IC.text = Misc.commaSep(nation.getIC())
	Food.text =  Misc.commaSep(nation.getFood())
	Aluminium.text =  Misc.commaSep(resources[Resources.ALUMINIUM])
	Oil.text =  Misc.commaSep(resources[Resources.OIL])
	Steel.text =  Misc.commaSep(resources[Resources.STEEL])
	Sulphur.text =  Misc.commaSep(resources[Resources.SULPHUR])


func setColumnMinWidth(i : int, s : int):
	get_children()[i].rect_min_size = Vector2(s, 0)


func getColumnsAmount() -> int:
	return len(get_children())


func getColumnString(i : int) -> String:
	return get_children()[i].text


func getColumnValueInt(i : int) -> int:
	return int(get_children()[i].text)
#	return Misc.commaSepToInt(get_children()[i].text)






















