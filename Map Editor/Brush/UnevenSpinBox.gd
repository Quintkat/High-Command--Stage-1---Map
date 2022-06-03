extends SpinBox

var previousValue


func _ready():
	previousValue = value


func _process(delta):
	if int(value) % 2 != 1:
		if previousValue < value:
			value += 1
		else:
			value -= 1
		emit_signal("value_changed", value)
		previousValue = value
		
