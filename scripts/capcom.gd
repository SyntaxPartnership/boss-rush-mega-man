extends Node2D

const SHNE_START = -56
const SHNE_END = 320

var begin = false
var shine_delay = 30
var shine_limit = 2

func _ready():
	audio.play_music("capcom")

func _input(event):
	
	if Input.is_action_just_pressed("start") or Input.is_action_just_pressed("jump"):
		if begin:
			_on_timeout()
			begin = false

func _physics_process(delta):
	if begin:
		if shine_delay > 0:
			shine_delay -= 1
		
		if shine_delay == 0 and shine_limit > 0:
			if $shine.position.x < SHNE_END:
				$shine.position.x += 600 * delta
			else:
				$shine.position.x = SHNE_START
				shine_limit -= 1
		
		if shine_limit == 0 and $text.get_visible_characters() < $text.get_total_character_count():
			$text.set_visible_characters($text.get_visible_characters() + 1)
		
	if audio.last_sound != null and !audio.last_sound.is_playing():
		$time.start()
		audio.last_sound = null

func _on_fadein():
	begin = true

func _on_fadeout():
	get_tree().change_scene("res://scenes/sp.tscn")

func _on_timeout():
	audio.stop_music("capcom")
	$fade.state = 1
	$fade.set("end", true)
