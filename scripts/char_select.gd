extends Node2D

var menu = 0
var new_menu = 0

var rotate = false
var rot_dir = -1
var radius
var down
var rotate_dur = 0.5
var dist = Vector2(60, 10)
var chars = []
var orbit_ang_offset = 0

var max_text = 0

var selected = false

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
	set_anim(menu)
	
	radius = Vector2.ONE * dist
	down = Vector2(0, 1).angle()
	
	for child in $mid/rotate.get_children():
		if child.is_in_group("rotate"):
			chars.append(child)
	
	init_pos()

func _input(event):
	
	if Input.is_action_just_pressed("left"):
		rot_dir = 1
		menu -= 1
		rotate = true
	elif Input.is_action_just_pressed("right"):
		rot_dir = -1
		menu += 1
		rotate = true
	
	if Input.is_action_just_pressed("jump"):
		rotate = false
	
	if menu < 0:
		menu = 2
	elif menu > 2:
		menu = 0

func _process(delta):
	
	if menu != new_menu:
		set_anim(menu)
		new_menu = menu
	
	if $front/info.visible_characters < $front/info.get_total_character_count():
		$front/info.visible_characters += 1
		
	update_chars(delta)

func update_chars(delta):
	
	if rotate:
		radius = Vector2.ONE * dist
		
		orbit_ang_offset += (2 * rot_dir) * PI * delta / float(rotate_dur)
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
		$back/char_portraits.frame = select
		$front/info.visible_characters = 0
		$front/name.set_text(info_a[select])
		$front/info.set_text(info_b[select])
	
func init_pos():
	for i in chars.size():
		var spacing = 2 * PI / float(chars.size())
		var new_position = Vector2()
		new_position.x = cos(spacing * i + down) * radius.x
		new_position.y = sin(spacing * i + down) * radius.y
		chars[i].position = new_position
