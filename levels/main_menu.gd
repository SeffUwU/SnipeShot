extends Control
#модуль главного меню
var width = 5   # ширина игрового поля
var height = 5  # высота игрового поля

func _on_width_value_changed(value):  # вызываетя при изменении слайлепа ширины
	width = value
	$width/text.text = "Width:" + str(width)  #изменяю текст под слайдером


func _on_height_value_changed(value):
	height = value  # вызывается при изменения слайдера высоты
	$height/text.text = "Height:" + str(height)  #изменяю текст под слайдером


func _on_start_button_up():  # вызывается при нажатии кнопки Start
	GlobalSingleton.get_size(height,width)
# Строка выше отправляет синглтону информацию о желаемом размере поля
	get_tree().change_scene("res://levels/PlayArea.tscn")
# После чего строка выше меняет текущую сцену на игровую зону
