extends KinematicBody2D

func _ready():
	self.visible = false # Скрываем врага до момента пока он не появится
	playground_size  = Vector2(GameManager.height, GameManager.width)  # Размер игрового поля
	playground_tiles = GameManager.tileArr  # 2Д Массив всех "плиток"
	tile_distance    = GameManager.tile_dist  # Расстояние между "плитками"
	center_pos       = GameManager.PGcenter # Центр игрового поля

func _physics_process(delta):
	move_to_player(player_direction(player))
	_spawn_self()
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
var is_spawned: bool = false
var playground_size = Vector2.ZERO
var playground_tiles
var tile_distance:int
var center_pos
var can_move = false
onready var player = get_tree().get_nodes_in_group("Player")[0]
var rng = RandomNumberGenerator.new()


func _spawn_self():
	if((!$detectionHull.get_overlapping_areas().empty() or !$detectionHull.get_overlapping_bodies().empty()) and !is_spawned):
		self.visible = false
		rng.randomize()
		var random_position = Vector2(rng.randi_range(0, playground_size.x - 1), rng.randi_range(0, playground_size.y - 1))
		self.position = playground_tiles[random_position.x][random_position.y].position - center_pos
	else:
		is_spawned = true
		self.visible = true

func player_direction(player)->Vector2:
# Эта функция возвращает количетсво "плиток" до игрока по осям x,y.
# Используется в move_to_player()
	var vector = player.position - self.position
	return (Vector2(vector.x,vector.y) / 100)


func move_to_player(player_dir)->void:
	if(GameManager.players_move == false and $Timer.is_stopped() and can_move == false):
		$Timer.start()
	if (can_move == true and GameManager.players_move == false):
		if (abs(player_dir.x) < abs(player_dir.y)):
			self.position.y += tile_distance * sign(player_dir.y)
		elif (abs(player_dir.x) > abs(player_dir.y)):
			self.position.x += tile_distance * sign(player_dir.x)
		else:
			self.position.x += sign(player_dir.x) * tile_distance
		can_move = false
		GameManager.switch_turn() # Дать игроку ход
		
func _on_Timer_timeout():
	can_move = true

func desired_tile_is_free()->bool:
	if($detectionHull.overlaps_area(player)):
		return false
	else:
		return true



# DIE
func _on_PlayerNode_player_kills():
	$death_particles.emitting = true
	$death_timer.set_wait_time($death_particles.lifetime + 0.1)
	$death_timer.start()
func _on_death_timer_timeout():
	GameManager.add_points(1)
	GameManager.alive_enemies -= 1
	queue_free()
# ===

