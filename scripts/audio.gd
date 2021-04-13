extends Node

var last_sound

func play_music(which):
	for i in $music.get_children():
		if i.name == which:
			last_sound = i
			i.play()

func fade_music(which):
	pass

func stop_music(which):
	for i in $music.get_children():
		if i.name == which:
			last_sound = null
			i.stop()

func play_sound(which):
	pass

func fade_sound(which):
	pass

func stop_sound(which):
	pass
