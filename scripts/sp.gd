extends Node2D

var begin = false

func _input(event):
	
	if Input.is_action_just_pressed("start") or Input.is_action_just_pressed("jump"):
		if begin:
			_on_time_timeout()
			begin = false

func _on_fade_fadein():
	begin = true
	$time.start()

func _on_fade_fadeout():
	get_tree().change_scene("res://scenes/cutscene.tscn")

func _on_time_timeout():
	$fade.state = 1
	$fade.set('end', true)
