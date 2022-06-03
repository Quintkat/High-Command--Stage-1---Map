extends PanelContainer


const NATIONALITY = "nationality"
const CULTURES = "cultures"
const CITIES = "cities"
const RESOURCES = "resources"
const INFRASTRUCTURE = "infrastructure"
const RIVERS = "rivers"


func manualToggle(buttonName : String):
	var button = null
	match buttonName:
		NATIONALITY:
			button = $HBox/Grid/VisNationality
		CULTURES:
			button = $HBox/Grid/VisCultures
		CITIES:
			button = $HBox/Grid/VisCities
		RESOURCES:
			button = $HBox/Grid/VisResources
		INFRASTRUCTURE:
			button = $HBox/Grid/VisInfrastructure
		RIVERS:
			button = $HBox/Grid/VisRivers
	
	if button != null:
		button.pressed = !button.pressed


func manualPress(buttonName : String):
	var button = null
	match buttonName:
		NATIONALITY:
			button = $HBox/Grid/VisNationality
		CULTURES:
			button = $HBox/Grid/VisCultures
		CITIES:
			button = $HBox/Grid/VisCities
		RESOURCES:
			button = $HBox/Grid/VisResources
		INFRASTRUCTURE:
			button = $HBox/Grid/VisInfrastructure
		RIVERS:
			button = $HBox/Grid/VisRivers
	
	if button != null:
		button.pressed = true
			
