extends KinematicBody2D

func _ready():
	GameManager.game_started = true
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
func _physics_process(delta): # Главная функция (вызывается раз в кадр)
	get_input()
	move_step(delta) # delta - время прошедшее с последнего кадра (от 0 до 1)
	spriteRotation()
	shooting()
	if(Input.is_action_just_pressed("shooting_mode_btn")):
		change_shoot_mode()

#===============================================================================
var playground_size   # Двумерный массив размера игрового поля
var playground_tiles  # Двумерный масств элементов игрового поля
var tile_distance     # "Шаг" или расстояние между кадой "плиткой"
var moving_dir        # Вектор направления движения (от -1,-1 до 1,1)
var center_pos        # Центр сгенерированного игрового поля
var playground_position = Vector2.ZERO  # Текущая позиция на игровом поле
var rng = RandomNumberGenerator.new()   # Переменная для генерации случайных цифр
var shoot_mode = false

func _on_generatePlayground_returnTilesSignal(width, height, tiles, tileDist, center):
# Эта функция вызывается при открытии этой сцены и исходит от "generatePlayground.gd"
	playground_size = Vector2(height, width)
	playground_tiles = tiles
	tile_distance = tileDist
	center_pos = center
	
#	var col_poly = $no_spawn_area/collision_polygon.polygon
#	col_poly[0] = Vector2(-tile_distance,-tile_distance)*2
#	col_poly[1] = Vector2(+tile_distance,-tile_distance)*2
#	col_poly[2] = Vector2(+tile_distance,+tile_distance)*2
#	col_poly[3] = Vector2(-tile_distance,+tile_distance)*2

	rng.randomize() # Генерирует случайный seed для следующей операции с randi_range
	playground_position = Vector2(rng.randi_range(0,playground_size.x - 1),rng.randi_range(0,playground_size.y - 1))
	self.position = playground_tiles[playground_position.x][playground_position.y].position - center_pos
	playground_position += Vector2.ONE
	# Код выше устанавливает игрока в случайное место на игровом поле
	# Чтобы код получился не очень длинный и более читаемый разбил на строки

var TouchVector = Vector2.ZERO# 2Д Вектор направления "свайпа"
func _on_SwipeDetector_swiped(direction)->void:
# Вызывается по сигналу модуля "SwipeDetector.gd"
	TouchVector = direction
#===============================================================================

#INPUT STARTS HERE++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
func _on_SwipeDetector_tap():
	change_shoot_mode()
func get_input()->void:
# Функция для получения ввода игрока направления желаемого движения
	moving_dir = Vector2.ZERO
	if (Input.is_action_just_pressed("move_left")  or TouchVector == Vector2(-1,0)) \
	   and playground_position.y > 1:
		moving_dir.x -= 1
	elif (Input.is_action_just_pressed("move_right") or TouchVector == Vector2(1, 0)) \
	   and playground_position.y < playground_size.x:
		moving_dir.x += 1
	elif (Input.is_action_just_pressed("move_up"   ) or TouchVector == Vector2(0,-1)) \
	   and playground_position.x > 1:
		moving_dir.y -= 1
	elif (Input.is_action_just_pressed("move_down" ) or TouchVector == Vector2(0, 1)) \
	   and playground_position.x < playground_size.y:
		moving_dir.y += 1
	TouchVector = Vector2.ZERO

#INPUT ENDS HERE----------------------------------------------------------------
func move_step(delta)->void:
# Функция для движения персонажа по плиткам
	if(moving_dir != Vector2.ZERO and $move_timer.is_stopped() and !shoot_mode and GameManager.players_move):
		GameManager.switch_turn()
		self.position += moving_dir * tile_distance
		playground_position.x += moving_dir.y
		playground_position.y += moving_dir.x
		$move_timer.start()

# 
var confirm_shoot: bool = false
var stored_dir
func confirm_shoot_func(dir)->void:
	if(shoot_mode):
		if(!confirm_shoot):
			stored_dir = dir
			confirm_shoot = true
		elif(confirm_shoot and stored_dir == dir):
			$playerSprite/gun_temporary/fire_line_temp/shooting_zone/CollisionShape2D.disabled = false
			$shoot_release_timer.start()
		else:
			stored_dir = dir
func _on_shoot_release_timer_timeout():
	shoot_mode = false
	$playerSprite/gun_temporary.visible = false
	$playerSprite/gun_temporary/fire_line_temp/shooting_zone/CollisionShape2D.disabled = true
func shooting()->void:	
	if(shoot_mode):
		if Input.is_action_just_pressed("move_left"   ) or TouchVector == Vector2(-1, 0):
			confirm_shoot_func(Vector2(-1, 0))
		elif Input.is_action_just_pressed("move_right") or TouchVector == Vector2( 1, 0):
			confirm_shoot_func(Vector2( 1, 0))
		elif Input.is_action_just_pressed("move_up"   ) or TouchVector == Vector2( 0,-1):
			confirm_shoot_func(Vector2( 0,-1))
		elif Input.is_action_just_pressed("move_down" ) or TouchVector == Vector2( 0, 1):
			confirm_shoot_func(Vector2( 0, 1))
func change_shoot_mode():
	if (!shoot_mode):
		shoot_mode = true
		$playerSprite/gun_temporary.visible = true
	else: 
		shoot_mode = false
		$playerSprite/gun_temporary.visible = false
		$playerSprite/gun_temporary/fire_line_temp/shooting_zone/CollisionShape2D.disabled = true

func spriteRotation()->void:  # Вращение спрайта игрока
	if moving_dir.x > 0:
		$playerSprite.rotation_degrees = 90
	if moving_dir.x < 0:
		$playerSprite.rotation_degrees = 270
	if moving_dir.y > 0:
		$playerSprite.rotation_degrees = 180
	if moving_dir.y < 0:
		$playerSprite.rotation_degrees = 0


signal player_kills
func _on_shooting_zone_body_entered(body):
# Убийство врагов на линии
	if(!body.is_in_group("player")):
		connect("player_kills", body, "_on_PlayerNode_player_kills")
		emit_signal("player_kills")



