extends KinematicBody2D

func _ready():
	# Инициализируем начало игры
	GameManager.game_started = true # Устанавливаем "игра начата" в положение истинно
	GameManager.player = self # Устанавливаем объект игрока в переменную игр. мендж.
	GameManager.init_player_moves() # Инициализируем ходы игрока
	
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
func _physics_process(delta): # Главная функция (вызывается раз в кадр)
	get_input()
	move_step()
	spriteRotation()
	if(Input.is_action_just_pressed("shooting_mode_btn")):
		change_shoot_mode()

#===============================================================================
var playground_size   # Двумерный массив размера игрового поля
var playground_tiles  # Двумерный масств элементов игрового поля
var tile_distance     # "Шаг" или расстояние между кадой "плиткой"
var moving_dir        # Вектор направления движения (от -1,-1 до 1,1)
var center_pos        # Центр сгенерированного игрового поля
var playground_position = Vector2.ZERO # Текущая позиция на игровом поле
var rng = RandomNumberGenerator.new()  # Переменная для генерации случайных цифр
var shoot_mode = false
var TouchVector = Vector2.ZERO # 2D Вектор направления "свайпа"
signal player_kills
var confirm_shoot: bool = false
var stored_dir

var rotate = {
	"up": 90,
	"down": 270,
	"left": 0,
	"right": 180
}
#===============================================================================
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
	print(TouchVector)

#INPUT STARTS HERE==============================================================
func _on_SwipeDetector_swiped(direction)->void:
# Вызывается по сигналу модуля "SwipeDetector.gd"
	TouchVector = direction
	if(shoot_mode):
		confirm_shoot_func(direction)

func _on_SwipeDetector_tap():
	change_shoot_mode()

func get_input()->void:
# Функция для получения направления движения, желаемое игроком
	moving_dir = Vector2.ZERO
	if (Input.is_action_just_pressed("move_left")  or TouchVector == Vector2(-1,0)) \
	   and playground_position.y > 1:
		moving_dir.x -= 1
		confirm_shoot_func(Vector2(-1,0))
	elif (Input.is_action_just_pressed("move_right") or TouchVector == Vector2(1, 0)) \
	   and playground_position.y < playground_size.x:
		moving_dir.x += 1
		confirm_shoot_func(Vector2(1,0))
	elif (Input.is_action_just_pressed("move_up"   ) or TouchVector == Vector2(0,-1)) \
	   and playground_position.x > 1:
		moving_dir.y -= 1
		confirm_shoot_func(Vector2(0,-1))
	elif (Input.is_action_just_pressed("move_down" ) or TouchVector == Vector2(0, 1)) \
	   and playground_position.x < playground_size.y:
		moving_dir.y += 1
		confirm_shoot_func(Vector2(0,1))
	TouchVector = Vector2.ZERO

#INPUT ENDS HERE=======MOVE STARTS HERE=========================================
func move_step()->void:
# Функция для движения персонажа по плиткам
	if(moving_dir != Vector2.ZERO and $move_timer.is_stopped() and !shoot_mode and GameManager.players_move):
		if($Tween.is_active() == false):
			$Tween.interpolate_property(
				self, "position", self.position,
				self.position + (moving_dir * tile_distance),
				0.3,
				Tween.TRANS_SINE,
				Tween.EASE_IN_OUT
			)
			GameManager.remove_from_turn_list(self)
			$Tween.start()
			playground_position.x += moving_dir.y
			playground_position.y += moving_dir.x
			rng.randomize()
			var pitch = rng.randf_range(-0.05,0.05)
			$sounds/move_sound.pitch_scale = 1 + pitch
			$sounds/move_sound.play()
			$move_timer.start()

# SHOOT STARTS HERE=============================================================
# Весь блок ниже выполняет функцию подтверждения выстрела, он проверяет если на-
# правление выстрела совпадает с текущим, и совершает выстрел. 
#(Стоит немного доработать эту часть кода)
func confirm_shoot_func(dir)->void:
	if(shoot_mode):
		if(!confirm_shoot):
			stored_dir = dir
			confirm_shoot = true
		elif(confirm_shoot and stored_dir == dir):
			$playerSprite/gun_temporary/attack_path/shooting_zone/CollisionShape2D.disabled = false
			$playerSprite/gun_temporary/shot_fired.play("default")
			$shoot_release_timer.start()
		else:
			stored_dir = dir

func _on_shoot_release_timer_timeout():
	shoot_mode = false
	$playerSprite/gun_temporary.visible = false
	$playerSprite/gun_temporary/attack_path/shooting_zone/CollisionShape2D.disabled = true
	GameManager.remove_from_turn_list(self)

func change_shoot_mode()->void:
	if (!shoot_mode):
		shoot_mode = true
		$playerSprite/gun_temporary.visible = true
	else: 
		shoot_mode = false
		$playerSprite/gun_temporary.visible = false
		$playerSprite/gun_temporary/attack_path/shooting_zone/CollisionShape2D.disabled = true

#=SPRITE ROTATION STARTS HERE===================================================
func spriteRotation()->void:  # Вращение спрайта игрока
	var weapon = $playerSprite/gun_temporary
	if moving_dir.x > 0:
		weapon.rotation_degrees = rotate["right"]
		$playerSprite.play("right")
	if moving_dir.x < 0:
		weapon.rotation_degrees = rotate["left"]
		$playerSprite.play("left")
	if moving_dir.y > 0:
		weapon.rotation_degrees = rotate["down"]
		$playerSprite.play("down")
	if moving_dir.y < 0:
		weapon.rotation_degrees = rotate["up"]
		$playerSprite.play("up")
		
#=KILL/DEATH STARTS HERE========================================================
func _on_shooting_zone_body_entered(body): # Убийство врагов на линии
	if(!body.is_in_group("player")):
		connect("player_kills", body, "_on_Player_player_kills")
		emit_signal("player_kills")
