extends Camera2D
# Используется исключительно для измения приближения камеры к "плиткам" чтобы
# уместить их всех
var margin  # Зона вокруг плитки которую нужно тоже включить в кадр
var width   # Ширина игрового поля
var height  # Высота игрового поля
var wholeTiles  # Массив всех плиток
var targets = []  # Цели которы камера должна уместить в кадре

onready var screen_size = self.get_viewport_rect().size
# При запуске сохраняет размер "кадра" или viewport'а

func _on_generatePlayground_cameraExportVars(width, height, tiles, margin):
# Сигнал отправляемый модулем "generatePlayground.gd"
	wholeTiles = tiles
	targets.append(wholeTiles[0][0])
	targets.append(wholeTiles[height-1][width-1])
	# Две строки выше добавляют в цели камеры первую и последнюю "плитку"
	var r = Rect2(position, Vector2.ONE) # Создание прямоугольника для умещения в кадре
	for target in targets:
	# Увеличивает прямоугольник до размеров центральной позиции "плиток"
		r = r.expand(target.position)
	r = r.grow_individual(margin.x, margin.y, margin.x, margin.y)
	# Увеличивает прямоугольник еще немного по margin'у

	var z # Приближение
	if r.size.x > r.size.y * screen_size.aspect():
	# Если длина X > длины Y * соотношения сторон экрана, то устанавливаем зум
		z = r.size.x / screen_size.x
	else:
	# Иначе, то устанавливаем зум
		z = r.size.y / screen_size.y
	zoom = Vector2.ONE * z
	$Control.rect_min_size *= z
	pass



