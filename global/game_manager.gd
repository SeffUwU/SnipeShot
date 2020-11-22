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
#===============================================================================

# GAME MANAGER | Менеджер игровых событий ниже

var game_started: bool = false # Начата ли игра игроком

#=Смена хода игрока и врагов====================================================
var players_move: bool = true # Ход ли у игрока в данный момент
func switch_turn():
	if (players_move == true):
		players_move = false
	else:
		players_move = true
#=Генерация врагов на поле=====================================================

var alive_enemies: int = 0
func spawn_enemy():
		var enemy = load("res://enemies/type1/Enemy1.tscn")
		var enemy_instance = enemy.instance()
		get_tree().get_root().add_child(enemy_instance)
func _physics_process(delta):
	var expected_enemies_on_PG = int((height + width)/2)
	if((alive_enemies < expected_enemies_on_PG) and game_started):
		spawn_enemy()
		alive_enemies += 1
#===============================================================================
var player_score: int = 0
func add_points(n):
	player_score += n
