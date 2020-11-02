extends Node

signal swiped(direction)              # Сигнал для отправки другим модулям
signal swiped_cancel(start_position)  # Сигнал при отмене "свайпа"
signal tap                            # Сигнал для отправки другим модулям

export var tapRadius = 20.0  # Радиус "тапа" или "клика" по экрану

export(float,1.0,1.5) var MAX_DIAGONAL_SLOPE = 1.5  # Максимум диагонального движения

onready var timer = $Timer  # Таймер для отметы "свайпа"
var swipe_start_position = Vector2()  # Позиция начала свайпа 

func _input(event):
# Вызывается при любом вводе со стороны пользователя
	if not event is InputEventScreenTouch:
		return
# Выше проверка на то что используется сенсорный экран (если не так то выход)
	if event.pressed:
	# При нажатии на экран
		_start_detection(event.position)
	# Сохранения начальной позиции "свайпа" и начало таймера в вызываемой функции
	elif not timer.is_stopped():
	# Вызывается если таймер НЕ остановился
		_end_detection(event.position)
		# Создание вектора "свайпа" по конечной позиции
	pass

func _start_detection(position):
	swipe_start_position = position  # сохранения позиции начала свайпа
	timer.start()  # начало таймера "свайпа"


func _end_detection(position):
	timer.stop() # Остановка таймера
	var direction = (position - swipe_start_position).normalized()
	# Нормализированный вектор направления
	var pointsDistance = position - swipe_start_position  # Расстояние между началом и концом "свайпа"
	if (pointsDistance.x < -tapRadius or pointsDistance.x > tapRadius) \
	   or (pointsDistance.y <-tapRadius or pointsDistance.y > tapRadius):
	# Проверка на то чтобы расстояние между началом и концом свайпа было не больше
	# tapRadius
		if abs(direction.x) + abs(direction.y) >= MAX_DIAGONAL_SLOPE:
		# Если модуль x + y больше максимума диагонального движения то выход
			return
		
		if abs(direction.x) > abs(direction.y):
		# Если модуль X больше моделя Y
			emit_signal("swiped", Vector2(sign(direction.x),0.0))
			# Отправляет сигнал направления X
			# Функция sign() возвращает знак числа (Пример: sign(-6) вернет -1,
			# sign(5) вернет 1).
			
		else:
			emit_signal("swiped", Vector2(0.0,sign(direction.y)))
			# Отправляет сигнал направления Y
	else:
	# Если расстояние между началом свайпа и его концом меньше tapRadius
		emit_signal("tap")
		# Отправляем сигнала "тапа" или "клика"
func _on_Timer_timeout():
# Если таймер дошел до 0
	emit_signal("swiped_cancel", swipe_start_position)
# Пока что нигде не используетя

