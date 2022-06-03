extends PanelContainer


onready var Select = $VBox/Draw/VBox/Select
onready var RemoveButton = $VBox/Draw/VBox/Remove
onready var Name = $VBox/New/VBox/Name/TextEdit
onready var Colour = $VBox/New/VBox/Colour/ColorPickerButton
onready var Save = $VBox/New/VBox/Save
var brush

const DEFAULT = Cultures.DEFAULT
var selected = DEFAULT
var editing = false

signal cultureCreated(culture)
signal cultureEdited(culture)
signal cultureRemoved(culture)


func _ready():
	populateSelect()


func _process(delta):
	if visible:
		if isEditing():
			if !editing:
				Colour.color = Cultures.colour(Name.text)
			editing = true
			Save.text = "Save edit to Culture"
			Save.disabled = Colour.color in Cultures.getColours() and Colour.color != Cultures.colour(Name.text)
		else:
			editing = false
			Save.text = "Save as new Culture"
			Save.disabled = Colour.color in Cultures.getColours()


func populateSelect():
	Select.clear()
	
	Select.add_item(DEFAULT, 0)
	Select.set_item_icon(0, createIcon(Cultures.colour(DEFAULT)))
	_on_Select_item_selected(0)
	Select.select(0)
	
	var all = Cultures.getAll()
	for i in range(len(all)):
		Select.add_item(all[i], i + 1)
		Select.set_item_icon(i + 1, createIcon(Cultures.colour(all[i])))
		if Cultures.sprite(all[i]) == null:
			Cultures.overwriteSprite(all[i], createTexture(Cultures.colour(all[i])))


func getCultureSelected() -> String:
	return selected



######################
# Creation functions #
######################

func _on_Save_pressed():
	var culture = Name.text
	var colour = Colour.color
	if isEditing():
		Cultures.editColour(culture, colour)
		Cultures.overwriteSprite(culture, createTexture(colour))
		emit_signal("cultureEdited", culture)
	else:
		Cultures.addCulture(culture, colour)
		Cultures.overwriteSprite(culture, createTexture(colour))
		emit_signal("cultureCreated", culture)
	
	populateSelect()
	

func isEditing():
	return Name.text in Cultures.getAll()


func createImage(col : Color) -> Image:
	return TextureCreator.createImage(col)


func createTexture(col : Color) -> ImageTexture:
	return TextureCreator.createTexture(col)


func createIcon(col : Color) -> ImageTexture:
	return TextureCreator.createIcon(col)


func _on_Remove_pressed():
	emit_signal("cultureRemoved", selected)
	Cultures.removeCulture(selected)
	populateSelect()
	selected = DEFAULT


func _on_Select_item_selected(index):
	selected = Select.get_item_text(index)



###########################
# Miscellaneous functions #
###########################

func addBrush(b : Brush):
	b.removeFromParent()
	brush = b
	brush.setMode(brush.CULTURE)
	$VBox/Draw/VBox.add_child(brush)
	$VBox/Draw/VBox.move_child(brush, 0)


func giveLayerVisibility(vis : bool):
	$VBox/Warning.visible = !vis
