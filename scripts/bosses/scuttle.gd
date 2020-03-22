extends KinematicBody2D

onready var world = get_parent().get_parent()
onready var player = world.get_child(2)
onready var camera = player.get_child(9)

const GRAVITY = 900
const JUMP_STR = -400

var intro = true
var intro_bnce = 0
var p_intro = false
var intro_delay = 40
var fill_bar = true
var spin_spawn = false
var spinner

var velocity = Vector2()
var left_bar = 0
var right_bar = 0

var state = 0
var prev_st = 0
var st_count = 0
var jumps = 0
var jump = false
var act_delay = 5
var x_spd = 0
var pull = 0
var tosses = 3
var pull_delay = -1

func _ready():
	$anim.play("spin")
	
	left_bar = camera.limit_left + 44
	right_bar = camera.limit_right - 44
	
	global_position.x = camera.limit_left + 128
	global_position.y = camera.limit_top + 69
	
	velocity.y = -200
	velocity.x = -95

func _physics_process(delta):
	
	if p_intro:
		intro_delay -= 1
		
		if intro_delay == 0:
			$anim.play("intro")
	
	if act_delay > -1 and is_on_floor():
		if state == 1 or state == 6 or state == 8 or state == 9:
			act_delay -= 1
	
	if pull_delay > -1 and state == 10:
		pull_delay -= 1
	
	if prev_st != state:
		if state == 1 or state == 2 or state == 5:
			if jumps > 0:
				if player.global_position.x < global_position.x:
					$sprite.flip_h = false
				else:
					$sprite.flip_h = true
			
		if state == 6 or state == 7:
			if player.global_position.x < global_position.x:
				$sprite.flip_h = false
			else:
				$sprite.flip_h = true
			
			prev_st = state
	
	velocity.y += GRAVITY * delta
	
	velocity = move_and_slide(velocity, Vector2(0, -1))
	
	if intro:
		if !is_on_floor() and intro_bnce == 1:
			if velocity.y < 0:
				$anim.play("jump")
			else:
				$anim.play("fall")
		
		if is_on_floor():
			velocity.x = 0
			match intro_bnce:
				0:
					velocity.y = -200
					$sprite.flip_h = true
					intro_bnce += 1
			
			if $anim.get_current_animation() == "fall" and intro_bnce == 1:
				$anim.play("land")
				intro_bnce += 1
	
	if !fill_bar:
		match state:
			0:
				act_delay = 5
				jumps = floor(rand_range(2, 4))
				state += 1
			1:
				if act_delay == 0:
					$anim.play("land")
					state += 1
			3:
				if velocity.y > 0:
					$anim.play("fall")
					state += 1
			4:
				if is_on_floor():
					velocity.x = 0
					$anim.play("land")
					state += 1
			6:
				if act_delay == 0:
					if tosses > 0:
						$anim.play("pull")
						state += 1
					else:
						state = 0
						tosses = 3
			7:
				if $sprite.frame == 10:
					pull = round(rand_range(1, 3))
					print(pull)
					var gaby = load("res://scenes/bosses/gabyaoll.tscn").instance()
					gaby.position.y = global_position.y + -6
					if global_position.x > camera.limit_left + 128:
						gaby.position.x = global_position.x + 15
						gaby.dir = -1
					else:
						gaby.position.x = global_position.x + -15
						gaby.dir = 1
					gaby.type = pull
					world.get_child(3).add_child(gaby)
					act_delay = 5
					state += 1
					tosses -= 1
			8:
				if act_delay == 0:
					for i in get_tree().get_nodes_in_group("gabyoall"):
						if !i.move:
							i.position.x = global_position.x
							i.position.y = global_position.y + 12
							i.move = true
					
					$anim.play("toss")
					act_delay = 5
					pull_delay = 90
					state += 1
			9:
				if act_delay == 0:
					$anim.play("idle")
					state += 1
			10:
				if pull_delay == 0:
					act_delay = 1
					state = 6
		
		
	
	#Animations.
	if $anim.get_current_animation() == "intro":
		match $sprite.frame:
			2:
				if intro_bnce == 2:
					var spin = load("res://scenes/bosses/spin.tscn").instance()
					spinner = spin
					spin.position.x = global_position.x + 12
					spin.position.y = global_position.y - 16
					world.get_child(3).add_child(spin)
					intro_bnce += 1
			3:
				spinner.get_child(0).offset.y = -1
			4:
				spinner.get_child(0).offset.y = 0
	
	#Kill the intro spinner.
	if spinner != null:
		if spinner.global_position.x < left_bar - 16:
			spinner.kill()
			spinner = null
			world.fill_b_meter = true

func play_anim(anim):
	$anim.play(anim)

func _on_anim_finished(anim_name):
	
	match anim_name:
		"intro":
			spinner.velocity = Vector2(-90, -310)
			spinner.set_grav = true
		
		"land":
			if intro:
				$anim.play("idle")
				p_intro = true
				intro = false
			
			match state:
				2:
					$anim.play("jump")
					if jumps > 0:
						velocity.y = JUMP_STR
					else:
						velocity.y = JUMP_STR * 1.15
					
					if jumps > 0:
						x_spd = lerp(0, position.distance_to(player.position), 1)
						if player.global_position.x < global_position.x:
							x_spd = -x_spd
					else:
						if global_position.x >= camera.limit_left + 128:
							x_spd = -lerp(0, position.distance_to(Vector2(left_bar, camera.limit_bottom - 40)), 1)
						else:
							x_spd = lerp(0, position.distance_to(Vector2(right_bar, camera.limit_bottom - 40)), 1)
						
					velocity.x = x_spd
					state += 1
					jumps -= 1
				5:
					$anim.play("idle")
					act_delay = 5
					if jumps > -1:
						state = 1
					else:
						state += 1
						act_delay = 5
