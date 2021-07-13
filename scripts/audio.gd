extends Node

var last_song
var last_sound

func _input(event):
	
	if Input.is_key_pressed(KEY_SPACE):
		$music/boss_a.play()

func play_music(which):
	for i in $music.get_children():
		if i.name == which:
			last_song = i
			i.play()

func stop_all_music():
	for i in $music.get_children():
		i.stop()

func stop_music(which):
	for i in $music.get_children():
		if i.name == which:
			last_song = null
			i.stop()

func play_sound(which):
	for i in $sfx.get_children():
		if i.name == which:
			last_sound = i
			i.play()

func fade_sound(which):
	pass

func stop_sound(which):
	for i in $sfx.get_children():
		if i.name == which:
			last_sound = null
			i.stop()
