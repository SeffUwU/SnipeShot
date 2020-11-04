extends RigidBody2D
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
	
	rng.randomize() # Генерирует случайный seed для следующей операции с randi_range
	playground_position = Vector2(rng.randi_range(0,playground_size.x - 1),rng.randi_range(0,playground_size.y - 1))
	self.position = playground_tiles[playground_position.x][playground_position.y].position - center_pos
	playground_position += Vector2.ONE
	# Код выше устанавливает игрока в случайное место на игровом поле
	# Чтобы код получился не очень длинный и более читаемый разбил на строки

var TouchVector = Vector2.ZERO# 2Д Вектор направления "свайпа"
func _on_SwipeDetector_swiped(direction):
# Вызывается по сигналу модуля "SwipeDetector.gd"
	TouchVector = direction
#===============================================================================
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
func _ready():
	pass
	

func _physics_process(delta): # Главная функция (вызывается раз в кадр)
	reload_scene()
	get_input()
	move_step(delta) # delta - время прошедшее с последнего кадра (от 0 до 1)
	spriteRotation()
	if(Input.is_action_just_pressed("shooting_mode_btn")): shooting()

#INPUT STARTS HERE++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
func _on_SwipeDetector_tap():
	shooting()
func get_input():
# Функция для получения ввода игрока направления желаемого движения
	moving_dir = Vector2.ZERO
	if (Input.is_action_pressed("move_left")  or TouchVector == Vector2(-1,0)) \
	   and playground_position.y > 1:
		moving_dir.x -= 1
	elif (Input.is_action_pressed("move_right") or TouchVector == Vector2(1, 0)) \
	   and playground_position.y < playground_size.x:
		moving_dir.x += 1
	elif (Input.is_action_pressed("move_up"   ) or TouchVector == Vector2(0,-1)) \
	   and playground_position.x > 1:
		moving_dir.y -= 1
	elif (Input.is_action_pressed("move_down" ) or TouchVector == Vector2(0, 1)) \
	   and playground_position.x < playground_size.y:
		moving_dir.y += 1
	TouchVector = Vector2.ZERO

#INPUT ENDS HERE----------------------------------------------------------------
func move_step(delta):
	if(moving_dir != Vector2.ZERO and $move_timer.is_stopped() and !shoot_mode):
		self.position += moving_dir * tile_distance
		playground_position.x += moving_dir.y
		playground_position.y += moving_dir.x
		$move_timer.start()
func _on_move_timer_timeout():
	#Ну оно пока что есть но применение найду ему позже
	pass

func shooting():
	if (!shoot_mode):
		shoot_mode = true
		$playerSprite/gun_temporary.visible = true
	else: 
		shoot_mode = false
		$playerSprite/gun_temporary.visible = false
	pass

func spriteRotation():  # Вращение главного спрайта
	if moving_dir.x > 0:
		$playerSprite.rotation_degrees = 90
	if moving_dir.x < 0:
		$playerSprite.rotation_degrees = 270
	if moving_dir.y > 0:
		$playerSprite.rotation_degrees = 180
	if moving_dir.y < 0:
		$playerSprite.rotation_degrees = 0

func reload_scene():
	if (Input.is_action_just_pressed("reload")):
		print("Okay! Restarting current scene!")
		get_tree().reload_current_scene()






