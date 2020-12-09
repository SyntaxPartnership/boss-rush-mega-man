extends Node2D

#For moving Rock.
const ROCK_RSPD = 90
const ROCK_JSPD = -310
const ROCK_GRAV = 900
var rock_xspd = 0
var rock_vel = Vector2(0, 0)
var rock_move = false

#Wily mugshot
var wframe = 0
var wrand = 0
var wfade = 30
var wflash = 0

var new_scene = -1
var sub_scene = 0
var txt_delay = 0
var td_max = 0
var time_allow = true
var allow_text = true
var txt_overlap = true
var paper_delay = [5, 50, 150]
var paper_anim = [3, 5, 2]
var paper_frame = [0, 0, 0]
var camx_ogpos = 0
var shake = false
var shake_time = 0
var boom_flash = 0
var bf_delay = 4
var skip = false
var next = false
var next_flash = 0

var radius = Vector2.ONE * 0.25
var rotation_duration = 1.0
var offset = 0

var text = {
	#Intro scene. Before the title screen.
	1 : ["20XX", "IN A SEEMINGLY ABANDONED\n\nJUNKYARD."],
	2 : ["", ""],
	3 : [" [??????]:", "I FEEL IT... LAMENTATION,\n\nREGRET, ANGER..."],
	4 : [" [??????]:", "IT'S LINGERING INSIDE\n\nYOUR BROKEN BODIES."],
	5 : [" [??????]:", "IT'LL BE FUN TO GIVE\n\nYOU A WAY TO FULLY EXPRESS"],
	6 : [" [??????]:", "THOSE EMOTIONS."],
	7 : [" [??????]:", "NOW TELL ME..."],
	8 : [" [??????]:", "WHAT DO YOU DESIRE?"],
	9 : ["", ""],
	10 : [" [ROBOTS]:", "[shake rate=30 level=8]R-E-V-E-N-G-E!!![/shake]"],
	11 : ["", ""],
	12 : ["MEANWHILE...", "INSIDE THE NOTORIOUS DR.\n\nWILY'S NEW LAIR."],
	13 : ["", ""],
	14 : [" [DR. WILY]:", "SOON THIS BASE WILL BE FULLY\n\nOPERATIONAL. AND THEN I'LL"],
	15 : [" [DR. WILY]:", "SHOW THE WORLD MY TRUE\n\nGENIUS!!"],
	16 : ["", ""],
	19 : [" [DR. WILY]:", "WH-WH-WHAT IS THAT NOISE?!"],
	20 : ["", ""],
	31 : [" [DR. WILY]:", "I DON'T CARE WHO RECEIVES\n\nTHIS! HERE ARE MY\n\nCOORDINATES! SOMEBODY!\n\nANYBODY! SAVE ME!"],
	32 : [" [??????]:", "FUFUFU! SO MY HUNCH ON\n\nTHIS PLANET WAS CORRECT.\n\nI'M CERTAINLY GOING TO\n\nHAVE FUN HERE!"],
	33 : ["", ""],
	#Mega Man Opening Scene - After Title Screen.
	36 : [" [DR. WILY]:", "-MY COORDINATES! SOMEBODY!\n\nANYBODY! SAVE ME!"],
	37 : [" [DR. LIGHT]:", "THERE'S NO DOUBT ABOUT IT.\n\nTHIS IS WILY'S VOICE."],
	38 : [" [DR. LIGHT]:", "WHAT HAS HE GOTTEN INTO\n\nTHIS TIME?"],
	39 : [" [ROCK]:", "IF HE'S IN DANGER, I HAVE NO\n\nCHOICE BUT TO GO HELP HIM."],
	40 : [" [ROLL]:", "BUT WHAT IF IT'S A TRAP? THAT\n\nMEAN DR. WILY IS CAPABLE OF"],
	41 : [" [ROLL]:", "ANYTHING! YOU CAN'T TRUST\n\nHIM!"],
	42 : [" [ROCK]:", "MAYBE. BUT I HAVE TO RISK IT.\n\nEVEN SOMEONE LIKE HIM"],
	43 : [" [ROCK]:", "DESERVES HELP."],
	54 : [" [MEGAMAN]:", "IF IT'S ONE OF HIS TRICKS,\n\nI'LL DEAL WITH IT LIKE I"],
	55 : [" [MEGAMAN]:", "ALWAYS DO!"],
	56 : [" [DR. LIGHT]:", "I AGREE. WHATEVER IS GOING\n\nON, WE NEED TO INVESTIGATE."],
	57 : [" [DR. LIGHT]:", "WHEN WILY IS INVOLVED, IT\n\nCAN'T MEAN ANYTHING GOOD."],
	58 : [" [DR. LIGHT]:", "PLEASE, BE CAREFUL."],
	59 : [" [MEGAMAN]:", "I'LL BE HOME SOON. DON'T\n\nWORRY!"],
}

func _input(event):
	
	if Input.is_action_just_pressed("start"):
		if !skip:
			skip()
	
	#Jump behaves differently depending on the scene.
	if Input.is_action_just_pressed("jump"):
		match global.cutscene:
			0:
				skip()
			1:
				if next:
					set_text()
					next = false

# Called when the node enters the scene tree for the first time.
func _ready():
	match global.cutscene:
		0:
			sub_scene = 0
			$audio/music/opening.play()
			$fade/front/name.set_visible_characters(0)
			$fade/front/text2.set_visible_characters(0)
			$timer.set_wait_time(1.0)
			$timer.start()
		1:
			$audio/music/lab.play()
			txt_overlap = false
			$sprites/light/anim.play("idle")
			$sprites/auto/anim.play("idle")
			$sprites/eddie/anim.play("idle")
			$sprites/rock/anim.play("idle1")
			$fade/fadeout.interpolate_property($fade/front, 'modulate', Color(1.0, 1.0, 1.0, 1.0), Color(1.0, 1.0, 1.0, 0.0), 0.125, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			$fade/fadeout.start()
			$cam.smoothing_enabled = false
			$cam.position.x = 1408
			sub_scene = 35
			$fade/front/name.set_visible_characters(0)
			$fade/front/text2.set_visible_characters(0)
			$timer.set_wait_time(1.0)
			$timer.start()

func _physics_process(delta):
	
	print(sub_scene,', ',wfade,', ',wflash)
	
	if global.cutscene != 0:
		if next:
			next_flash += 1
			
			if next_flash > 5:
				if !$fade/bottom/next.is_visible_in_tree():
					$fade/bottom/next.show()
				else:
					$fade/bottom/next.hide()
				next_flash = 0
		else:
			if $fade/bottom/next.is_visible_in_tree():
				$fade/bottom/next.hide()
	
	if global.cutscene == 1:
		
		if wrand > 0:
			wrand -= 1
		
		if wrand == 0:
			wframe = int(round(rand_range(0, 6)))
			wrand = int(round(rand_range(1, 4)))
			$map/wily_big.frame = wframe
		
		if text.has(sub_scene):
			if text.get(sub_scene)[0] == " [DR. LIGHT]:":
				if $sprites/light/anim.current_animation != "talk":
					$sprites/light/anim.play("talk")
			else:
				if $sprites/light/anim.current_animation != "idle":
					$sprites/light/anim.play("idle")
			
			if text.get(sub_scene)[0] == " [ROLL]:":
				if $sprites/roll.frame != 1:
					$sprites/roll.frame = 1
			else:
				if $sprites/roll.frame != 0:
					$sprites/roll.frame = 0
		
		rock_vel.x = rock_xspd
		if rock_move:
			rock_vel.y += ROCK_GRAV * delta
		else:
			rock_vel.y = 0
			
		rock_vel = $sprites/rock.move_and_slide(rock_vel, Vector2(0, -1))
		
		if boom_flash > 0:
			boom_flash -= 1
		else:
			if $sprites/flash.is_visible_in_tree():
				$sprites/flash.hide()
		
		match sub_scene:
			37:
				if wfade > 0:
					
					if wflash == 1:
						if $map/wily_big.is_visible_in_tree():
							$map/wily_big.hide()
					elif wflash == 0:
						if !$map/wily_big.is_visible_in_tree():
							$map/wily_big.show()
					
					wflash += 1
					wfade -= 1
					
					if wflash > 1:
						wflash = 0
				else:
					if $map/wily_big.is_visible_in_tree():
						$map/wily_big.hide()
			44:
				$sprites/rock/anim.play("jump")
				rock_vel.y = ROCK_JSPD
				rock_move = true
				sub_scene += 1
			45:
				if rock_vel.y >= 0:
					$audio/sfx/transform1.play()
					rock_move = false
					$sprites/flash.show()
					boom_flash = 8
					sub_scene += 1
			46:
				if boom_flash == 0:
					bf_delay -= 1
					if bf_delay == 0:
						$audio/sfx/transform1.stop()
						$audio/sfx/transform1.play()
						$sprites/flash.show()
						boom_flash = 8
						bf_delay = 4
						sub_scene += 1
			47:
				if boom_flash == 0:
					bf_delay -= 1
					if bf_delay == 0:
						$audio/sfx/transform1.stop()
						$audio/sfx/transform1.play()
						$sprites/flash.show()
						boom_flash = 8
						bf_delay = 4
						sub_scene += 1
			48:
				if boom_flash == 0:
					bf_delay -= 1
					if bf_delay == 0:
						$audio/sfx/transform1.stop()
						$audio/sfx/transform1.play()
						$sprites/flash.show()
						boom_flash = 8
						bf_delay = 4
						sub_scene += 1
			49:
				if boom_flash == 0:
					bf_delay -= 1
					if bf_delay == 0:
						$audio/sfx/transform1.stop()
						$audio/sfx/transform1.play()
						$sprites/flash.show()
						boom_flash = 8
						bf_delay = 4
						sub_scene += 1
			50:
				if boom_flash == 0:
					bf_delay -= 1
					if bf_delay == 0:
						$audio/sfx/transform1.stop()
						$audio/sfx/transform1.play()
						$sprites/flash.show()
						boom_flash = 8
						bf_delay = 4
						sub_scene += 1
			51:
				if boom_flash == 0:
					bf_delay -= 1
					if bf_delay == 0:
						$audio/sfx/transform1.stop()
						$audio/sfx/bling.play()
						$sprites/rock/anim.play("transform")
						sub_scene += 1
			52:
				if $sprites/rock.position.y >= 148:
					rock_move = false
					$sprites/rock.position.y = 148
					$audio/sfx/land.play()
					$sprites/rock/anim.play("idle2")
					bf_delay = 15
					sub_scene += 1
			53:
				if boom_flash == 0:
					bf_delay -= 1
					if bf_delay == 0:
						set_text()
			60:
				bf_delay = 15
				sub_scene += 1
			61:
				$sprites/rock/sprite.flip_h = true
				$sprites/rock/anim.play("lilstep")
				sub_scene += 1
			62:
				if $sprites/rock.position.x >= 1496:
					$audio/sfx/beamout.play()
					rock_xspd = 0
					$sprites/rock/anim.play("leave")
					sub_scene += 1
			64:
				if $sprites/rock.position.y > -32:
					$sprites/rock.position.y -= 8
				else:
					sub_scene += 1
			65:
				bf_delay = 30
				sub_scene += 1
			66:
				if boom_flash == 0:
					bf_delay -= 1
					if bf_delay == 0:
						$fade/fadeout.interpolate_property($fade/front, 'modulate', Color(1.0, 1.0, 1.0, 0.0), Color(1.0, 1.0, 1.0, 1.0), 0.125, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
						$fade/fadeout.start()
						sub_scene += 1
	
	if !skip:
		if sub_scene > 2 and sub_scene < 30:
			if paper_delay[0] > 0:
				paper_delay[0] -= 1
			if paper_delay[1] > 0:
				paper_delay[1] -= 1
			if paper_delay[2] > 0:
				paper_delay[2] -= 1
			
			if paper_anim[0] > 0:
				paper_anim[0] -= 1
			else:
				paper_frame[0] += 1
				if paper_frame[0] > 7:
					paper_frame[0] = 0
				$sprites/paper.frame = paper_frame[0]
				paper_anim[0] = 3
			if paper_anim[1] > 0:
				paper_anim[1] -= 1
			else:
				paper_frame[1] += 1
				if paper_frame[1] > 7:
					paper_frame[1] = 0
				$sprites/paper2.frame = paper_frame[1]
				paper_anim[1] = 3
			if paper_anim[2] > 0:
				paper_anim[2] -= 1
			else:
				paper_frame[2] += 1
				if paper_frame[2] > 7:
					paper_frame[2] = 0
				$sprites/paper3.frame = paper_frame[2]
				paper_anim[2] = 3
			
			if paper_delay[0] == 0:
				if $sprites/paper.frame < 3:
					$sprites/paper.position.y += 0.25
					$sprites/paper.position.x += 4
				else:
					$sprites/paper.position.y += 0.25
					$sprites/paper.position.x += 2
			
			if paper_delay[1] == 0:
				if $sprites/paper2.frame < 3:
					$sprites/paper2.position.y -= 0.3
					$sprites/paper2.position.x += 3
				else:
					$sprites/paper2.position.y -= 0.3
					$sprites/paper2.position.x += 1.5
			
			if paper_delay[2] == 0:
				if $sprites/paper3.frame < 3:
					$sprites/paper3.position.y += 0.1
					$sprites/paper3.position.x += 5
				else:
					$sprites/paper3.position.y += 0.1
					$sprites/paper3.position.x += 2.5
		
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
			if $sprites/flash.is_visible_in_tree():
				$sprites/flash.hide()
		
		if $sprites/fugue/anim.current_animation == "hover":
			offset += 0.75 * PI * delta / float(rotation_duration)
			offset = wrapf(offset, -PI, PI)
			var new_pos = Vector2()
			new_pos.y = sin(offset) * radius.y
			$sprites/fugue.position += new_pos
		
		if sub_scene < 30:
			if $sprites/wily/anim.current_animation == "scoot" and $sprites/wily.frame == 10:
				$sprites/wily.position.x += 0.125
			
			if $sprites/wily/anim.current_animation == "run":
				var swoop_ang = ($sprites/shdw_swoop.position - $sprites/wily.position).normalized()
				var roto_ang = ($sprites/shdw_roto.position - $sprites/wily.position).normalized()
				$sprites/shdw_swoop.position -= swoop_ang * 0.60
				$sprites/shdw_roto.position -= roto_ang * 0.60
				$sprites/wily.position.x += 0.5
				$sprites/shdw_scuttle.position.x += 0.60
				$sprites/shdw_defend.position.x += 0.60
	
	if allow_text:
		if txt_overlap:
			if $fade/front/name.get_visible_characters() < $fade/front/name.get_total_character_count():
				if next:
					next = false
				$fade/front/name.set_visible_characters($fade/front/name.get_visible_characters() + 1)
				$timer.stop()
			else:
				if $fade/front/text2.get_visible_characters() < $fade/front/text2.get_total_character_count() and txt_delay == 0:
					$fade/front/text2.set_visible_characters($fade/front/text2.get_visible_characters() + 1)
					$timer.stop()
					txt_delay = td_max
				elif $fade/front/text2.get_visible_characters() == $fade/front/text2.get_total_character_count():
					if global.cutscene == 0:
						if $timer.is_stopped():
							$timer.start()
					else:
						if !next:
							next = true
		else:
			if $fade/bottom/name.get_text() != "":
				if $fade/bottom/text.get_visible_characters() < $fade/bottom/text.get_total_character_count() and txt_delay == 0:
					if next:
						next = false
					$fade/bottom/text.set_visible_characters($fade/bottom/text.get_visible_characters() + 1)
					$timer.stop()
					txt_delay = td_max
				elif $fade/bottom/text.get_visible_characters() == $fade/bottom/text.get_total_character_count():
					if global.cutscene == 0:
						if $timer.is_stopped() and time_allow:
							$timer.start()
					else:
						if !next:
							if text.has(sub_scene):
								next = true
				
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
				$fade/front/text2.set_visible_characters(0)
				$fade/front/name.set_text(text.get(sub_scene)[0])
				if sub_scene != 10:
					$fade/front/text2.set_text(text.get(sub_scene)[1])
				else:
					$fade/front/text2.set_bbcode(text.get(sub_scene)[1])
		else:
			if text.has(sub_scene):
				$fade/bottom/text.set_visible_characters(0)
				$fade/bottom/name.set_text(text.get(sub_scene)[0])
				$fade/bottom/text.set_text(text.get(sub_scene)[1])
		if !text.has(sub_scene):
			$fade/front/name.set_text("")
			$fade/front/text2.set_text("")
			$fade/bottom/name.set_text("")
			$fade/bottom/text.set_text("")
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
			$sprites/flash.show() 
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
			$sprites/shdw_swoop.show()
			$sprites/shdw_roto.show()
			$sprites/shdw_scuttle.show()
			$sprites/shdw_defend.show()
			
			$sprites/shdw_swoop/anim.play("idle1")
			$sprites/shdw_roto/anim.play("idle1")
			$sprites/shdw_scuttle/anim.play("fall")
			$sprites/shdw_defend/anim.play("idle1")
			
			$fade/fadeout.interpolate_property($sprites/shdw_swoop, 'position', $sprites/shdw_swoop.position, $sprites/shdw_swoop.position + Vector2(32, -20), 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			$fade/fadeout.interpolate_property($sprites/shdw_roto, 'position', $sprites/shdw_roto.position, $sprites/shdw_roto.position + Vector2(-24, -28), 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			$fade/fadeout.interpolate_property($sprites/shdw_defend, 'position', $sprites/shdw_defend.position, $sprites/shdw_defend.position + Vector2(-24, 12), 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			$fade/fadeout.interpolate_property($sprites/shdw_scuttle, 'position', $sprites/shdw_scuttle.position, $sprites/shdw_scuttle.position + Vector2(24, 15), 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			$fade/fadeout.start()
			
			boom_flash = 8
			$sprites/flash.show()
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
			$sprites/flash.show()
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
			$sprites/flash.show()
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
			$sprites/flash.show()
			var boom = load("res://scenes/effects/l_explode.tscn").instance()
			boom.position.x = $map/hole.position.x + 32
			boom.position.y = $map/hole.position.y + 24
			$sprites.add_child(boom)
			$timer.set_wait_time(1.5)
			$timer.start()
			$audio/sfx/bigboom.play()
			shake = true
			shake_time = 20
		28:
			$timer.stop()
			time_allow = false
			$sprites/wily/anim.play("scoot")
		29:
			$timer.set_wait_time(0.5)
			$timer.start()
		30:
			txt_overlap = true
			time_allow = false
			$timer.stop()
			$fade/fadeout.interpolate_property($fade/front, 'modulate', Color(1.0, 1.0, 1.0, 0.0), Color(1.0, 1.0, 1.0, 1.0), 0.125, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			$fade/fadeout.start()
		33:
			$timer.stop()
			$timer.set_wait_time(1.0)
			$timer.start()
		34:
			$timer.stop()
# warning-ignore:return_value_discarded
			get_tree().change_scene("res://scenes/title.tscn")
		36:
			$timer.stop()
			
func set_txt_delay_max(number):
	td_max = number
	txt_delay = number

# warning-ignore:unused_argument
# warning-ignore:unused_argument
func _on_fadeout_tween_completed(object, key):
	
	#Swap the below section out for when more cutscenes are added.
	if skip:
		match global.cutscene:
			0:
				get_tree().change_scene("res://scenes/title.tscn")
			1:
				get_tree().change_scene("res://scenes/world.tscn")
		
	
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
		25:
			$sprites/shdw_scuttle/anim.play("land")
			$sprites/shdw_roto/anim.play("idle2")
		30:
			$timer.set_wait_time(4.0)
			$sprites/wily.queue_free()
			$sprites/shdw_swoop.queue_free()
			$sprites/shdw_roto.queue_free()
			$sprites/shdw_scuttle.queue_free()
			$sprites/shdw_defend.queue_free()
			set_text()
		31:
			$timer.set_wait_time(1.0)
			set_text()
		67:
			get_tree().change_scene("res://scenes/world.tscn")

func _on_fugue_anim_done(anim_name):
	match anim_name:
		"teleport":
			$sprites/fugue/anim.play("hover")


func _on_scuttle_anim_done(anim_name):
	match anim_name:
		"land":
			$sprites/shdw_scuttle/anim.play("idle2")
		"shrink":
			$timer.set_wait_time(2.0)
			$timer.start()
			$sprites/wily/anim.play("run")
			$sprites/shdw_swoop/anim.play("chase")
			$sprites/shdw_roto/anim.play("chase")
			$sprites/shdw_scuttle/anim.play("chase")
			$sprites/shdw_defend/anim.play("chase")

func _on_wily_anim_done(anim_name):
	match anim_name:
		"scoot":
			$sprites/shdw_scuttle/anim.play("shrink")

func skip():
	$timer.stop()
	$fade/fadeout.interpolate_property($fade/skip_fade, 'modulate', Color(1.0, 1.0, 1.0, 0.0), Color(1.0, 1.0, 1.0, 1.0), 0.125, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$fade/fadeout.start()
	allow_text = false
	skip = true

func _on_rock_anim_done(anim_name):
	match anim_name:
		"transform":
			$sprites/rock/anim.play("fall")
			rock_move = true
		
		"lilstep":
			$sprites/rock/anim.play("run")
			rock_xspd = ROCK_RSPD
		
		"leave":
			sub_scene += 1
