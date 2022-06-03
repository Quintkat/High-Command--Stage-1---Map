extends VBoxContainer

onready var Name = $Name/Label
onready var Warning = $Name/TextureRect
onready var Government = $Options1/GovForm
onready var Capital = $Options1/Capital
onready var Culture = $Options2/Culture

var nation : Nation

const NOCITY = "none"


func _ready():
	var gfs = GovForm.getAll()
	for i in range(len(gfs)):
		Government.add_item(gfs[i], i)
		

func _process(delta):
	Warning.visible = nation.getCapital() == null


func setNation(n : Nation):
	nation = n
	Name.text = nation.getName()
	reset()


func getNation() -> Nation:
	return nation


func reset():
	updateGovernment()
	populateCapital()
	populateCulture()


func updateGovernment():
	Government.select(findGFID(nation.getGovernmentForm()))


func populateCapital():
	Capital.clear()
	Capital.add_item(NOCITY, 0)
	var cities = nation.getCities()
	for i in range(len(cities)):
		var city : City = cities[i]
		if is_instance_valid(city):
			Capital.add_item(city.getName(), i + 1)
			Capital.set_item_metadata(i + 1, city)
	
	if nation.getCapital() == null:
		Capital.select(0)
	else:
		var capID = findCityID(nation.getCapital())
		Capital.select(capID)
		if Capital.get_item_metadata(capID) != nation.getCapital():
			nation.updateCapital(null)


func populateCulture():
	Culture.clear()
	Culture.add_item(Cultures.DEFAULT, 0)
	var cultures = Cultures.getAll()
	for i in range(len(cultures)):
		Culture.add_item(cultures[i], i + 1)
	
	Culture.select(findCultureID(nation.getCulture()))


func findGFID(gf : String):
	for i in range(Government.get_item_count()):
		if Government.get_item_text(i) == gf:
			return i


func findCityID(c : City):
	for i in range(Capital.get_item_count()):
		if Capital.get_item_metadata(i) == c:
			return i
	return 0


func findCultureID(c : String):
	for i in range(Culture.get_item_count()):
		if Culture.get_item_text(i) == c:
			return i
	return 0


func _on_GovForm_item_selected(index):
	nation.updateGovernmentForm(Government.get_item_text(index))


func _on_Capital_item_selected(index):
	if Capital.get_item_text(index) == NOCITY:
		nation.updateCapital(null)
	else:
		nation.updateCapital(Capital.get_item_metadata(index))


func _on_Culture_item_selected(index):
	nation.setCulture(Culture.get_item_text(index))




