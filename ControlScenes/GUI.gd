extends Control


func _physics_process(delta):
	change_score()


var temp_scr = 0
var curr_scr = 0
func change_score():
	if(temp_scr != curr_scr):
		$NinePatchRect/RichTextLabel.bbcode_text = "SCORE: [shake rate=5 level=10]%s[/shake]" % GameManager.player_score
		curr_scr= temp_scr
	temp_scr = GameManager.player_score
	
