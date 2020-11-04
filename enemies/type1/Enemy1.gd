extends RigidBody2D

var playground_size = Vector2.ZERO
var playground_tiles
var tile_distance
var center_pos

var rng = RandomNumberGenerator.new()
func _on_generatePlayground_returnTilesSignal(width, height, tiles, tileDist, center):
	playground_size  = Vector2(height, width)  # Размер игрового поля
	playground_tiles = tiles  # 2Д Массив всех "плиток"
	tile_distance    = tileDist  # Расстояние между "плитками"
	center_pos       = center  # Центр игрового поля
	
	rng.randomize()
	var random_position = Vector2(rng.randi_range(0, playground_size.x - 1), rng.randi_range(0, playground_size.y - 1))
	self.position = playground_tiles[random_position.x][random_position.y].position - center_pos



func _ready():
	pass
