extends KinematicBody2D

onready var world = get_parent().get_parent()
onready var camera = world.get_child(2).get_child(9)
onready var player = world.get_child(2)

var id = 3
const CHOKE = 3

const SPEED = 75
const CHRG_SPD = 125

var radius = Vector2.ONE * 0.5
var rotation_duration = 1.0
var offset = 0

var intro_tele = 0
var intro = true
var intro_delay = 30
var fill_bar = false

var state = 0
var act_timer = 120
var action = 0
var prev_action = 0
var act_count = 0
var side = 0
var opt_choose = 0
var c_bomb_len = 0
var c_bomb_opt = [72, 128]
var chrg_delay = 0
var chrg_dir = Vector2()
var plyr_pos = Vector2()
var pinch = false

var t_delay_max = 12
var t_delay = 0
var pinch_bomb = 0

var bomb_drop = 0
var bomb_max = 2
var bomb_side = false
var c_bomb = false
var carpet_bmb = 0
var toss = false

var velocity = Vector2()

var flash = 0
var flash_delay = 0
var hit = false

var damage = 40

var overlap = []

func _ready():
	
	world.reset_bolt_calc(false)
	
	#Set position and starting animation.
	global_position.x = camera.limit_left + 40
	global_position.y = camera.limit_top + 128
	
	$anim.play("teleport")
	world.sound("roto_a")

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
		if act_timer == 0 and state == 1:
			if world.boss_hp > 200:
				action = round(rand_range(0, 1))
			else:
				action = round(rand_range(0, 2))
			if action == 0:
				velocity.x = 0
				state = 2
				$anim.play_backwards("teleport")
				world.sound("roto_a")
			if action == 1:
				velocity.x = 0
				state = 3
				$anim.play_backwards("teleport")
				world.sound("roto_a")
			if action == 2:
				velocity.x = 0
				state = 5
				if player.global_position.x < camera.limit_left + 128:
					side = 0
				else:
					side = 1
				opt_choose = round(rand_range(0, 1))
				c_bomb_len = c_bomb_opt[opt_choose]
				$anim.play_backwards("teleport")
				world.sound("roto_a")
	
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
		
			#Get angle of player if they stay in one place too long.
			if plyr_pos != player.global_position:
				chrg_delay = 0
				plyr_pos = player.global_position
			
			if plyr_pos == player.global_position:
				chrg_delay += 1
				
				if chrg_delay == 110:
					velocity = Vector2(0, 0)
					if global_position.x < player.global_position.x:
						$sprite.flip_h = true
						$sprite/bubble.position.x = -$sprite/bubble.position.x
					$sprite/bubble.show()
					$anim.play("surprise")
					world.sound("shock")
					chrg_delay = 0
					state = 6
		
		if world.boss_hp < 150 and !pinch:
			velocity.x = 0
			state = 9
			$anim.play_backwards("teleport")
			world.sound("roto_a")
			pinch = true
		
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
			world.sound("roto_a")
			state = 4
	
	if state == 5:
		
		if c_bomb:
			carpet_bmb += 1
		
		if carpet_bmb == 10:
			world.sound("throw")
			var bomb = load('res://scenes/bosses/roto_bomb.tscn').instance()
			bomb.global_position = global_position
			world.get_child(1).add_child(bomb)
			carpet_bmb = 0
		
		if c_bomb_len > 0:
			c_bomb_len -= 1
		
		if act_count == 2:
			if side == 0:
				velocity.x = 100
			else:
				velocity.x = -100
			
			if c_bomb_len == 0:
				velocity.x = 0
				act_count += 1
				$anim.play_backwards("teleport")
				world.sound("roto_a")
				c_bomb = false
				carpet_bmb = 0
				c_bomb_len = c_bomb_opt[opt_choose]
		
		if act_count == 5:
			if side == 0:
				velocity.x = -100
			else:
				velocity.x = 100
			
			if c_bomb_len == 0:
				velocity.x = 0
				act_count += 1
				$anim.play_backwards("teleport")
				world.sound("roto_a")
				c_bomb = false
				carpet_bmb = 0
	
	if state == 7:
		velocity = chrg_dir * 300
		
		if is_on_floor() or is_on_ceiling():
			velocity = Vector2(0, 0)
			state = 8
			$anim.play_backwards("teleport")
			world.sound("roto_a")
	
	if state == 9:
		if t_delay > 0:
			t_delay -= 1
		
		if t_delay == 1:
			$anim.play_backwards("teleport")
			world.sound("roto_a")
			if t_delay_max > 0:
				t_delay_max -= 1
			
			if t_delay_max == 1:
				$anim.play_backwards("teleport")
				world.sound("roto_a")
				act_count = 0
				state = 10
	
	velocity = move_and_slide(velocity, Vector2(0, -1))
	
	if flash > 0:
		flash_delay += 1
		flash -= 1
		
		if flash_delay > 3:
			flash_delay = 0
		
		if flash_delay == 1:
			$sprite.hide()
			$flash.show()
		
		if flash_delay == 3:
			$flash.hide()
			$sprite.show()
	
	if flash == 0 and hit:
		$flash.hide()
		$sprite.show()
		flash_delay = 0
		hit = false
		
	overlap = $hit_box.get_overlapping_bodies()
	
	if !overlap.has(player):
		if world.dink:
			world.dink = false
	
	if overlap != []:
		
		for body in overlap:
			if body.is_in_group("player"):
				if !player.r_boost and !player.s_kick:
					world.calc_damage(body, self)
				else:
					world.calc_damage(self, body)
			if body.is_in_group("weapons"):
				world.calc_damage(self, body)
#		for body in overlap:
#			if body.is_in_group("weapons") or body.is_in_group("adaptor_dmg"):
#				if flash == 0:
#					world.enemy_dmg(id, body.id)
#					if world.damage != 0 and !body.reflect:
#						var add_count = false
#						#Weapon behaviors.
#						match body.property:
#							0:
#								body._on_screen_exited()
#							2:
#								if world.damage < world.boss_hp:
#									body._on_screen_exited()
#							3:
#								if world.damage < world.boss_hp:
#									body.choke_check()
#									body.choke_max = CHOKE
#									body.choke_delay = 6
#									body.velocity = Vector2(0, 0)
#						world.boss_hp -= world.damage
#						flash = 20
#						hit = true
#						if !add_count:
#							world.hit_num += 1
#						if world.boss_hp > 0:
#							world.sound("hit")
#						else:
#							if body.property == 3:
#								if !body.ret:
#									body.ret()
#					else:
#						if body.property != 3:
#							body.reflect = true
#						else:
#							if !body.ret:
#								body.ret()
#
#			if body.name == "mega_arm" and body.choke:
#				body.global_position = global_position
#				if flash == 0 and body.choke_delay == 0:
#					if body.choke_max > 0:
#						world.boss_hp -= 10
#						body.choke_max -= 1
#						body.choke_delay = 6
#						flash = 20
#						hit = true
#						world.sound("hit")
#						#Make the Mega Arm return to the player if boss dies.
#						if world.boss_hp <= 0:
#							body.choke = false
#							body.choke_delay = 0
#				elif body.choke_max == 0 or id == 0:
#					body.choke = false
#					body.choke_delay = 0
#
#			if body.name == "player":
#				if player.hurt_timer == 0 and player.blink_timer == 0 and !player.hurt_swap:
#					global.player_life[int(player.swap)] -= damage
#					player.damage()
	
	if $anim.get_current_animation() == "drop1" and $sprite.get_frame() == 18 and !toss:
		if bomb_drop == bomb_max:
			bomb_side = true
		world.sound("throw")
		var bomb = load('res://scenes/bosses/roto_bomb.tscn').instance()
		bomb.global_position = global_position
		bomb.velocity.y = -200
		world.get_child(1).add_child(bomb)
		toss = true
	
	if $anim.get_current_animation() == "drop2" and $sprite.get_frame() == 21 and !toss:
		world.sound("throw")
		var bomb = load('res://scenes/bosses/roto_bomb.tscn').instance()
		bomb.global_position = global_position
		bomb.velocity.y = 300
		world.get_child(1).add_child(bomb)
		toss = true
	
	if $anim.get_current_animation() == "teleport" and !$hit_box/box.is_disabled():
		$hit_box/box.set_disabled(true)
	elif $anim.get_current_animation() != "teleport" and $hit_box/box.is_disabled():
		$hit_box/box.set_disabled(false)
	
	#Increase Bomb Drops as Roto takes damage.
	if world.boss_hp <= 210 and bomb_max < 4:
		bomb_max = 4

	if world.boss_hp <= 140 and bomb_max != 6:
		bomb_max = 6
	
	if world.boss_hp <= 0:
		world.kill_music()
		world.sound("death")
		world.bolt_calc()
		
		for i in get_tree().get_nodes_in_group("bomb"):
			i.queue_free()
		
		for b in range(world.max_bolts):
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

func _on_anim_finished(anim_name):
	
	if anim_name == "teleport":
		if intro:
			match intro_tele:
				0:
					$anim.play_backwards("teleport")
					world.sound("roto_a")
					intro_tele += 1
				1:
					global_position.x = camera.limit_left + 40
					global_position.y = camera.limit_top + 64
					$anim.play("teleport")
					intro_tele += 1
				2:
					$anim.play_backwards("teleport")
					world.sound("roto_a")
					intro_tele += 1
				3:
					global_position.x = camera.limit_left + 128
					global_position.y = camera.limit_top + 136
					$anim.play("teleport")
					intro_tele += 1
				4:
					$anim.play_backwards("teleport")
					world.sound("roto_a")
					intro_tele += 1
				5:
					global_position.x = camera.limit_right - 40
					global_position.y = camera.limit_top + 64
					$anim.play("teleport")
					intro_tele += 1
				6:
					$anim.play_backwards("teleport")
					world.sound("roto_a")
					intro_tele += 1
				7:
					global_position.x = camera.limit_right - 40
					global_position.y = camera.limit_top + 136
					$anim.play("teleport")
					intro_tele += 1
				8:
					$anim.play("surprise")
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
					act_timer = 120
		
		if state == 5:
			match act_count:
				0:
					if side == 0:
						global_position.x = camera.limit_left + 24
						global_position.y = camera.limit_top + 136
					else:
						global_position.x = camera.limit_right - 24
						global_position.y = camera.limit_top + 136
					$anim.play("teleport")
					act_count += 1
				1:
					$anim.play("spin-fast")
					c_bomb = true
					act_count += 1
				3:
					if side == 0:
						global_position.x = camera.limit_right - 24
						global_position.y = camera.limit_top + 136
					else:
						global_position.x = camera.limit_left + 24
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
					act_timer = 120
		
		if state == 8:
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
					act_timer = 120
		
		if state == 9:
			match act_count:
				0:
					global_position.x = round(rand_range(camera.limit_left + 24, camera.limit_right - 24))
					global_position.y = camera.limit_top + 40
					$anim.play("teleport")
					act_count += 1
				1:
					$anim.play("surprise")
					t_delay = t_delay_max
					act_count = 0
		
		if state == 10:
			match act_count:
				0:
					global_position.x = round(rand_range(camera.limit_left + 24, camera.limit_right - 24))
					global_position.y = camera.limit_top + 40
					$anim.play("teleport")
					act_count += 1
				1:
					$anim.play_backwards("teleport")
					world.sound("roto_a")
					act_count += 1
				2: 
					global_position.x = round(rand_range(camera.limit_left + 24, camera.limit_right - 24))
					global_position.y = camera.limit_top + 40
					$anim.play("teleport")
					act_count += 1
				3:
					$anim.play("drop2")
		
		if state == 11:
			match act_count:
				0:
					global_position.x = player.global_position.x
					global_position.y = camera.limit_top + 136
					$anim.play("teleport")
					act_count += 1
				1:
					$anim.play("spin-norm")
					act_timer = 120
					act_count = 0
					state = 1
					
					
	if anim_name == "drop1":
		if bomb_drop < bomb_max:
			$anim.play_backwards("teleport")
			world.sound("roto_a")
			bomb_drop += 1
		else:
			$anim.play("spin-norm")
			state = 1
			bomb_drop -= bomb_max
			act_timer = 120
		toss = false
		act_count = 0
	
	if anim_name == "drop2":
		if pinch_bomb < 9:
			pinch_bomb += 1
			act_count = 0
		else:
			state = 11
			act_count = 0
			pinch_bomb = 0
		$anim.play_backwards("teleport")
		world.sound("roto_a")
		toss = false
	
	if anim_name == "surprise":
		if state == 6:
			var target = (player.global_position - global_position).normalized()
			chrg_dir = target
			$sprite.flip_h = false
			$sprite/bubble.position.x = -$sprite/bubble.position.x
			$sprite/bubble.hide()
			$anim.play("spin-fast")
			state = 7
	
	if anim_name == "intro":
		world.fill_b_meter = true

func play_anim(anim):
	$anim.play(anim)
