extends PanelContainer


onready var Warning = $VBox/Warning
onready var Select = $VBox/Selection/OptionButton
onready var CreateButton = $VBox/Create/VBox/Create
onready var CreateLabel = $VBox/Create/VBox/LabelTile
onready var Name = $VBox/Create/VBox/TextEdit
onready var Buttons = $VBox/EditButtons
onready var North = $VBox/EditButtons/Grid/North
onready var East = $VBox/EditButtons/Grid/East
onready var West = $VBox/EditButtons/Grid/West
onready var South = $VBox/EditButtons/Grid/South
onready var Back = $VBox/EditButtons/Grid/Back
onready var End = $VBox/End
onready var Small = $VBox/Sizes/Small
onready var Medium = $VBox/Sizes/Medium
onready var Large = $VBox/Sizes/Large

const NOPOS = Vector2(-1, -1)
var position : Vector2 = NOPOS
var eMap : EditorMap

var currentRiver : River = null
var size : String = Rivers.LARGE

signal riverCreated(riverName, pos)
signal riverEdited(river)
signal riverRemoved(river)


func _process(delta):
	Buttons.visible = currentRiver != null or (!Small.pressed and !Medium.pressed and !Large.pressed)
	End.visible = currentRiver != null or (!Small.pressed and !Medium.pressed and !Large.pressed)
	CreateButton.visible = position != NOPOS
	if eMap != null:
		CreateButton.disabled = Name.text in eMap.getRivers()
	CreateLabel.visible = position == NOPOS


func giveEditorMap(e : EditorMap):
	eMap = e


func givePos(pos : Vector2):
	position = pos



######################
# Creation functions #
######################

func _on_Create_pressed():
	var riverName = Name.text
	emit_signal("riverCreated", riverName, position)
	Name.text = ""
	populateSelect()



#######################
# Selection functions #
#######################

func populateSelect():
	Select.clear()
	Select.add_item("none", 0)
	Select.set_item_metadata(0, null)
	
	var rivers = eMap.getRivers().values()
	for i in range(len(rivers)):
		var river : River = rivers[i]
		Select.add_item(river.getName(), i + 1)
		Select.set_item_metadata(i + 1, river)
	
	Select.select(0)
		

func _on_OptionButton_item_selected(index):
	currentRiver = Select.get_item_metadata(index)
	updateButtons()
	if currentRiver != null:
		currentRiver.selectLastTile()


func _on_Remove_pressed():
	if currentRiver != null:
		emit_signal("riverRemoved", currentRiver)
		currentRiver.delete()
		currentRiver = null
		populateSelect()



#########################
# Size button functions #
#########################

func _on_Small_pressed():
	size = Rivers.SMALL


func _on_Medium_pressed():
	size = Rivers.MEDIUM


func _on_Large_pressed():
	size = Rivers.LARGE



###################################
# River editing buttons functions #
###################################

func extendRiver(dir : String):
	currentRiver.extend(dir, size)


func _on_North_pressed():
	extendRiver("North")
	updateButtons()


func _on_West_pressed():
	extendRiver("West")
	updateButtons()


func _on_East_pressed():
	extendRiver("East")
	updateButtons()


func _on_South_pressed():
	extendRiver("South")
	updateButtons()


func _on_Back_pressed():
	currentRiver.shorten()
	updateButtons()


func _on_End_pressed():
	currentRiver.extendIntoWater(size)
	updateButtons()


func updateButtons():
	if currentRiver != null:
		var dir = currentRiver.getLastDirection()
		North.disabled = dir == "South"
		West.disabled = dir == "East"
		East.disabled = dir == "West"
		South.disabled = dir == "North"
		
		var length = currentRiver.getLength()
		Back.disabled = length <= 1
		End.disabled = length <= 1 or currentRiver.extendsIntoWater
		
		var largestSize = currentRiver.getLargestSize()
		Small.disabled = largestSize in [Rivers.MEDIUM, Rivers.LARGE]
		Medium.disabled = largestSize == Rivers.LARGE



###########################
# Miscellaneous functions #
###########################

func giveLayerVisibility(vis : bool):
	Warning.visible = !vis










