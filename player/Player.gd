extends KinematicBody2D


var touchInputDirection = Vector2()

var PlayerTurn = true

var stepDistance
var canStep = true
var allowedSteps = 3




#PLAYGROUND=====================================================================
var stepTiles
var widthTiles
var heightTiles

func _on_generatePlayground_returnTilesSignal(height, width, tiles, tileDist, center):
	heightTiles = height
	widthTiles  = width
	stepTiles  = tiles
	stepDistance = tileDist
	self.position = Vector2(0,0) - center + stepTiles[rand_range(0,height)][rand_range(0,width)].position
	print(self.position)
#===============================================================================
func _ready():
	pass

var shooting = false

var moving_dir = Vector2()


func _process(delta):
	moveStep(delta)
	
	getInput(touchInputDirection)
	spriteRotation()
	if Input.is_action_just_pressed("shooting_mode_btn"):
		shootMode()

#INPUT=========================================================================
func _on_touchControls_sendTouchControls(dir):
	touchInputDirection = Vector2.ZERO
	touchInputDirection.x += dir.x
	touchInputDirection.y += dir.y
func _on_SwipeDetector_swiped(direction):
	touchInputDirection = Vector2.ZERO
	touchInputDirection.x += direction.x
	touchInputDirection.y += direction.y
func getInput(TouchVector): 
	moving_dir = Vector2.ZERO
	touchInputDirection = Vector2.ZERO
	if (canStep == true):
		if Input.is_action_pressed("move_left")  or TouchVector == Vector2(-1,0):
			moving_dir.x -= 1
		if Input.is_action_pressed("move_right") or TouchVector == Vector2(1, 0):
			moving_dir.x += 1
		if Input.is_action_pressed("move_up"   ) or TouchVector == Vector2(0,-1):
			moving_dir.y -= 1
		if Input.is_action_pressed("move_down" ) or TouchVector == Vector2(0, 1):
			moving_dir.y += 1



#==============================================================================
func movePlayer():
	
	pass
var desired_position = Vector2.ZERO
func moveStep(t):
	position.linear_interpolate(desired_position, 5 * t)
	if(desired_position != Vector2.ZERO):
		print(self.position)
		
		if(self.position == desired_position):
			desired_position = Vector2.ZERO
	else:
		desired_position = Vector2(self.position.x + (moving_dir.x * stepDistance), self.position.y + (moving_dir.y * stepDistance) ) 
	pass
#SHOOT MODE====================================================================
func _on_touchControls_sendShootMode():
	shootMode()
	print('SHOOT')
func _on_SwipeDetector_tap():
	shootMode()
func shootMode():
		if shooting == false:
			shooting = true
			$playerSprite/gun_temporary.visible = true
			$playerSprite/fire_line_temp.visible = true
		else:
			shooting = false
			$playerSprite/gun_temporary.visible = false
			$playerSprite/fire_line_temp.visible = false

#==============================================================================
func spriteRotation():
	if PlayerTurn == true:
		if moving_dir.x > 0:
			$playerSprite.rotation_degrees = 90
		if moving_dir.x < 0:
			$playerSprite.rotation_degrees = 270
		if moving_dir.y > 0:
			$playerSprite.rotation_degrees = 180
		if moving_dir.y < 0:
			$playerSprite.rotation_degrees = 0








