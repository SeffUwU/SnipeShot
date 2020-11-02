extends Control
var pressDirection = Vector2()

signal sendTouchControls(dir)
signal sendShootMode
var hidden = true

func _process(delta):
	pressDirection = Vector2.ZERO
	if $Node/UP.pressed:
		pressDirection.y -= 1
	if $Node/DOWN.pressed:
		pressDirection.y += 1
	if $Node/LEFT.pressed:
		pressDirection.x -= 1
	if $Node/RIGHT.pressed:
		pressDirection.x += 1
	if $Node/UP.pressed or $Node/DOWN.pressed or $Node/LEFT.pressed or $Node/RIGHT.pressed:
		emit_signal("sendTouchControls", pressDirection)
	if $Node/SHOOTMODE.pressed:
		if $timerSHOOT.is_stopped():
			emit_signal("sendShootMode")
			$timerSHOOT.start()
	if $toggleGUI.pressed and $toggleGUIcooldown.is_stopped():
		if hidden == true:
			$Node/UP.visible        = false
			$Node/DOWN.visible      = false
			$Node/RIGHT.visible     = false
			$Node/LEFT.visible      = false
			$Node/SHOOTMODE.visible = false
			$Node/SHOOTMODE/controls.visible  = false
			hidden = false
			$toggleGUIcooldown.start()
		else:
			$Node/UP.visible        = true
			$Node/DOWN.visible      = true
			$Node/RIGHT.visible     = true
			$Node/LEFT.visible      = true
			$Node/SHOOTMODE.visible = true
			$Node/SHOOTMODE/controls.visible  = true
			hidden = true
			$toggleGUIcooldown.start()
