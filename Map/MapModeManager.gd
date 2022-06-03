extends Node2D

# Map modes
const DEFAULT = "ui_f1"
var currentMode = DEFAULT
var modes = {
	# Default, no settings here, since the default mode is handled by the map itself
	DEFAULT 	: 	[],
	
	# Terrain map mode
	"ui_f2"		:	[
		"river"
	],
	
	# Infrastructure map mode
	"ui_f3"		:	[
		"city",
		"road",
		"smallroad",
		"railroad",
		"airbase",
		"borders",
		"river"
	],
	
	# Resource map mode
	"ui_f4"		:	[
		"city",
		"road",
		"smallroad",
		"railroad",
		"resource",
		"borders",
		"river"
	],
	
	"ui_f5"		:	[
		"culture",
		"borders"
	],
	
	# Nation map mode
	"ui_f6"		:	[
		"nationality",
		"borders",
		"nationLabel"
	],
	
	# Terrain border map mode
	"ui_f7"		:	[
		"borders",
		"river"
	],
}

const possibleSettings = [
	"nationality",
	"borders",
	"city",
	"road",
	"smallroad",
	"railroad",
	"airbase",
	"resource",
	"nationLabel",
	"river",
	"culture"
]

# Other
var map : Map


func init(m):
	map = m


func _process(delta):
	inputs()
	if !isDefault() && modes[currentMode].has("city"):
		map.updateCityLabelVisibilityAuto()


func inputs():
	for mode in modes:
		if Input.is_action_just_pressed(mode):
			if mode == DEFAULT:
				switchDefault()
				return
				
			if mode in modes:
				if mode != currentMode:
					currentMode = mode
					switchMode(modes[currentMode])
				else:
					switchDefault()
					
			
func switchDefault():
	currentMode = DEFAULT
	map.cameraZoomEvent(true)


func switchMode(settings : Array):
	for setting in possibleSettings:
		setVisibility(setting, setting in settings)


func setVisibility(setting : String, vis : bool):
	match setting:
		"nationality":
			map.updateNationalityVisibility(vis)
		"borders":
			map.updateBorderVisibility(vis)
		"city":
			map.updateCityVisibility(vis)
			map.updateCityLabelVisibility(vis)
		"road":
			map.updateRoadVisibility(vis)
		"smallroad":
			map.updateSmallRoadVisibility(vis)
		"railroad":
			map.updateRailroadVisibility(vis)
		"airbase":
			map.updateAirbaseVisibility(vis)
		"resource":
			map.updateResourceVisibility(vis)
		"nationLabel":
			map.updateNationLabelVisibility(vis)
		"river":
			map.updateRiverVisibility(vis)
		"culture":
			map.updateCultureVisibility(vis)
		_:
			print("unknown map mode visibility setting \"", setting, "\"")


func isDefault() -> bool:
	return currentMode == DEFAULT










