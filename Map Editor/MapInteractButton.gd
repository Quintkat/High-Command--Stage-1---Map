extends Button

signal holdDown


func _process(delta):
	if pressed:
		emit_signal("holdDown")
