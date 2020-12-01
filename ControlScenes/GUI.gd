extends Control


func _process(delta):
	change_score()
	show_turns()


var temp_scr = 0
var curr_scr = 0
func change_score():
	if(temp_scr != curr_scr):
		$SCORE/RichTextLabel.bbcode_text = "SCORE: [shake rate=5 level=10]%s[/shake]" % GameManager.player_score
		curr_scr= temp_scr
	temp_scr = GameManager.player_score
	

func show_turns():
	if(GameManager.player_move_count == 1):
		$TURNS/RichTextLabel.bbcode_text = "1 SAFE TURN"
	else:
		$TURNS/RichTextLabel.bbcode_text = "NEXT: ENEMY"
