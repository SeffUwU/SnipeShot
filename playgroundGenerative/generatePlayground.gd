extends Node2D
# Входные параметры из игрового менеджера
onready var width = GameManager.width   # Длина поля
onready var height = GameManager.height # Ширина поля
export (int) var tileDist = 100 # Расст. между плитками

var margin = Vector2(100,100) # Переменная для экспорта в другой модуль
var wholeTiles # Массив для хранения всех "плиток" игровогополя
var center_point = Vector2(0,0) # Центральная точка игрвого поля
signal returnTilesSignal(width,height,tiles,tileDist, center) # Сигнал для экспорта данных
signal cameraExportVars(width,height,tiles,margin) # Сигнал для экспорта данных
onready var tile = preload("res://playgroundGenerative/playGroundTile.tscn") # Ссылка на объект "плитки"

func _ready(): # Функция вызывающаяся при запуске модуля.
	# Код ниже центрирует все "плитки", который будут сгенерированы
	center_point = Vector2((((width-1)*tileDist)/2),((height-1)*tileDist)/2)
	self.position -= center_point
	
	wholeTiles = tiles2d() # Генерируем все "плитки"
	
	emit_signal("returnTilesSignal", height, width, wholeTiles, tileDist, center_point)
	# Отправим >player_Viewport размеры поля, все плитки, и "безопастную зону",  
	# чтобы можно было легко определить zoom камеры
	emit_signal("cameraExportVars", width, height, wholeTiles, margin)
	# Отправляет тоже самое во внутренний объект камеры.
	GameManager.set_tiles(tileDist, wholeTiles, center_point)
	# Отправляем те же данные в "игровой менеджер"
# Код ниже создает и помещает плитки в 2D массив WholeTiles
func tiles2d():
	var array = []
	for i in height:
		array.append([])
		for j in width:
			var tileInstance = tile.instance()
			add_child(tileInstance)
			tileInstance.position.x = self.position.x + (j * tileDist)
			tileInstance.position.y = self.position.y + (i * tileDist)
			tileInstance.show_behind_parent = true
			array[i].append(tileInstance)
	return array
