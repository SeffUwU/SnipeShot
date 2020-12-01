extends Node

# Данные для генерации поля ====================================================
var height: int = 6
var width:  int = 6

func set_size(x,y)->void:
# Эта функция выставляет размер поля для последующей генерации в "generatePlayground"
	height = x
	width = y
# Данные для других модулей=====================================================
var tile_dist: int
var tileArr
var PGcenter:Vector2
func set_tiles(dist, tiles, center):
	tile_dist = dist
	tileArr = tiles
	PGcenter = center

var player # Нода игрока
#===============================================================================

# GAME MANAGER | Менеджер игровых событий ниже

var game_started: bool = false # Начата ли игра игроком

#=Смена хода игрока и врагов====================================================
var players_move: bool = true # Ход ли у игрока в данный момент
var player_move_count: int = 0# Счетчик ходов игрока (он имеет два хода)

var all_enemies = []



func switch_turn():
	if(players_move):
		players_move = false
		init_enemy_moves()
	else:
		players_move = true
		init_player_moves()

var turn_list = []
func init_player_moves():
	turn_list.clear()
	turn_list.append(player)
	turn_list.append(player)
func init_enemy_moves():
	for i in all_enemies.size():
		turn_list.append(all_enemies[i])
		all_enemies[i].can_move = true

func wait_turns():
	while(!turn_list.empty()):
		return
	switch_turn()

func remove_from_turn_list(obj):
	turn_list.erase(obj)

#=Генерация врагов на поле=====================================================

var alive_enemies: int = 0
var expected_enemies_on_PG
func spawn_enemy():
		var enemy = load("res://enemies/type1/Enemy1.tscn")
		var enemy_instance = enemy.instance()
		all_enemies.append(enemy_instance)
		get_tree().get_root().add_child(enemy_instance)

func _physics_process(delta):
	expected_enemies_on_PG = int((height + width)/2) + add_difficulty()
	wait_turns()
	if((alive_enemies < expected_enemies_on_PG) and game_started):
		spawn_enemy()
		alive_enemies += 1
	if(Input.is_action_just_pressed("reload")):
		get_tree().reload_current_scene()

#===============================================================================
var player_score: int = 0
func add_points(n):
	player_score += n

func add_difficulty()->int:
	var added_enemies = int(player_score/15)
	return added_enemies

func emeny_die(obj):
	obj.queue_free()
	turn_list.erase(obj)
	all_enemies.erase(obj)

var player_dead = false
func kill_player():
	player_dead = true
	get_tree().get_nodes_in_group("Player")[0].queue_free()
	
