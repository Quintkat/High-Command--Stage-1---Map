extends PanelContainer


var brush


func getTerrainType() -> String:
	return $VBox.selected


func addBrush(b : Brush):
	b.removeFromParent()
	brush = b
	brush.setMode(brush.TERRAIN)
	$VBox.add_child(brush)
	$VBox.move_child(brush, 0)
