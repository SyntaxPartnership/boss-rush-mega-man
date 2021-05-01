extends Node2D

var allow_ctrl = false

var menu = 0
var new_menu = 0

var rotate = true
var rot_dir = 1
var radius
var down
var rotate_dur = 0.4
var dist = Vector2(60, 10)
var chars = []
var orbit_ang_offset = 0

var max_text = 0

var selected = false
var move = false

var info_a = {
	0 : "\nMEGAMAN\nDLN-001",
	1 : "\nPROTOMAN\nDLN-000",
	2 : "\nBASS\nSWN-001",
}

var info_b = {
	0 : "LAB\nASSISTANT\nTURNED\nHERO.",
	1 : "ORIGINAL\nROBOT\nMASTER\nPROTOTYPE.",
	2 : "SELF\nPROCLAIMED\nSTRONGEST\nROBOT."
}

func _ready():
	set_anim(3)
	
	radius = Vector2.ONE * dist
	down = Vector2(0, 1).angle()
	
	for child in $mid/rotate.get_children():
		if child.is_in_group("rotate"):
			chars.append(child)

func _input(event):
	
	if allow_ctrl:
		if Input.is_action_just_pressed("left"):
			rot_dir = 1
			menu -= 1
			set_anim(3)
			
			audio.play_sound("cursor")
			rotate = true
			allow_ctrl = false
		elif Input.is_action_just_pressed("right"):
			rot_dir = -1
			menu += 1
			set_anim(3)
			
			audio.play_sound("cursor")
			rotate = true
			allow_ctrl = false
		
		if Input.is_action_just_pressed("jump"):
			selected = true
			set_anim(menu)
			audio.play_sound("bling")
			allow_ctrl = false
	
	if menu < 0:
		menu = 2
	elif menu > 2:
		menu = 0

func _process(delta):
	
	if allow_ctrl:
		if $mid/info.visible_characters < $mid/info.get_total_character_count():
			$mid/info.visible_characters += 1
	
	if rotate:
		for c in get_tree().get_nodes_in_group("rotate"):
			var scaling = (((c.position.y - 10) + 1) * 3)
			scaling = scaling / 100
			if scaling > 0:
				scaling = 0
			c.scale.x = 1 + scaling
			c.scale.y = 1 + scaling

			if c.position.y > 0:
				c.raise()
	
	if !selected:
		update_chars(delta)
	else:
		if move:
			for m in get_tree().get_nodes_in_group("rotate"):
				m.position.y -= 8
				if m.position.y < -256:
					audio.stop_music("menu")
					global.player_id[0] = menu
					global.cutscene = 1 + global.player_id[0] #CHANGE FOR ADDITIONAL CHARACTERS
					get_tree().change_scene("res://scenes/cutscene.tscn")

func update_chars(delta):
	
	if rotate:
		radius = Vector2.ONE * dist

		orbit_ang_offset += rot_dir * PI * delta / float(rotate_dur)
		orbit_ang_offset = wrapf(orbit_ang_offset, -PI, PI)

		if chars.size() != 0:
			for i in chars.size():
				var spacing = 2 * PI / float(chars.size())
				var new_position = Vector2()
				new_position.x = cos(spacing * i + orbit_ang_offset) * radius.x
				new_position.y = sin(spacing * i + orbit_ang_offset) * radius.y

				#FUCK THIS CHUNK OF CODE ESPECIALLY

				if i == menu:
					if new_position.angle() > 1.1 and new_position.angle() < 1.9:
						new_position.x = cos(down) * radius.x
						new_position.y = sin(down) * radius.y
						chars[i].position = new_position
						
						if !allow_ctrl and !selected:
							for h in get_tree().get_nodes_in_group("rotate"):
								if !h.is_visible():
									h.show()
									$back/char_portraits.show()
									$back/char_info.show()
									$mid/name.show()
							
							allow_ctrl = true
						
						set_anim(menu)
						
						rotate = false

				chars[i].position = new_position
				

func set_anim(select):
	if !selected:
		match select:
			0:
				$mid/rotate/anim.play("rock-run")
			1:
				$mid/rotate/anim.play("blues-run")
			2:
				$mid/rotate/anim.play("forte-run")
			3:
				$mid/rotate/anim.play("all-idle")
		if select != 3:
			$back/char_portraits.frame = select
			$back/char_info.frame = select
			$mid/info.visible_characters = 0
			$mid/name.set_text(info_a[select])
			$mid/info.set_text(info_b[select])
	else:
		match select:
			0:
				$mid/rotate/anim.play("rock-select")
			1:
				$mid/rotate/anim.play("blues-select")
			2:
				$mid/rotate/anim.play("forte-select")
		$tween.interpolate_property($mid/fakefade, "modulate", Color(0.0, 0.0, 0.0, 0.0), Color(0.0, 0.0, 0.0, 1.0), 0.125, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		$tween.start()

func _on_anim__finished(anim_name):
	var c_name
	match menu:
		0:
			c_name = "rock-"
		1:
			c_name = "blues-"
		2:
			c_name = "forte-"
	if anim_name == c_name+"select":
		audio.play_sound("beamout")
		$mid/rotate/anim.play(c_name+"beam")
	if anim_name == c_name+"beam":
		move = true
