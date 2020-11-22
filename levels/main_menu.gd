extends Control
#модуль главного меню
var width = 6   # ширина игрового поля
var height = 6  # высота игрового поля

func _on_width_value_changed(value):  # вызываетя при изменении слайлепа ширины
	width = value
	$width/text.text = "Width:" + str(width)  #изменяю текст под слайдером


func _on_height_value_changed(value):
	height = value  # вызывается при изменения слайдера высоты
	$height/text.text = "Height:" + str(height)  #изменяю текст под слайдером


func _on_start_button_up():  # вызывается при нажатии кнопки Start
	GameManager.set_size(height,width)
# Строка выше отправляет синглтону информацию о желаемом размере поля
	get_tree().change_scene("res://levels/PlayArea.tscn")
# После чего строка выше меняет текущую сцену на игровую зону

func display_warn(h,w):
	if(h >= 16 or w >= 16):
		$WH_warn.visible = true
	else:
		$WH_warn.visible = false

func _process(delta):
	display_warn(height, width)
