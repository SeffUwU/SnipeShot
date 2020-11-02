extends Node2D

onready var width = GlobalSingleton.width
onready var height = GlobalSingleton.height
export (int) var tileDist = 100

var margin = Vector2(100,100)

var wholeTiles
var center_point = Vector2(0,0)
signal returnTilesSignal(width,height,tiles,tileDist, center)
signal cameraExportVars(width,height,tiles,margin)
onready var tile = preload("res://playgroundGenerative/playGroundTile.tscn")

func _ready():
	print(GlobalSingleton.width)
	#центрируем эту сцену относительно всех будующе сгенерированных объектов
	center_point = Vector2((((width-1)*tileDist)/2),((height-1)*tileDist)/2)
	self.position -= center_point
	#==
	#генерируем все "плитки"
	wholeTiles = tiles2d()
	
	emit_signal("returnTilesSignal",height,width,wholeTiles,tileDist, center_point)
	#отправим >player_Viewport размеры поля, все плитки, и "безопастную зону",  
	#чтобы можно было легко определить zoom камеры
	emit_signal("cameraExportVars",width,height,wholeTiles,margin)

#Создает 2D массив со всеми "плитками"
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
