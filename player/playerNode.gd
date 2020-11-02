extends RigidBody2D
#===============================================================================
var playground_size   # Двумерный массив размера игрового поля
var playground_tiles  # Двумерный масств элементов игрового поля
var tile_distance     # "Шаг" или расстояние между кадой "плиткой"
var moving_dir        # Вектор направления движения (от -1,-1 до 1,1)
var center_pos        # Центр сгенерированного игрового поля
var playground_position = Vector2.ZERO  #
var rng = RandomNumberGenerator.new()   # Переменная для генерации случайных цифр

func _on_generatePlayground_returnTilesSignal(width, height, tiles, tileDist, center):
# Эта функция вызывается при открытии этой сцены и исходит от "generatePlayground.gd"
	playground_size = Vector2(height, width)
	playground_tiles = tiles
	tile_distance = tileDist
	center_pos = center

var TouchVector = Vector2.ZERO# 2Д Вектор направления "свайпа"
func _on_SwipeDetector_swiped(direction):
# Вызывается по сигналу модуля "SwipeDetector.gd"
	TouchVector = direction
#===============================================================================
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
func _ready():
	rng.randomize() # Генерирует случайный seed для следующей операции с randi_range
	self.position = playground_tiles[rng.randi_range(0,playground_size.x-1)]  \
					[rng.randi_range(0,playground_size.x-1)] \
					.position - center_pos
	# Код выше устанавливает игрока в случайное место на игровом поле
	# Чтобы код получился не очень длинный и более читаемый разбил на строки

func _physics_process(delta): # Главная функция (вызывается раз в кадр)
	get_input()
	move_step(delta) # delta - время прошедшее с последнего кадра (от 0 до 1)
	spriteRotation()
	print(playground_position)
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
func get_input():
# Функция для получения ввода игрока направления желаемого движения
	moving_dir = Vector2.ZERO
	if Input.is_action_pressed("move_left")  or TouchVector == Vector2(-1,0):
		moving_dir.x -= 1
	elif Input.is_action_pressed("move_right") or TouchVector == Vector2(1, 0):
		moving_dir.x += 1
	elif Input.is_action_pressed("move_up"   ) or TouchVector == Vector2(0,-1):
		moving_dir.y -= 1
	elif Input.is_action_pressed("move_down" ) or TouchVector == Vector2(0, 1):
		moving_dir.y += 1
	TouchVector = Vector2.ZERO

var desired_position = Vector2.ZERO  # Желаемая позиция (исп. в move_step())
var stored_pos  # Сохраненная позиция (исп. в move_step())
var time = 0  # время прошедшее с последнего "хода"
func move_step(delta):
	if(desired_position == Vector2.ZERO):
		desired_position.x = tile_distance * moving_dir.x
		desired_position.y = tile_distance * moving_dir.y
		stored_pos = self.position
	while(time < 3.0 and desired_position != Vector2.ZERO):
		position = lerp(position, stored_pos + desired_position, 15 * delta)
		time += 7.0 * delta
		yield()
	desired_position = Vector2.ZERO
	time = 0.0

func spriteRotation():  # Вращение главного спрайта
	if moving_dir.x > 0:
		$playerSprite.rotation_degrees = 90
	if moving_dir.x < 0:
		$playerSprite.rotation_degrees = 270
	if moving_dir.y > 0:
		$playerSprite.rotation_degrees = 180
	if moving_dir.y < 0:
		$playerSprite.rotation_degrees = 0


