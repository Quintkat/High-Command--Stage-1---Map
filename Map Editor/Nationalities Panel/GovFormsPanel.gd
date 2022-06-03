extends PanelContainer

onready var GovFormsBox = $VBox/ScrollContainer/GovForms

var nationality : String

const entryScene = preload("res://Map Editor/Nationalities Panel/FullNameEntry.tscn")


func _ready():
	populate()


func setNationality(nat : String):
	nationality = nat


func populate():
	for gf in GovForm.getAll():
		var newEntry = entryScene.instance()
		GovFormsBox.add_child(newEntry)
		newEntry.setGovForm(gf)
		newEntry.setText("")


func loadFullNames():
	if nationality in Nationality.getAll():
		var fullNames = Nationality.getFullNames(nationality)
		for entry in GovFormsBox.get_children():
			var gf = entry.getGovForm()
			if gf in fullNames:
				entry.setText(fullNames[gf])
			else:
				entry.setText("")


func saveFullNames():
	var fullNames = {}
	for entry in GovFormsBox.get_children():
		var gf = entry.getGovForm()
		var fullName = entry.getText()
		if fullName != "":
			fullNames[gf] = fullName
	
	Nationality.overwriteFullNames(nationality, fullNames)


func _on_LoadGovForms_pressed():
	loadFullNames()


func getEntryBoxes() -> Array:
	var entries = []
	for child in GovFormsBox.get_children():
		entries.append(child.getEntryBox())
	return entries


