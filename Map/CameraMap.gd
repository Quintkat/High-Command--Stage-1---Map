extends Camera2D
class_name MapCamera

# The map
onready var Map = get_parent()

# Setup variables
const displaySize = Vector2(1920, 1080)
var mapSize : Vector2

# Camera behaviour variables
var maxZoom
var zoomLevels
var zoomAmountLevels = []
var zoomJump
#var moving : bool = false	# Whether or not the camera is being dragged around
#var movingOrigin : Vector2	# Where the mouse started when the camera is being dragged
var movingPreviousMouse : Vector2
var movingSpeed = 20

# Camera info derivatives
var zoomGradient = []

# Map editor variables
var widerMovement = false
var moveWithKeyboard = true


# The initialisation function, sets up the camera in the middle of the map, zoomed out all the way
func init(gridSize : Vector2):
	zoomLevels = max(int(gridSize[0]/6.4), int(gridSize[1]/3.6))
	if zoomLevels < 7:
		zoomLevels = 7
	mapSize = TileConstants.SIZE*gridSize
	maxZoom = max(mapSize[0]/displaySize[0], mapSize[1]/displaySize[1])
	zoomJump = maxZoom/zoomLevels
	for l in range(zoomLevels - 1):
		zoomAmountLevels.append(1 + l*zoomJump)
	
	for z in range(1, maxZoom/zoomJump):
		if z <= maxZoom/zoomJump/2 - 1:
			zoomGradient.append(0)
		elif z <=  maxZoom/zoomJump/2 + 1:
			zoomGradient.append(float(z - (zoomLevels/2 - 1))/3)
		else:
			zoomGradient.append(1)
	
#	Fonts.init(self)
#	for zg in zoomGradient:
#		print(zg)
	
	updateZoom(maxZoom)
	move(mapSize/2)

# Moves the camera to a certain position
func move(pos : Vector2):
	var alteredPos = Vector2(0, 0)
	if !widerMovement:
#		alteredPos[0] = int(max(zoom[0]*displaySize[0]/2, min(mapSize[0] - zoom[0]*displaySize[0]/2, pos[0])))
#		alteredPos[1] = int(max(zoom[0]*displaySize[1]/2, min(mapSize[1] - zoom[1]*displaySize[1]/2, pos[1])))
		var mapMidpoint = mapSize/2
		var minX = min(zoom[0]*displaySize[0]/2, mapMidpoint[0])
		var maxX = max(mapSize[0] - zoom[0]*displaySize[0]/2, mapMidpoint[0])
		var minY = min(zoom[0]*displaySize[1]/2, mapMidpoint[1])
		var maxY = max(mapSize[1] - zoom[1]*displaySize[1]/2, mapMidpoint[1])
		alteredPos[0] = int(max(minX, min(maxX, pos[0])))
		alteredPos[1] = int(max(minY, min(maxY, pos[1])))
	else:
		alteredPos[0] = int(max(0, min(mapSize[0], pos[0])))
		alteredPos[1] = int(max(0, min(mapSize[1], pos[1])))
		
	position = alteredPos
	Map.cameraMoveEvent()

func shift(shift : Vector2):
	move(position + shift)

# Setting the zoom to another level
func updateZoom(z : float):
	zoom = max(1, min(maxZoom, z))*Vector2(1, 1)
	shift(Vector2(0, 0))
	Map.cameraZoomEvent()


func _process(delta):
	inputs()

# Handles all the inputs in one place
func inputs():
	if !Input.is_action_pressed("change_brush_size"):
		if Input.is_action_just_released("zoom_in"):
			zoomIn()

		if Input.is_action_just_released("zoom_out"):
			zoomOut()

	if moveWithKeyboard:
		if Input.is_action_pressed("cam_down"):
			shift(Vector2(0, movingSpeed))

		if Input.is_action_pressed("cam_up"):
			shift(Vector2(0, -movingSpeed))

		if Input.is_action_pressed("cam_left"):
			shift(Vector2(-movingSpeed, 0))

		if Input.is_action_pressed("cam_right"):
			shift(Vector2(movingSpeed, 0))

	# Camera dragging
	if Input.is_action_just_pressed("cam_drag"):
		movingPreviousMouse = get_global_mouse_position()

	if Input.is_action_pressed("cam_drag"):
		shift(movingPreviousMouse - get_global_mouse_position())

func zoomIn():
	updateZoom(zoom[0] - zoomJump)

func zoomOut():
	updateZoom(zoom[0] + zoomJump)

func getZoomGradient():
	return zoomGradient[getIndexedZoomLevel()]

func getIndexedZoomLevel():
	return getZoom()/zoomJump - 2

func getZoomPercentage():
	return (maxZoom - getZoom())/(maxZoom - 1)

func getZoomAmountLevels():
	return zoomAmountLevels

func getZoom():
	return zoom[0]

func getViewportSize():
	return displaySize*zoom[0]
