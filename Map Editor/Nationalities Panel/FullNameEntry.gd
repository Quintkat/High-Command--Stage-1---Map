extends HBoxContainer

var govForm : String

func setGovForm(gf : String):
	govForm = gf
	$Label.text = govForm + ": "


func getGovForm() -> String:
	return govForm


func setText(t : String):
	$TextEdit.text = t


func getText() -> String:
	return $TextEdit.text


func getEntryBox():
	return $TextEdit
