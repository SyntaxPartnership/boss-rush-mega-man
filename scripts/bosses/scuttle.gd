extends KinematicBody2D

onready var world = get_parent().get_parent()
onready var player = world.get_child(2)
onready var camera = player.get_child(9)

var id = 4
const CHOKE = 3

const GRAVITY = 900
const JUMP_STR = -400

var intro = true
var intro_bnce = 0
var bounce = 0
var p_intro = false
var intro_delay = 40
var fill_bar = true
var spin_spawn = false
var spinner
var sic_em = 0
var dist = 0
var spr_delay = 5
var force_spin = 0
var desp = false
var desp_dir = 0
var desp_spd = 1
var spark = false
var spk_delay = 0
var spit_spk = 0
var desp_bounce = 0
var air_toss = false
var gaby_air = false
var mssl_toss = false

var velocity = Vector2()
var left_bar = 0
var right_bar = 0

var state = 0
var prev_st = 0
var st_count = 0
var jumps = 0
var jump = false
var act_delay = -1
var x_spd = 0
var pull = 0
var tosses = 3
var pull_delay = -1

var flash = 0
var flash_delay = 0
var hit = false
var touch = false

var kicked = false

var damage = 40

var overlap = []

func _ready():
	
	world.reset_bolt_calc(false)
	
	$anim.play("spin")
	
	left_bar = camera.limit_left + 44
	right_bar = camera.limit_right - 44
	
	global_position.x = camera.limit_left + 128
	global_position.y = camera.limit_top + 69
	
	velocity.y = -200
	velocity.x = -95

func _physics_process(delta):
	
	sic_em = floor(global_position.y - player.global_position.y)
	dist = global_position.distance_to(player.global_position)
	
	$flash_b.frame = $sprite.frame
	$flash_b.flip_h = $sprite.flip_h
	
	if kicked and !player.s_kick:
		kicked = false
	
	if spark:
		if !$sprk_anim.is_playing():
			$spark.show()
			$sprk_anim.play("spark")
		
		spk_delay += 1
		spit_spk += 1
		
		if spk_delay > 1:
			match $flash_b.is_visible():
				true:
					$flash_b.hide()
				false:
					$flash_b.show()
			spk_delay = 0
		
		if spit_spk == 30:
			world.sound('spark')
			var sm_spark = load("res://scenes/bosses/sm_spark.tscn").instance()
			sm_spark.position = global_position
			sm_spark.velocity.x = rand_range(-50, 50)
			world.get_child(3).add_child(sm_spark)
			spit_spk = 0
	else:
		if $flash_b.is_visible():
			$flash_b.hide()
	
	if p_intro:
		intro_delay -= 1
		
		if intro_delay == 0:
			$anim.play("intro")
	
	if act_delay > -1 and is_on_floor():
		if state == 1 or state == 6 or state == 8 or state == 9 or state == 14 or state == 15:
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
			
		
	if flash > 0:
		flash_delay += 1
		flash -= 1
		
		if flash_delay > 3:
			flash_delay = 0
		
		if flash_delay == 1:
			$sprite.hide()
			$flash.show()
		
		if flash_delay == 3:
			$sprite.show()
			$flash.hide()
	
	if flash == 0 and hit:
		hit = false
		$sprite.show()
		$flash.hide()
		flash_delay = 0
	
	
	velocity.y += GRAVITY * delta
	
	velocity = move_and_slide(velocity, Vector2(0, -1))
	
	if intro:
		if !is_on_floor() and intro_bnce == 1:
			if velocity.y < 0:
				world.sound('boing')
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
				
	#Desperation
	if world.boss_hp <= 140 and !desp:
		if state == 1 or state == 10:
			act_delay = 10
			state = 15
			force_spin = 0
			desp = true
	
	if !fill_bar:
		match state:
			0:
				$hitbox/stand.set_deferred('disabled', false)
				$hitbox/squat.set_deferred('disabled', true)
				$hitbox/boing.set_deferred('disabled', true)
				act_delay = 8
				jumps = floor(rand_range(2, 4))
				state += 1
			1:
				if act_delay == 0:
					$anim.play("land")
					state += 1
			3:
				if velocity.y > 0:
					world.sound('throw')
					if !air_toss:
						$anim.play("air-toss")
						air_toss = true
					state += 1
			4:
				if is_on_floor():
					velocity.x = 0
					$anim.play("land")
					air_toss = false
					gaby_air = false
					state += 1
			6:
				if act_delay == 0:
					if tosses > 0:
						world.sound('pull')
						$anim.play("pull")
						state += 1
					else:
						#Add function for desperation attack.
						state = 11
						tosses = 3
			7:
				if $sprite.frame == 10:
					pull = round(rand_range(1, 3))
					var gaby = load("res://scenes/bosses/gabyaoll.tscn").instance()
					gaby.position.y = global_position.y + -6
					if global_position.x > camera.limit_left + 128:
						gaby.position.x = global_position.x + 15
						gaby.dir = -1
					else:
						gaby.position.x = global_position.x + -15
						gaby.dir = 1
						
					#Temp fix until I figure out why missile disappear.
					if pull == 3:
						if !mssl_toss:
							mssl_toss = true
						else:
							pull = 1
					
					gaby.type = pull
					world.get_child(3).add_child(gaby)
					act_delay = 8
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
					act_delay = 8
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
			11:
				id = 0
				force_spin = 0
				$hitbox/stand.set_deferred('disabled', true)
				$hitbox/squat.set_deferred('disabled', false)
				$hitbox/boing.set_deferred('disabled', true)
				$anim.play("shrink")
				mssl_toss = false
				state += 1
			12:
				if $sprite.flip_h:
					if global_position.x < camera.limit_right - 48:
						if !player.is_on_floor():
							$anim.playback_speed = 1
							velocity.x = 60
						else:
							$anim.playback_speed = 2
							velocity.x = 60 * 2
					else:
						id = 4
						velocity.x = 0
						$anim.playback_speed = 1
						$anim.play_backwards("shrink")
						state = 26
				else:
					if global_position.x > camera.limit_left + 48:
						if !player.is_on_floor():
							$anim.playback_speed = 1
							velocity.x = -60
						else:
							$anim.playback_speed = 2
							velocity.x = -60 * 2
					else:
						id = 4
						velocity.x = 0
						$anim.playback_speed = 1
						$anim.play_backwards("shrink")
						state = 26
				if global_position.x <= player.global_position.x + 16 and global_position.x >= player.global_position.x - 16:
					if !player.s_kick:
						world.sound('boing')
						velocity.x = 0
						state += 1
			13:
				id = 4
				spr_delay -= 1
				
				if spr_delay == 0:
					$hitbox/stand.set_deferred('disabled', true)
					$hitbox/squat.set_deferred('disabled', true)
					$hitbox/boing.set_deferred('disabled', false)
					$anim.playback_speed = 1
					$anim.play("spring")
					spr_delay = 5
					act_delay = 40
					state += 1
			14:
				if act_delay == 0:
					state = 0
			15:
				if act_delay == 0:
					$anim.play("land")
					state += 1
			17:
				if velocity.y > 0:
					$anim.play("fall")
					state += 1
			18:
				if is_on_floor():
					velocity.x = 0
					$anim.play("shrink")
					state += 1
			19:
				var get_gaby = get_tree().get_nodes_in_group('gabyoall')
				
				for d in get_gaby:
					var g_dist = d.global_position.x - global_position.x
					if g_dist < 8 and g_dist > -8:
						d.kill_gaby()
				
				if desp_dir == 1 and global_position.x > camera.limit_right - 32:
					world.sound('wall_hit')
					$sprite.flip_h = false
					world.shake = 8
					desp_dir = -1
					desp_bounce += 1
					if desp_spd < 3:
						desp_spd += 0.5
						$anim.playback_speed += 0.25
					if !spark:
						spark = true
				elif desp_dir == -1 and global_position.x < camera.limit_left + 32:
					world.sound('wall_hit')
					$sprite.flip_h = true
					world.shake = 8
					desp_dir = 1
					desp_bounce += 1
					if desp_spd < 3:
						desp_spd += 0.5
						$anim.playback_speed += 0.25
					if !spark:
						spark = true
				
				if desp_bounce == 8:
					state += 1
					velocity.y = -200
					spark = false
					spk_delay = 0
					spit_spk = 0
					$sprk_anim.stop()
					$spark.hide()
					desp_bounce = 0
					desp_spd = 1

				
				velocity.x = (80 * desp_dir) * desp_spd
			
			20:
				if is_on_floor():
					if bounce == 0:
						velocity.x = 0
						velocity.y = 100
						bounce += 1
					elif bounce == 1:
						id = 4
						velocity.y = -200
						world.sound('boing')
						$anim.play("jump")
						state += 1
			21:
				if velocity.y > 0:
					$anim.play("fall")
					state += 1
			22:
				if is_on_floor():
					$anim.play("land")
					state += 1
			24:
				if is_on_floor():
					velocity.x = 0
					play_anim('land')
					state += 1
				
	
	#Kill boss.
	if world.boss_hp <= 0:
		world.kill_music()
		world.sound("death")
		world.bolt_calc()
		
		for _b in range(world.max_bolts):
			var which = rand_range(0, 100)
			var spawn
			if which <= world.accuracy:
				spawn = load("res://scenes/objects/bolt_l.tscn").instance()
				spawn.type = 1
			else:
				spawn = load("res://scenes/objects/bolt_s.tscn").instance()
				spawn.type = 0
			spawn.global_position = global_position
			spawn.time = 420
			spawn.velocity.y = rand_range(0, spawn.JUMP_SPEED * 1.2)
			spawn.x_spd = rand_range(-100, 100)
			world.get_child(1).add_child(spawn)
				
		var enemy_kill = get_tree().get_nodes_in_group('gabyoall')
		for i in enemy_kill:
			var boom = load("res://scenes/effects/l_explode.tscn").instance()
			boom.global_position = i.global_position
			world.get_child(3).add_child(boom)
			i.queue_free()
		world.enemy_count = 0
		var kill_wall = get_tree().get_nodes_in_group('wall')
		for w in kill_wall:
			w.queue_free()
			w.queue_free()
		for n in range(16):
			var boom = world.DEATH_BOOM.instance()
			boom.global_position = global_position
			boom.id = n
			world.get_child(3).add_child(boom)
		queue_free()
	
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
	
	#Object overlap detection
	overlap = $hitbox.get_overlapping_bodies()
	
	if overlap != []:
		for body in overlap:
			if body.is_in_group("player"):
				if !player.s_kick:
					world.calc_damage(body, self)
				else:
					if state == 12:
						id = 4
						play_anim('fall')
						$anim.playback_speed = 1
						velocity.y = -300
						if !player.get_child(3).flip_h:
							velocity.x = 200
						else:
							velocity.x = -200
						state = 24
						
					world.calc_damage(self, body)
			if body.is_in_group("weapons"):
				world.calc_damage(self, body)
	
	if $sprite.frame == 28:
		if !gaby_air:
			var gaby = load("res://scenes/bosses/gabyaoll.tscn").instance()
			gaby.position.y = global_position.y + -6
			if !$sprite.flip_h:
				gaby.position.x = global_position.x + 15
			else:
				gaby.position.x = global_position.x + -15
			gaby.move = true
			gaby.type = 1
			gaby.drop = true
			gaby.velocity.y = -100
			world.get_child(3).add_child(gaby)
			gaby_air = true
		

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
					world.sound('boing')
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
					act_delay = 8
					if jumps > -1:
						state = 1
					else:
						state += 1
						act_delay = 8
				16:
					world.sound('boing')
					$anim.play("jump")
					velocity.y = JUMP_STR * 0.75
					state += 1
				19:
					$anim.play("shrink")
					state += 1
				23:
					id = 4
					state = 0
					$anim.play("idle")
				25:
					state = 0
					$anim.play("idle")
		"shrink":
			match state:
				12:
					$anim.play("spin")
				19:
					id = 0
					$hitbox/stand.set_deferred('disabled', true)
					$hitbox/squat.set_deferred('disabled', false)
					$hitbox/boing.set_deferred('disabled', true)
					if global_position.x >= camera.limit_left + 128:
						desp_dir = 1
					else:
						$sprite.flip_h = true
						desp_dir = -1
					$anim.play("spin")
				26:
					state = 0
					$anim.play("idle")
		
		"air-toss":
			$anim.play("fall")
