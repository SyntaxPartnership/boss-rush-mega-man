extends KinematicBody2D

onready var world = get_parent().get_parent()
onready var camera = world.get_child(2).get_child(9)
onready var player = world.get_child(2)

const SPEED = 75

var radius = Vector2.ONE * 0.5
var rotation_duration = 1.0
var offset = 0

var intro_tele = 0
var intro = true
var intro_delay = 30
var fill_bar = false

var state = 0
var act_timer = 240
var action = 0
var act_count = 0
var side = 0

var bomb_drop = 0
var bomb_max = 2
var c_bomb = false
var carpet_bmb = 0
var toss = false

var velocity = Vector2()

func _ready():
	
	#Set position and starting animation.
	global_position.x = camera.limit_left + 40
	global_position.y = camera.limit_top + 128
	
	$anim.play("teleport")

func _physics_process(delta):
	
	#Play the into dance and fill the boss meter.
	if fill_bar:
		if intro_delay > 0:
			intro_delay -= 1
		
		if intro_delay == 1:
			$anim.play("intro")
	
	#Decrease the action timer.
	if !fill_bar and !intro:
		act_timer -= 1
	
	#When the timer expires, choose an action
		if act_timer == 0:
			if world.boss_hp > 200:
				action = rand_range(0, 1)
			else:
				action = rand_range(0, 2)
			action = round(action)
			if action == 0:
				velocity.x = 0
				state = 2
				$anim.play_backwards("teleport")
			if action == 1:
				velocity.x = 0
				state = 3
				$anim.play_backwards("teleport")
			if action == 2:
				velocity.x = 0
				state = 5
				$anim.play_backwards("teleport")
	
	if state == 1:
		#Hover function
		offset += 2 * PI * delta / float(rotation_duration)
		offset = wrapf(offset, -PI, PI)
		var new_pos = Vector2()
		new_pos.y = sin(offset) * radius.y
		global_position += new_pos
		
		#Set Roto's speed.
		if !fill_bar and !intro:
			if player.global_position <= global_position and velocity.x > -SPEED:
				velocity.x -= 5
			if player.global_position > global_position and velocity.x < SPEED:
				velocity.x += 5
	
	if state == 5:
		
		if c_bomb:
			carpet_bmb += 1
		
		if carpet_bmb == 8:
			var bomb = load('res://scenes/bosses/roto_bomb.tscn').instance()
			bomb.global_position = global_position
			world.get_child(1).add_child(bomb)
			carpet_bmb = 0
		
		if act_count == 2 and global_position.x < camera.limit_left + 128:
			velocity.x = 100
		elif act_count == 2 and global_position.x >= camera.limit_left + 128:
			velocity.x = 0
			act_count += 1
			$anim.play_backwards("teleport")
			c_bomb = false
			carpet_bmb = 0
		
		if act_count == 5 and global_position.x > camera.limit_left + 128:
			velocity.x = -100
		elif act_count == 5 and global_position.x <= camera.limit_left + 128:
			velocity.x = 0
			act_count += 1
			$anim.play_backwards("teleport")
			c_bomb = false
			carpet_bmb = 0
	
	velocity = move_and_slide(velocity, Vector2(0, -1))
		
	if state == 3:
		if is_on_floor():
			if side == 0:
				velocity.x = 250
			else:
				velocity.x = -250
		
		if is_on_wall():
			velocity.x = 0
			velocity.y = -300
		
		if velocity.y < 0 and global_position.y < camera.limit_top + 64:
			velocity.y = 0
			$anim.play_backwards("teleport")
			state = 4
	
	if $anim.get_current_animation() == "drop1" and $sprite.get_frame() == 18 and !toss:
		var bomb = load('res://scenes/bosses/roto_bomb.tscn').instance()
		bomb.global_position = global_position
		bomb.velocity.y = -200
		world.get_child(1).add_child(bomb)
		toss = true
	
	#Increase Bomb Drops as Roto takes damage.
	if world.boss_hp <= 210 and bomb_max < 4:
		bomb_max = 4

	if world.boss_hp <= 140 and bomb_max != 6:
		bomb_max = 6

func _on_anim_finished(anim_name):
	
	if anim_name == "teleport":
		if intro:
			match intro_tele:
				0:
					$anim.play_backwards("teleport")
					intro_tele += 1
				1:
					global_position.x = camera.limit_left + 40
					global_position.y = camera.limit_top + 64
					$anim.play("teleport")
					intro_tele += 1
				2:
					$anim.play_backwards("teleport")
					intro_tele += 1
				3:
					global_position.x = camera.limit_left + 128
					global_position.y = camera.limit_top + 136
					$anim.play("teleport")
					intro_tele += 1
				4:
					$anim.play_backwards("teleport")
					intro_tele += 1
				5:
					global_position.x = camera.limit_right - 40
					global_position.y = camera.limit_top + 64
					$anim.play("teleport")
					intro_tele += 1
				6:
					$anim.play_backwards("teleport")
					intro_tele += 1
				7:
					global_position.x = camera.limit_right - 40
					global_position.y = camera.limit_top + 136
					$anim.play("teleport")
					intro_tele += 1
				8:
					$anim.play("idle")
					fill_bar = true
					state = 1
		
		if state == 2:
			match act_count:
				0:
					global_position.x = player.global_position.x
					global_position.y = camera.limit_top + 136
					$anim.play("teleport")
					act_count += 1
				1:
					$anim.play("drop1")
		
		if state == 3:
			match act_count:
				0:
					side = rand_range(0, 1)
					side = round(side)
					if side == 0:
						global_position.x = camera.limit_left + 32
						global_position.y = camera.limit_top + 64
						$anim.play("teleport")
						act_count += 1
					else:
						global_position.x = camera.limit_right - 32
						global_position.y = camera.limit_top + 64
						$anim.play("teleport")
						act_count += 1
				1:
					$anim.play("spin-fast")
					velocity.y = 300
					act_count = 0
		
		if state == 4:
			match act_count:
				0:
					global_position.x = player.global_position.x
					global_position.y = camera.limit_top + 136
					$anim.play("teleport")
					act_count += 1
				1:
					$anim.play("spin-norm")
					state = 1
					act_count = 0
					act_timer = 240
		
		if state == 5:
			match act_count:
				0:
					global_position.x = camera.limit_left + 24
					global_position.y = camera.limit_top + 136
					$anim.play("teleport")
					act_count += 1
				1:
					$anim.play("spin-fast")
					c_bomb = true
					act_count += 1
				3:
					global_position.x = camera.limit_right - 24
					global_position.y = camera.limit_top + 136
					$anim.play("teleport")
					act_count += 1
				4:
					$anim.play("spin-fast")
					c_bomb = true
					act_count += 1
				6:
					global_position.x = player.global_position.x
					global_position.y = camera.limit_top + 136
					$anim.play("teleport")
					act_count += 1
				7:
					$anim.play("spin-norm")
					state = 1
					act_count = 0
					act_timer = 240
	
	if anim_name == "drop1":
		if bomb_drop < bomb_max:
			$anim.play_backwards("teleport")
			bomb_drop += 1
		else:
			$anim.play("spin-norm")
			state = 1
			bomb_drop -= bomb_max
			act_timer = 240
		toss = false
		act_count = 0
	
	if anim_name == "intro":
		world.fill_b_meter = true

func play_anim(anim):
	$anim.play(anim)
