extends PanelContainer


onready var Select = $VBox/Draw/VBox/Select
onready var RemoveButton = $VBox/Draw/VBox/Remove
onready var Name = $VBox/New/VBox/Name/TextEdit
onready var Colour = $VBox/New/VBox/Colour/ColorPickerButton
onready var Save = $VBox/New/VBox/Save
onready var GovFormsPanel = $VBox/New/VBox/GovFormsPanel
var brush

const DEFAULT = Nationality.DEFAULT
var selected = DEFAULT
var editing = false

signal nationalityCreated(nat)
signal nationalityEdited(nat)
signal nationalityRemoved(nat)


func _ready():
	populateSelect()


func _process(delta):
	if visible:
		GovFormsPanel.setNationality(Name.text)
		if isEditing():
			if !editing:
				Colour.color = Nationality.colour(Name.text)
				GovFormsPanel.loadFullNames()
			editing = true
			Save.text = "Save edit to Nationality"
			Save.disabled = Colour.color in Nationality.getColours() and Colour.color != Nationality.colour(Name.text)
		else:
			editing = false
			Save.text = "Save as new Nationality"
			Save.disabled = Colour.color in Nationality.getColours()



######################
# Creation functions #
######################

func _on_Save_pressed():
	var nat = Name.text
	var colour = Colour.color
	if isEditing():
		Nationality.editColour(nat, colour)
		Nationality.overwriteSprite(nat, createTexture(colour))
		emit_signal("nationalityEdited", nat)
	else:
		Nationality.addNationality(nat, colour)
		Nationality.overwriteSprite(nat, createTexture(colour))
		emit_signal("nationalityCreated", nat)
	
	GovFormsPanel.saveFullNames()
	populateSelect()
	

func isEditing():
	return Name.text in Nationality.getAll()



#####################
# Drawing functions #
#####################

func getNationalitySelected() -> String:
	return selected


func _on_Select_item_selected(index):
	selected = Select.get_item_text(index)


func populateSelect():
	Select.clear()
	
	Select.add_item(DEFAULT, 0)
	Select.set_item_icon(0, createIcon(Nationality.colour(DEFAULT)))
	_on_Select_item_selected(0)
	Select.select(0)
	
	var all = Nationality.getAll()
	for i in range(len(all)):
		Select.add_item(all[i], i + 1)
		Select.set_item_icon(i + 1, createIcon(Nationality.colour(all[i])))
		if Nationality.sprite(all[i]) == null:
			Nationality.overwriteSprite(all[i], createTexture(Nationality.colour(all[i])))


func _on_Remove_pressed():
	emit_signal("nationalityRemoved", selected)
	Nationality.removeNationality(selected)
	populateSelect()
	selected = Select.get_item_text(0)


func createImage(col : Color) -> Image:
	return TextureCreator.createImage(col)


func createTexture(col : Color) -> ImageTexture:
	return TextureCreator.createTexture(col)


func createIcon(col : Color) -> ImageTexture:
	return TextureCreator.createIcon(col)



###########################
# Miscellaneous functions #
###########################

func addBrush(b : Brush):
	b.removeFromParent()
	brush = b
	brush.setMode(brush.NATIONALITY)
	$VBox/Draw/VBox.add_child(brush)
	$VBox/Draw/VBox.move_child(brush, 0)


func getEntryBoxes() -> Array:
	var govFormEntries = GovFormsPanel.getEntryBoxes()
	var entries = [
		Name,
		Colour
	]
	for e in govFormEntries:
		entries.append(e)
	return entries


func giveLayerVisibility(vis : bool):
	$VBox/Warning.visible = !vis

