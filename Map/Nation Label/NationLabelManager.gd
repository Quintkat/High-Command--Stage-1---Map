extends Control

# Variables for calculations
var tileWidth : int
var grid : Grid
const NationLabelScene = preload("res://Map/Nation Label/NationLabel.tscn")
const paddingPortion = 1.0/3

# Variables for the created labels
var nations = {}	# Nation : label


func init(tw : int, g : Grid):
	tileWidth = tw
	grid = g


func addLabel(nation : Nation):
	# Create label
	var label : NationLabel = NationLabelScene.instance()
	var nationality = nation.nName
	var governmentForm = nation.governmentForm
	add_child(label)
	label.init(Nationality.getGovName(nationality, governmentForm))
	nations[nation] = label
#	var time = OS.get_system_time_msecs()
	positionLabel(label, nation)
#	print("Position time, ", nationality, ": ", OS.get_system_time_msecs() - time, "ms\n")
		

func positionLabel(label : Label, nation : Nation):
#	var time = OS.get_system_time_msecs()
	var result = getTilesNationIsolatedRectangle(nation)
	var rect = result[0]
	var startPosRect = result[1]
#	print("Rectangulate time, ", OS.get_system_time_msecs() - time, "ms")
	
#	# Split the rectangle/"nation" into 4 quadrants, 
#	# and then see whether the top-left-bottom-right or bottom-left-top-right allignment is better
	# Find the "furthest" point from the center of mass, and find its furthest point on the opposite side of
	# the CoM
#	var time1 = OS.get_system_time_msecs()
	var nWidth = len(rect)
	var nHeight = len(rect[0])
	var centerPoint : Vector2 = calcCenterMass(rect, startPosRect)
#	print("Centering time, ", OS.get_system_time_msecs() - time1, "ms")
	
#	var time2 = OS.get_system_time_msecs()
	# Old method
#	# Calculating the candidates for each quadrant
#	var topLeftPos = getFurthest(rect, centerPoint, 0, 0, centerPoint[0], centerPoint[1])
#	var topRightPos = getFurthest(rect, centerPoint, centerPoint[0], 0, nWidth, centerPoint[1])
#	var botLeftPos = getFurthest(rect, centerPoint, 0, centerPoint[1], centerPoint[0], nHeight)
#	var botRightPos = getFurthest(rect, centerPoint, centerPoint[0], centerPoint[1], nWidth, nHeight)
#	testRect(centerPoint + startPosRect, "#FFFFFF")
#	testRect(topLeftPos + startPosRect, "#002EFF")
#	testRect(topRightPos + startPosRect, "#FF00B2")
#	testRect(botLeftPos + startPosRect, "#00FF37")
#	testRect(botRightPos + startPosRect, "#FFD800")

	# New method
	var furthest = getFurthest(rect, centerPoint, 0, 0, nWidth, nHeight)
	var opposite = getFurthestOnLine(rect, centerPoint, centerPoint - furthest)
#	testRect(centerPoint + startPosRect, "FFFFFF")
#	testRect(furthest + startPosRect, "FF00B2")
#	testRect(opposite + startPosRect, "00FF37")
#	print("getFurthest time, ", OS.get_system_time_msecs() - time2, "ms")
	
#	var time5 = OS.get_system_time_msecs()
	# Decide between upwards slope or downwards slope line
	var leftPos : Vector2
	var rightPos : Vector2
	
	# New method
	if furthest[0] > opposite[0]:
		leftPos = opposite
		rightPos = furthest
	else:
		leftPos = furthest
		rightPos = opposite
	leftPos += startPosRect
	rightPos += startPosRect
	
	# Old method
#	if topLeftPos.distance_to(botRightPos) > botLeftPos.distance_to(topRightPos):
#		leftPos = topLeftPos + startPosRect
#		rightPos = botRightPos + startPosRect
#	else:
#		leftPos = botLeftPos + startPosRect
#		rightPos = topRightPos + startPosRect
#	print("Decision time, ", OS.get_system_time_msecs() - time5, "ms")
	
#	var time3 = OS.get_system_time_msecs()
	# Figure out all of the number necessary for positioning, scaling, and rotation of the label
	var rotation = rad2deg(leftPos.angle_to_point(rightPos)) + 180
	var availableWidth = leftPos.distance_to(rightPos)*tileWidth
#	var time4 = OS.get_system_time_msecs()
	var textSize = Fonts.fontNation.get_string_size(label.text)
#	var textSize = Vector2(len(label.text)*235.5, Fonts.fontNation.size*1.174)
#	print("textSize time???, ", OS.get_system_time_msecs() - time4, "ms")
	var textWidth = textSize[0]
	var textHeight = textSize[1]
	var newScale = availableWidth*(1 - paddingPortion)/textWidth
	var labelPos = leftPos*tileWidth + Vector2(availableWidth*paddingPortion/2, -textHeight*newScale/2).rotated(deg2rad(rotation))
	
	label.rect_rotation = rotation
	label.rect_scale = Vector2(newScale, newScale)
	label.rect_size = Vector2(0, 0)		# It will rescale on its own
	label.rect_position = labelPos
#	print(label.rect_position)
#	print(label.text)
#	print(label.modulate)
#	label.modulate = Color(0, 0, 0, 0)
	
#	print("label positioning time, ", OS.get_system_time_msecs() - time3, "ms")
	

func calcCenterMass(rect : Array, offset : Vector2 = Vector2(0, 0)) -> Vector2:
	var centerMass = Vector2(0, 0)
	var centerAnti = Vector2(0, 0)
	var counter = 0
	var antiCounter = 0
	for x in range(len(rect)):
		for y in range(len(rect[0])):
			if rect[x][y] == null:
#				centerAnti += Vector2(x, y)
#				antiCounter += 1
				continue
			
			centerMass += Vector2(x, y)
			counter += 1
	
	return VectorMath.vectInt(centerMass/counter)
	
	if antiCounter == 0:
		return VectorMath.vectInt(centerMass/counter)
	
	centerMass /= counter
	centerAnti /= antiCounter
	print(centerMass, " ", centerAnti)
	
#	var angleAnti = centerAnti.angle_to_point(centerMass)
	# We want the anti center to "push" on the center of mass (since normal points "pull" on the CoM)
	var vectorBetween = centerMass - centerAnti
	print(vectorBetween)
	var newCenter = centerMass + vectorBetween/(counter/antiCounter)
	print(newCenter)
	
	var finalCenter = VectorMath.vectInt(newCenter)
	return finalCenter


func getFurthest(rect : Array, center : Vector2, xMin, yMin, xMax, yMax) -> Vector2:
	var furthestPoint = center
	var currentLargestDistance = 0
	for x in range(int(xMin), int(xMax)):
		for y in range(int(yMin), int(yMax)):
			if rect[x][y] == null:
				continue
			
			var testPos = Vector2(x, y)
			var testDist = extraDistanceMetric(center, testPos)
			if  testDist > currentLargestDistance:
				furthestPoint = testPos
				currentLargestDistance = testDist
	
	return furthestPoint


func getFurthestOnLine(rect : Array, center : Vector2, line : Vector2) -> Vector2:
	var furthest = center
	var stepVector = line/line.length()
	var current = center
	while current[0] >= 0 and current[0] < len(rect) and current[1] >= 0 and current[1] < len(rect[0]):
		var currentBound = VectorMath.vectInt(current)
		var currentTile = rect[currentBound[0]][currentBound[1]]
		if currentTile != null:
			furthest = currentBound
		
		current += stepVector
	
	
	return furthest


# Metric that also takes into account how far from the supposed x and y axes centered on u v is
func extraDistanceMetric(u : Vector2, v : Vector2):
	var baseScore = u.distance_squared_to(v)
#	var extraScore = pow(abs(u[0] - v[0])*abs(u[1] - v[1]), 1.25)
	var extraScore = abs(u[0] - v[0])*abs(u[1] - v[1])
	if extraScore == 0:
		baseScore /= 4
	return baseScore + extraScore


# Returns all of the tiles of a certain nationality in a rectangular grid, 
# as if it was cut out of the original grid
func getTilesNationIsolatedRectangle(nation : Nation):
	var nationality = nation.nName	
	
	# Find out the the bounds of the eventual rectangle
	var boundRect = nation.getBoundingRectangle()
	var minXPos = boundRect.position[0]
	var minYPos = boundRect.position[1]
	var maxXPos = boundRect.end[0]
	var maxYPos = boundRect.end[1]
			
	# Slice the rectangle into existence
	var rect = []
	for i in range(minXPos, maxXPos + 1):
		var vertSlice = grid.getVerticalSlice(i, minYPos, maxYPos)
		rect.append(vertSlice.duplicate())
		
	# Make all the tiles that are not of the desired nationality null, for ease of use I suppose.
	for i in range(len(rect)):
		for j in range(len(rect[i])):
			var tile = rect[i][j]
			if tile.getNationality() != nationality:
				rect[i][j] = null
	
	# For reference, the top left position of rect in the actual grid is also given
	var startPos = Vector2(minXPos, minYPos)
	
	return [rect, startPos]


func testRect(pos, c):
	var rect = ColorRect.new()
	add_child(rect)
	rect.rect_position = pos*tileWidth
	rect.rect_size = Vector2(100, 100)
	rect.color = Color(c)






