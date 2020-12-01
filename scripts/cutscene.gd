extends Node2D

var cutscene = 0
var new_scene = -1
var sub_scene = 0
var txt_delay = 0
var td_max = 0
var time_allow = true
var allow_text = true
var txt_overlap = true
var paper_delay = [10, 60, 150]
var camx_ogpos = 0
var shake = false
var shake_time = 0
var boom_flash = 0

var text = {
	1 : ["20XX", "IN A SEEMINGLY ABANDONED\n\nJUNKYARD."],
	2 : ["", ""],
	3 : [" [??????]:", "I FEEL IT... LAMENTATION,\n\nREGRET, ANGER..."],
	4 : [" [??????]:", "IT'S LINGERING INSIDE\n\nYOUR BROKEN BODIES."],
	5 : [" [??????]:", "IT'LL BE FUN TO GIVE\n\nYOU A WAY TO FULLY EXPRESS"],
	6 : [" [??????]:", "THOSE EMOTIONS."],
	7 : [" [??????]:", "NOW TELL ME..."],
	8 : [" [??????]:", "WHAT DO YOU DESIRE?"],
	9 : ["", ""],
	10 : [" [ROBOTS]:", "REVENGE!!!"],
	11 : ["", ""],
	12 : ["MEANWHILE...", "INSIDE THE NOTORIOUS DR.\n\nWILY'S NEW LAIR."],
	13 : ["", ""],
	14 : [" [DR. WILY]:", "SOON THIS BASE WILL BE FULLY\n\nOPERATIONAL. AND THEN I'LL"],
	15 : [" [DR. WILY]:", "SHOW THE WORLD MY TRUE\n\nGENIUS!!"],
	16 : ["", ""],
	19 : [" [DR. WILY]:", "WH-WH-WHAT IS THAT NOISE?!"],
	20 : ["", ""],
}

# Called when the node enters the scene tree for the first time.
func _ready():
	if cutscene == 0:
		$audio/music/opening.play()
		$fade/front/name.set_visible_characters(0)
		$fade/front/text.set_visible_characters(0)
		$timer.set_wait_time(1.0)
		$timer.start()

func _physics_process(delta):
	
	print(sub_scene,', ',$cam.position.x,', ',$timer.get_time_left())
	
	if td_max > 0:
		if txt_delay > 0:
			txt_delay -= 1
	
	if shake:
		if shake_time > 0:
			$cam.position.x = int(round(rand_range(camx_ogpos - 2, camx_ogpos + 2)))
			shake_time -= 1
		else:
			$cam.position.x = camx_ogpos
			shake = false
	
	if boom_flash > 0:
		boom_flash -= 1
	else:
		if $sprites/white.is_visible_in_tree():
			$sprites/white.hide()
		
	
	if allow_text:
		if txt_overlap:
			if $fade/front/name.get_visible_characters() < $fade/front/name.get_total_character_count():
				$fade/front/name.set_visible_characters($fade/front/name.get_visible_characters() + 1)
			else:
				if $fade/front/text.get_visible_characters() < $fade/front/text.get_total_character_count() and txt_delay == 0:
					$fade/front/text.set_visible_characters($fade/front/text.get_visible_characters() + 1)
					txt_delay = td_max
				else:
					if $timer.is_stopped():
						$timer.start()
		else:
			if $fade/bottom/name.get_text() != "":
				if $fade/bottom/text.get_visible_characters() < $fade/bottom/text.get_total_character_count() and txt_delay == 0:
					$fade/bottom/text.set_visible_characters($fade/bottom/text.get_visible_characters() + 1)
					txt_delay = td_max
				else:
					if $timer.is_stopped() and time_allow:
						$timer.start()
				
	match sub_scene:
		3:
			if $cam.position.x > 128:
				$cam.position.x -= 1
			else:
				$sprites/fugue/anim.play("teleport")
				$sprites/fugue.show()
				time_allow = true
				set_text()
	
func set_text():
	sub_scene += 1
	
	if new_scene != sub_scene:
		if txt_overlap:
			if text.has(sub_scene):
				$fade/front/name.set_visible_characters(0)
				$fade/front/text.set_visible_characters(0)
				$fade/front/name.set_text(text.get(sub_scene)[0])
				$fade/front/text.set_text(text.get(sub_scene)[1])
		else:
			if text.has(sub_scene):
				$fade/bottom/text.set_visible_characters(0)
				$fade/bottom/name.set_text(text.get(sub_scene)[0])
				$fade/bottom/text.set_text(text.get(sub_scene)[1])
		new_scene = sub_scene

func _on_timer_timeout():
	set_text()
	
	match sub_scene:
		1:
			allow_text = true
			$timer.stop()
			$timer.set_wait_time(3.0)
		2:
			txt_overlap = false
			time_allow = false
			$timer.stop()
			$fade/fadeout.interpolate_property($fade/front, 'modulate', Color(1.0, 1.0, 1.0, 1.0), Color(1.0, 1.0, 1.0, 0.0), 0.125, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			$fade/fadeout.start()
		9:
			$timer.stop()
			$fade/fadeout.interpolate_property($fade/front, 'modulate', Color(1.0, 1.0, 1.0, 0.0), Color(1.0, 1.0, 1.0, 1.0), 0.125, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			$fade/fadeout.start()
		11:
			set_txt_delay_max(0)
		13:
			$cam.smoothing_enabled = false
			$cam.position.x = 896
			camx_ogpos = $cam.position.x
			txt_overlap = false
			time_allow = false
			$timer.stop()
			$fade/fadeout.interpolate_property($fade/front, 'modulate', Color(1.0, 1.0, 1.0, 1.0), Color(1.0, 1.0, 1.0, 0.0), 0.125, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			$fade/fadeout.start()
		16:
			$sprites/wily/anim.play("nervous")
			$timer.set_wait_time(1.0)
			$timer.start()
			$audio/music/opening.stop()
			$audio/sfx/thud.play()
			shake = true
			shake_time = 20
		17:
			$timer.set_wait_time(0.25)
			$timer.start()
			$audio/sfx/thud.play()
			shake = true
			shake_time = 20
		18:
			time_allow = true
			$sprites/wily/anim.play("idle2")
			$timer.stop()
			$timer.set_wait_time(3.0)
			$audio/sfx/thud.play()
			set_text()
			shake = true
			shake_time = 20
		20:
			$timer.set_wait_time(0.25)
			$timer.start()
			$audio/sfx/thud.play()
			shake = true
			shake_time = 20
		21:
			$timer.set_wait_time(0.25)
			$timer.start()
			$audio/sfx/thud.play()
			shake = true
			shake_time = 20
		22:
			$timer.set_wait_time(1.0)
			$timer.start()
			$audio/sfx/thud.play()
			shake = true
			shake_time = 20
		23:
			$sprites/wily/anim.play("surprise")
			boom_flash = 8
			$sprites/white.show()
			$map/hole.show()
			var boom = load("res://scenes/effects/l_explode.tscn").instance()
			boom.position.x = $map/hole.position.x + 16
			boom.position.y = $map/hole.position.y - 16
			$sprites.add_child(boom)
			$timer.set_wait_time(0.25)
			$timer.start()
			$audio/sfx/bigboom.play()
			shake = true
			shake_time = 20
		24:
			boom_flash = 8
			$sprites/white.show()
			var boom = load("res://scenes/effects/l_explode.tscn").instance()
			boom.position.x = $map/hole.position.x
			boom.position.y = $map/hole.position.y
			$sprites.add_child(boom)
			$timer.set_wait_time(0.25)
			$timer.start()
			$audio/sfx/bigboom.play()
			shake = true
			shake_time = 20
		25:
			boom_flash = 8
			$sprites/white.show()
			var boom = load("res://scenes/effects/l_explode.tscn").instance()
			boom.position.x = $map/hole.position.x - 24
			boom.position.y = $map/hole.position.y + 18
			$sprites.add_child(boom)
			$timer.set_wait_time(0.25)
			$timer.start()
			$audio/sfx/bigboom.play()
			shake = true
			shake_time = 20
		26:
			boom_flash = 8
			$sprites/white.show()
			var boom = load("res://scenes/effects/l_explode.tscn").instance()
			boom.position.x = $map/hole.position.x - 32
			boom.position.y = $map/hole.position.y - 24
			$sprites.add_child(boom)
			$timer.set_wait_time(0.25)
			$timer.start()
			$audio/sfx/bigboom.play()
			shake = true
			shake_time = 20
		27:
			$sprites/wily/anim.play("idle2")
			boom_flash = 8
			$sprites/white.show()
			var boom = load("res://scenes/effects/l_explode.tscn").instance()
			boom.position.x = $map/hole.position.x + 32
			boom.position.y = $map/hole.position.y + 24
			$sprites.add_child(boom)
			$timer.set_wait_time(2.0)
			$timer.start()
			$audio/sfx/bigboom.play()
			shake = true
			shake_time = 20
			
func set_txt_delay_max(number):
	td_max = number
	txt_delay = number

func _on_fadeout_tween_completed(object, key):
	match sub_scene:
		2:
			set_text()
		9:
			txt_overlap = true
			set_txt_delay_max(10)
			set_text()
		13:
			time_allow = true
			set_text()

func _on_fugue_anim_done(anim_name):
	match anim_name:
		"teleport":
			$sprites/fugue/anim.play("hover")
