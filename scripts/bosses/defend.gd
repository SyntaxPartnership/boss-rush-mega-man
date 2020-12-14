extends KinematicBody2D

onready var world = get_parent().get_parent()
onready var player = world.get_child(2)
onready var camera = player.get_child(9)

var id = 5
const CHOKE = 3

var damage = 30
var flash = 0
var flash_delay = 0
var hit = false
var touch = false

const GRAVITY = 700
const JUMP_STR = -250

var intro = true
var fill_bar = true

var state = 0
var spr_offset = Vector2()
var spr_shake = 0
var thrusters = false
var thr_strt = -1
var thr_frame = 0
var thr_delay = 0
var thr_state = -1

var turns = 0
var x_target = 0
var hits = 0
var desp = false
var desp_fin = false
var desp_delay = 30
var big_bullet
var drop_down = 0
var drop_delay = 60
var shot_delay = 60
var shot_step = 0
var shots = 2
var slap_delay = 40
var slap_pos = 0
var charge = false
var set_box = false
var hit_overlap = []
var shld_overlap = []
var plyr_overlap = []
var bnce_states = [0, 1, 2, 3, 10]
var shld_touch = false

var velocity = Vector2()

var thrst_data = {
	5 : [0, 0, Vector2(0, 22)],
	6 : [1, 0, Vector2(1, 22)],
	7 : [2, 0, Vector2(1, 22)],
	8 : [3, 0, Vector2(1, 22)],
	9 : [4, 0, Vector2(1, 22)],
	10 : [5, 4, Vector2(-19, 2)],
	12 : [6, 2, Vector2(1, 22)],
	16 : [7, 0, Vector2(-2, 22)],
	17 : [8, 6, Vector2(-1, 22)],
	19 : [9, 6, Vector2(-1, 22)],
	21 : [5, 4, Vector2(-19, 2)],
	22 : [5, 4, Vector2(-19, 2)]
}

var shld_data = {
	5 : [false, true, true],
	6 : [false, true, true],
	7 : [false, true, true],
	11 : [false, true, true],
	12 : [false, true, true],
	15 : [false, true, true],
	16 : [false, true, true],
	20 : [false, true, true],
	8 : [true, false, false],
	9 : [true, false, false],
	10 : [true, false, false],
	13 : [true, false, false],
	14 : [true, false, false],
	17 : [true, false, false],
	18 : [true, false, false],
	19 : [true, false, false],
	21 : [true, false, false],
	22 : [true, false, false]
}

func _ready():
	world.reset_bolt_calc(false)
	
	$anim.play("fade_in")
	
	$sprite.flip_h = true
	
	turns = round(rand_range(2, 5))
	

func _physics_process(delta):
	
	if state == 5 or state == 6:
		drop_delay -= 1
	
	if state == 18 or state == 21 or state == 22 or state == 24:
		desp_delay -= 1
	
	match state:
		1:
			if turns > 0:
				if $sprite.flip_h and global_position.x < camera.limit_right - 72:
					velocity.x = 200
				elif $sprite.flip_h and global_position.x >= camera.limit_right - 72:
					if velocity.x > 0:
						velocity.x -= 10
					else:
						$anim.play("turn_1")
						turns -= 1
						state = 2
				elif !$sprite.flip_h and global_position.x > camera.limit_left + 72:
					velocity.x = -200
				elif !$sprite.flip_h and global_position.x <= camera.limit_left + 72:
					if velocity.x < 0:
						velocity.x += 10
					else:
						$anim.play("turn_1")
						turns -= 1
						state = 2
			else:
				if $sprite.flip_h:
					velocity.x = 300
				else:
					velocity.x = -300
				
				if is_on_wall():
					world.sound("wall_hit")
					world.shake = 12
					stun_plyr()
					$anim.play("recoil")
					if $sprite.flip_h:
						velocity.x = -50
					else:
						velocity.x = 50
					velocity.y = -200
					state = 30
		
		3:
			if $sprite.flip_h:
				if turns > 0:
					if velocity.x < 200:
						velocity.x += 20
				else:
					if velocity.x < 300:
						velocity.x += 30
			else:
				if turns > 0:
					if velocity.x > -200:
						velocity.x -= 20
				else:
					if velocity.x > -300:
						velocity.x -= 30
			
			if turns > 0:
				if velocity.x == -200 or velocity.x == 200:
					state = 1
			else:
				if velocity.x == -300 or velocity.x == 300:
					state = 1
				
		4:
			if global_position.y > camera.limit_bottom - 104:
				velocity.y -= GRAVITY * delta
			else:
				velocity = Vector2(0, 0)
				state = 5
				
		5:
			if player.global_position.x < global_position.x and $sprite.flip_h or player.global_position.x > global_position.x and !$sprite.flip_h:
				$anim.play("turn_2")
				state = 6
			
			if drop_delay <= 0:
				$anim.play("open")
				drop_delay = 60
				state = 7
		
		8:
			velocity.y += GRAVITY * delta
			
			if velocity.y > 0 and $anim.get_current_animation() == "rise":
				world.sound('fall')
				$anim.play("fall")
			
			if is_on_floor() and state == 8:
				#If the player is on the floor and not displaying iframes, stun them.
				stun_plyr()
				
				world.shake = 12
				world.kill_se('fall')
				world.sound("wall_hit")
				state = 9
		
		9:
			slap_delay -= 1
			
			if slap_delay == 0:
				$anim.play("up_floor")
				state = 11
		
		10:
			shot_delay -= 1
			
			if shot_delay == 0:
				if shots > 0:
					if shot_step == 0:
						if shots > 1:
							world.sound('def_bullet')
							var slow = load("res://scenes/bosses/def_bullet.tscn").instance()
							slow.type = 0
							if $sprite.flip_h:
								slow.velocity = Vector2(1, 0)
								slow.position.x = global_position.x + 3
							else:
								slow.velocity = Vector2(-1, 0)
								slow.position.x = global_position.x - 3
							slow.position.y = global_position.y + 8
							slow.speed = 100
							world.get_child(1).add_child(slow)
						else:
							world.sound('def_bullet')
							var fast = load("res://scenes/bosses/def_bullet.tscn").instance()
							fast.type = 1
							if $sprite.flip_h:
								fast.velocity = Vector2(1, 0)
								fast.position.x = global_position.x + 3
							else:
								fast.velocity = Vector2(-1, 0)
								fast.position.x = global_position.x - 3
							fast.position.y = global_position.y + 8
							fast.speed = 250
							world.get_child(1).add_child(fast)
						$anim.play("open")
						shot_step += 1
						shot_delay = 15
						shots -= 1
					else:
						$anim.play("close")
						shot_step -= 1
						shot_delay = 35
			
			var bullets = get_tree().get_nodes_in_group('def_bullet')
			
			if bullets == [] and shot_step == 1:
				$anim.play("close")
				turns = round(rand_range(2, 5))
				shot_delay = 60
				shot_step = 0
				shots = 2
				state = 0
		
		12:
			slap_delay = 15
			if global_position.y > camera.limit_bottom - 56:
				global_position.y -= 1
			elif global_position.y < camera.limit_bottom - 56:
				global_position.y = camera.limit_bottom - 56
			else:
				if player.global_position.x < global_position.x and $sprite.flip_h or player.global_position.x > global_position.x and !$sprite.flip_h:
					$anim.play("turn_2")
					state = 13
				else:
					state = 14

		14:
			slap_delay -= 1

			if slap_delay == 0:
				slap_pos = player.global_position.x
				if player.stun > 0:
					$anim.play("fly")
					charge = true
				else:
					if global_position.x > camera.limit_left + 128 and $sprite.flip_h or global_position.x < camera.limit_left + 128 and !$sprite.flip_h:
						$anim.play("turn_2")
						turns = round(rand_range(2, 5))
						state = 17
					else:
						turns = round(rand_range(2, 5))
						slap_delay = 40
						$anim.play("fly")
						state = 3
			
			if charge:
				if $sprite.flip_h:
					if (slap_pos - global_position.x) > 32:
						velocity.x = 200
					else:
						if velocity.x > 25:
							velocity.x -= 25
						else:
							velocity.x = 25
							$anim.play("slap")
							state = 15
				else:
					if (slap_pos - global_position.x) < -32:
						velocity.x = -200
					else:
						if velocity.x < -25:
							velocity.x += 25
						else:
							velocity.x = -25
							$anim.play("slap")
							state = 15
							
		15:
			
			if charge and $sprite.frame == 17:
				if player.stun > 0:
					world.sound("clang")
					player.slap = true
					player.anim_state(player.TOSSED)
					var angle
					if $sprite.flip_h:
						angle = Vector2(1, 0).angle() - (PI / 8)
					else:
						angle = Vector2(-1, 0).angle() + (PI / 8)
					angle = wrapf(angle, -PI, PI)
					player.slap_vel = Vector2(cos(angle), sin(angle)) * 300
				charge = false
				state = 16
		
		16:
			slap_delay -= 1
			
			if slap_delay == 0:
				turns = round(rand_range(2, 5))
				slap_delay = 40
				$anim.play("close")
				state = 17
		
		18:
			if desp_delay == 0:
				$anim.play("close")
				state = 19
		
		20:
			if global_position.y > camera.limit_top + 64:
				velocity.y -= GRAVITY * delta
			else:
				global_position.y = camera.limit_top + 64
				velocity = Vector2.ZERO
				$anim.play("desp")
				$coll_box_a.set_deferred("disabled", true)
				$coll_box_b.set_deferred("disabled", false)
				desp_delay = 20
				state = 21
		
		21:
			if desp_delay == 0:
				$sprite.offset.y = -2
				desp_delay = 5
				world.sound('def_bullet')
				var bullet = load("res://scenes/bosses/def_bullet.tscn").instance()
				bullet.type = 3
				bullet.speed = 100
				bullet.master_vel = (player.global_position - global_position).normalized()
				bullet.position.x = global_position.x
				bullet.position.y = global_position.y + 8
				world.get_child(1).add_child(bullet)
				big_bullet = get_tree().get_nodes_in_group('def_bullet')
				state = 22
		
		22:
			if desp_delay == 0:
				if $sprite.offset.y != 0:
					$sprite.offset.y = 0
				
			if big_bullet != []:
				global_position.x = big_bullet[0].global_position.x
				
				if global_position.y < camera.limit_top + (64 + (16 * drop_down)):
					global_position.y += 1
		
		23:
			$anim.play("desp_move")
			$sprite.offset.y = 0
			$coll_box_a.set_deferred("disabled", false)
			$coll_box_b.set_deferred("disabled", true)
			desp_delay = 5
			desp_fin = false
			state = 24
		
		24:
			if desp_delay == 0:
				$anim.play("open")
				state = 7
		
		25:
			if $anim.is_playing():
				$anim.stop()
			$coll_box_a.set_deferred("disabled", true)
			$coll_box_b.set_deferred("disabled", false)
			
			if thrusters:
				$thrusters.hide()
				thr_state = -1
				thrusters = false
				
			velocity = Vector2(0, -500)
			
			if is_on_ceiling():
				ceiling_dmg()
		
		26:
			if global_position.y < camera.limit_top + 88:
				velocity.y += GRAVITY * delta
			else:
				$anim.play("hover_1")
				thrusters = true
				state = 27
			
			$coll_box_a.set_deferred("disabled", false)
			$coll_box_b.set_deferred("disabled", true)
			
		27:
			if velocity.y > -200:
				velocity.y -= GRAVITY * delta
			
			if global_position.y <= camera.limit_top + 88:
				velocity = Vector2.ZERO
				state = 28
		
		28:
			$anim.play("open")
			state = 7
		
		30:
			velocity.y += GRAVITY * delta
			
			if is_on_floor():
				$anim.play("hover_1")
				velocity = Vector2.ZERO
				state = 31
		
		31:
			if global_position.y > camera.limit_bottom - 56:
				global_position.y -= 1
			else:
				$anim.play("turn_1")
				state = 32
	
	#Desperation attack.
	if !desp and world.boss_hp <= 140:
		if state == 1 or state == 2 or state == 3:
			velocity = Vector2.ZERO
			state = 18
			$anim.play("open")
			desp_fin = true
			desp = true
	
	#Make the boss shake when her shields clang together.
	if spr_shake > 0:
		spr_offset = Vector2(rand_range(-2, 2), rand_range(-2, 2))
		$sprite.offset = spr_offset
		$thrusters/sprite.offset = $sprite.offset
		spr_shake -= 1
	
	if spr_shake == 0 and spr_offset != Vector2(0, 0):
		spr_offset = Vector2(0, 0)
		$sprite.offset = spr_offset
		$thrusters/sprite.offset = $sprite.offset
	
	#Add sound effect for the clang.
	if $sprite.frame == 8 and spr_shake == 0:
		world.sound("clang")
		spr_shake = 8
		
	#Set shield hitbox.
	if shld_data.has($sprite.frame):
		#Set hitbox positions.
		if $sprite.flip_h != set_box:
			if $sprite.flip_h:
				$shield_box/box.position.x = 8
				$hit_box/box_b.position.x = -8
			else:
				$shield_box/box.position.x = -8
				$hit_box/box_b.position.x = 8
			set_box = $sprite.flip_h
		
		$hit_box/box_a.set_deferred("disabled", shld_data.get($sprite.frame)[0])
		$hit_box/box_b.set_deferred("disabled", shld_data.get($sprite.frame)[1])
		$shield_box/box.set_deferred("disabled", shld_data.get($sprite.frame)[2])
	
	#Display the thruster sprites appropriately.
	#Check sprite frame.
	if thrst_data.has($sprite.frame) and thrusters and $sprite.is_visible_in_tree():
		#If frame is in dict, pull data and set frames.
		if thr_state != thrst_data.get($sprite.frame)[0]:
			if thr_strt != thrst_data.get($sprite.frame)[1]:
				thr_strt = thrst_data.get($sprite.frame)[1]
				$thrusters/sprite.frame = thr_strt
				thr_delay = 0
				thr_frame = 0
			if !$sprite.flip_h:
				$thrusters/sprite.position.x = -thrst_data.get($sprite.frame)[2].x
			else:
				$thrusters/sprite.position.x = thrst_data.get($sprite.frame)[2].x
			$thrusters/sprite.position.y = thrst_data.get($sprite.frame)[2].y
			if $sprite.frame == 10 or $sprite.frame == 19 or $sprite.frame == 21 or $sprite.frame == 22:
				$thrusters/sprite.flip_h = $sprite.flip_h
			else:
				$thrusters/sprite.flip_h = false
			$thrusters.show()
			thr_state = thrst_data.get($sprite.frame)[0]
	elif !thrst_data.has($sprite.frame) and thr_state != -1:
		$thrusters.hide()
		thr_state = -1
	
	#Animate the thrusters.
	if thrusters:
		thr_delay += 1
	
	if thr_delay > 3:
		thr_frame += 1
		
		if thr_frame > 1:
			thr_frame = 0
	
		$thrusters/sprite.frame = thr_strt + thr_frame
		thr_delay = 0
	
	if flash > 0:
		flash_delay += 1
		flash -= 1
		
		if flash_delay > 3:
			flash_delay = 0
		
		if flash_delay == 1:
			$sprite.hide()
			if $thrusters.is_visible_in_tree():
				$thrusters.hide()
			$flash.show()
		
		if flash_delay == 3:
			$flash.hide()
			$sprite.show()
	
	if flash == 0 and hit:
		$flash.hide()
		$sprite.show()
		thr_state = -1
		flash_delay = 0
		hit = false
	
	velocity = move_and_slide(velocity, Vector2(0, -1))
	
	hit_overlap = $hit_box.get_overlapping_bodies()
	shld_overlap = $shield_box.get_overlapping_bodies()
	plyr_overlap = $plyr_box.get_overlapping_bodies()
	
	if shld_touch:
		if !shld_overlap.has(player):
			shld_touch = false
		else:
			if !player.s_kick and !player.r_boost:
				shld_touch = false

	if shld_overlap != []:
		for i in shld_overlap:
			if i.is_in_group("player"):
				if !shld_touch:
					if player.s_kick or player.r_boost:
						world.sound('dink')
						world.calc_damage($shield_box, i)
						shld_touch = true
					else:
						if player.stun < 0:
							world.calc_damage(i, $shield_box)
			else:
				if i.name != "scuttle_puck":
					reflect(i)

	if hit_overlap != []:
		for i in hit_overlap:
			var prev_hits = -1
			world.calc_damage(self, i)
			if prev_hits != hits:
				hits += 1
				prev_hits = hits
			
	
	if plyr_overlap != []:
		if player.s_kick or player.r_boost:
			if !shld_touch:
				var prev_hits = -1
				world.calc_damage(self, player)
				if prev_hits != hits:
					hits += 1
					prev_hits = hits
		else:
			if player.stun < 0:
				world.calc_damage(player, self)
	
	if world.boss_hp <= 0:
		for k in get_tree().get_nodes_in_group('def_bullet'):
			k.queue_free()
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
				
		for n in range(16):
			var boom = world.DEATH_BOOM.instance()
			boom.global_position = global_position
			boom.id = n
			world.get_child(3).add_child(boom)
		queue_free()

func play_anim(anim):
	$anim.play(anim)

func _on_anim_finished(anim_name):
	match anim_name:
		"fade_in":
			thrusters = true
			world.boss = true
			world.play_music("boss")
			$anim.play("move_to")
			$tween.interpolate_property(self, "position", position, position + Vector2(-88, 64), 0.75, Tween.TRANS_LINEAR, Tween.EASE_IN)
			$tween.start()
		
		"intro":
			world.fill_b_meter = true
		
		"close":
			if state == 0:
				$anim.play("fly")
				state = 3
			
			if state == 17:
				if global_position.x > camera.limit_left + 128 and $sprite.flip_h or global_position.x < camera.limit_left + 128 and !$sprite.flip_h:
					$anim.play("turn_2")
				else:
					$anim.play("fly")
					state = 3
			
			if state == 19:
				$anim.play("desp_move")
				x_target = (camera.limit_left + 128 - global_position.x)
				velocity.x = x_target
				velocity.y = 150
				state = 20
		
		"turn_1":
			if state == 2:
				if turns > 0:
					$anim.play("fly")
				else:
					$anim.play("charge")
				if $sprite.flip_h:
					$sprite.flip_h = false
				else:
					$sprite.flip_h = true
				state = 3
			elif state == 4:
				$anim.play("hover_1")
				if $sprite.flip_h:
					$sprite.flip_h = false
					velocity.x = -90
				else:
					$sprite.flip_h = true
					velocity.x = 90
				velocity.y = 100
			elif state == 10:
				$anim.play("hover_1")
				if $sprite.flip_h:
					$sprite.flip_h = false
				else:
					$sprite.flip_h = true
			elif state == 32:
				$anim.play("hover_1")
				if $sprite.flip_h:
					$sprite.flip_h = false
					if hits != 0:
						velocity.x = -90
				else:
					$sprite.flip_h = true
					if hits != 0:
						velocity.x = 90
				if hits != 0:
					state = 4
					hits = 0
					velocity.y = 100
				else:
					state = 10
			
		"turn_2":
			if state == 6:
				$anim.play("hover_1")
				if $sprite.flip_h:
					$sprite.flip_h = false
				else:
					$sprite.flip_h = true
				thr_state = -1
				state = 5
			
			if state == 13:
				if !$sprite.flip_h:
					$sprite.flip_h = true
				else:
					$sprite.flip_h = false
				$anim.play("hover_1")
				state = 14
			
			if state == 17:
				slap_delay = 40
				if $sprite.flip_h:
					$sprite.flip_h = false
				else:
					$sprite.flip_h = true
				$anim.play("fly")
				state = 3
		
		"open":
			if state == 7:
				$anim.play("rise")
				x_target = round(player.global_position.x - global_position.x)
				velocity.x = x_target
				velocity.y = JUMP_STR
				state = 8
			
			if state == 18:
				var p_flash = load("res://scenes/effects/pinch_flash.tscn").instance()
				p_flash.position = global_position
				world.get_child(3).add_child(p_flash)
				world.sound('bling')
		
		"fall":
			if state == 8:
				velocity.x = 0
		
		"up_floor":
			if state == 11:
				$anim.play("hover_1")
				state = 12
		
		"slap":
			slap_delay = 60
			velocity.x = 0
			$anim.play("open")

func _on_tween_completed(_object, _key):
	$anim.play("intro")

func calc_damage(body):
	
	#Spring Puck
	
	#All other weapons
	var add_count = false
	if body.is_in_group("weapons") and body.property != 99 or body.is_in_group("adaptor_dmg"):
		world.enemy_dmg(id, body.id)
		if world.damage != 0 and !body.reflect:
			#Weapon behaviors.
			match body.property:
				0:
					body._on_screen_exited()
				2:
					if world.damage < world.boss_hp:
						body._on_screen_exited()
				3:
					if world.damage < world.boss_hp:
						if flash == 0:
							body.choke_check()
							body.choke_max = CHOKE
							body.choke_delay = 6
						body.velocity = Vector2(0, 0)
			if flash == 0:
				world.boss_hp -= world.damage
				if state == 1 or state == 2 or state == 3:
					hits += 1
			if !add_count:
				world.hit_num += 1
				add_count = true
			flash = 20
			hit = true
			if world.boss_hp > 0:
				world.sound("hit")
			else:
				if body.property == 3:
					if !body.ret:
						body.ret()
		else:
			if body.property != 3:
				body.reflect = true
			else:
				if !body.ret:
					body.ret()
			
	if body.name == "mega_arm" and body.choke:
		body.global_position = global_position
		if flash == 0 and body.choke_delay == 0:
			if body.choke_max > 0:
				world.boss_hp -= 10
				body.choke_max -= 1
				body.choke_delay = 6
				flash = 20
				hit = true
				world.sound("hit")
				#Make the Mega Arm return to the player if boss dies.
				if world.boss_hp <= 0:
					body.choke = false
					body.choke_delay = 0
		elif body.choke_max == 0 or id == 0:
			body.choke = false
			body.choke_delay = 0

func ceiling_dmg():
	$anim.play("recoil")
	world.shake = 12
	var add_count = false
	if flash == 0:
		world.boss_hp -= 40
	if !add_count:
		world.hit_num += 1
		add_count = true
	flash = 20
	hit = true
	if world.boss_hp > 0:
		world.sound("hit")
	state = 26

func normal_dmg():
	var add_count = false
	if flash == 0:
		world.boss_hp -= 40
	if !add_count:
		world.hit_num += 1
		add_count = true
	flash = 20
	hit = true
	if world.boss_hp > 0:
		world.sound("hit")

func reflect(body):
	if body.property != 3 and body.property != 99:
		body.reflect = true
	elif body.property == 3:
		if !body.ret and !body.choke:
			world.sound('dink')
			body.ret()

func plyr_dmg():
	if player.hurt_timer == 0 and player.blink_timer == 0 and !player.hurt_swap and !player.r_boost and !charge and !player.slap:
		global.player_life[int(player.swap)] -= damage
		player.damage()

func stun_plyr():
	if player.is_on_floor() and player.hurt_timer == 0 and player.blink_timer == 0 and !player.hurt_swap:
		player.slide_timer = 0
		player.stun = 120
		player.anim_state(player.FALL)
		player.no_input(true)
