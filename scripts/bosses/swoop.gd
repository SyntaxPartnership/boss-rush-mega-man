extends KinematicBody2D

onready var world = get_parent().get_parent()
onready var camera = world.get_child(2).get_child(9)
onready var player = world.get_child(2)

#Id to determine which damage table to use.
var id = 2

var intro = true
var intro_delay = 30
var fill_bar = false

var up = false

var center = 0

var state = 0
var swoop = 0
var dives = 0
var limiter = 0
var bat = 0
var make_bat = false
var clone
var c_heart
var c_active = false
var deny_drill = true
var x_dist = 0
var drill_time = 30
var drill_bats = 0
var orig_state = 0

var h_state = 0
var h_dir = 0
var h_vel = Vector2()
var c_flash = 30
var c_f_delay = 0

var velocity = Vector2()
var orig_vel = Vector2()

var flash = 0
var flash_delay = 0
var hit = false

var touch = false
var damage = 0

func _ready():
	$anim_wings.play("flap")
	
	if global_position.y > camera.limit_top + 96:
		up = true
	
	center = camera.limit_right - 128
	
	var heart = load("res://scenes/bosses/heart.tscn").instance()
	heart.global_position = global_position
	world.get_child(1).add_child(heart)
	c_heart = heart
	c_heart.hide()

func _physics_process(delta):
	
	if clone == null:
		var get_clone = get_tree().get_nodes_in_group("special")
		#Set variable for the clone.
		for c in get_clone:
			if c.name == "swoop_clone":
				clone = c
	
	#Get x distance between boss and player.
	x_dist = floor(global_position.x - player.global_position.x)
	
	#Boss intro dance
	if intro and !fill_bar:
		if global_position.y < camera.limit_top + 96 and !up:
			velocity.y = 200
		elif global_position.y > camera.limit_top + 96 and up:
			velocity.y = -200
		else:
			velocity.y = 0
			fill_bar = true
	
	if fill_bar:
		if intro_delay > 0:
			intro_delay -= 1
		
		if intro_delay == 1:
			$anim_body.play("intro")
			$box_a.set_deferred("disabled", false)
	
	#Simulate the wings flapping.
	if $wings.frame < 3:
		$wings.offset.y = -$wings.frame
		$body.offset.y = -$wings.frame
	
	if !intro and !fill_bar:
		if $body.flip_h:
			$wings.position.x = -1
		else:
			$wings.position.x = 1
		
		if state == 0:
			if is_on_wall():
				
				#Generate a random number:
				swoop = floor(rand_range(0, 15))
				
				var bat_num = get_tree().get_nodes_in_group("bats")
				
				if bat_num.size() < 4:
					bat = floor(rand_range(16, 128))
				
				if swoop <= 5:
					if limiter < 2:
						state = 1
						world.sound("swoop_d")
						$anim_body.play("down")
						$anim_wings.play("idle")
						$wings.hide()
						velocity.y = 400
						limiter += 1
					else:
						velocity.y = 0
						global_position.y = camera.limit_top + 96
						$anim_body.play("idle")
						$anim_wings.play("flap")
						$wings.show()
						state = 0
						dives = 0
				
				#Drill action.
				if swoop > 5 and swoop <= 9 and !deny_drill:
					velocity.x = -velocity.x
					state = 3
				
				if swoop > 5 and limiter != 0:
					limiter = 0
				
				if $body.flip_h:
					$body.flip_h = false
					$wings.flip_h = false
				else:
					$body.flip_h = true
					$wings.flip_h = true
				$bat_spawn.position.x = -$bat_spawn.position.x
				clone.get_child(2).position.x = -clone.get_child(2).position.x
				
				#Disable the flag so the boss can use her drill attack.
				if deny_drill:
					deny_drill = false

			if $body.flip_h:
				velocity.x = 90
			else:
				velocity.x = -90
			
			#When the bat timer reaches a certain point, spawn a bat.
			if bat > 0:
				bat -= 1
			
			if bat == 1:
				state = 2
				velocity.x = 0
				$anim_body.play("kiss")
		
		if state == 1:
			
			if $body.flip_h:
				velocity.x = 120
			else:
				velocity.x = -120
			
			if velocity.y > -350:
				velocity.y -= 900 * delta
			
			if velocity.y < 0 and velocity.y >= -10:
				$anim_body.play("up")
			
			if global_position.y < camera.limit_top + 96 and velocity.y < 0:
				if dives < 1:
					velocity.y = 400
					world.sound("swoop_d")
					$anim_body.play("down")
					dives += 1
				else:
					velocity.y = 0
					global_position.y = camera.limit_top + 96
					$anim_body.play("idle")
					$anim_wings.play("flap")
					$wings.show()
					state = 0
					dives = 0
		
		if state == 2:
			if $body.frame == 2 and !make_bat:
				world.sound("swoop_a")
				var bat = load("res://scenes/bosses/bat.tscn").instance()
				bat.global_position = $bat_spawn.global_position
				world.get_child(1).add_child(bat)
				if $body.flip_h:
					bat.start = 0
				else:
					bat.start = 1
				#Make the clone spit out a bat.
				if c_active:
					var c_bat = load("res://scenes/bosses/bat.tscn").instance()
					c_bat.global_position = clone.get_child(2).global_position
					world.get_child(1).add_child(c_bat)
					if clone.get_child(1).flip_h:
						bat.start = 0
					else:
						bat.start = 1
				make_bat = true
		
		if state == 3:
			if x_dist >= -16 and x_dist <= 16:
				velocity.x = 0
				$anim_body.play("drill_a")
				$anim_wings.play("begin_drill")
				state = 4
		
		if state == 5:
			velocity.y += 900 * delta
		
		if state == 6:
			
			drill_time -= 1
			
			if drill_time <= 0:
				if drill_bats < 1:
					drill_bats += 1
					drill_time = 30
					for b in range(1, 5):
						var bat = load("res://scenes/bosses/bat.tscn").instance()
						bat.set_deferred("global_position", Vector2(global_position.x, global_position.y + 12))
						bat.spd_mod += drill_bats
						bat.state = b + 2
						bat.velocity.y = -200
						world.get_child(1).add_child(bat)
						bat.start_pos = global_position
					if c_active:
						for b in range(1, 5):
							var bat = load("res://scenes/bosses/bat.tscn").instance()
							bat.set_deferred("global_position", Vector2(clone.global_position.x, clone.global_position.y + 12))
							bat.spd_mod += drill_bats
							bat.state = b + 2
							bat.velocity.y = -200
							world.get_child(1).add_child(bat)
							bat.start_pos = global_position
				else:
					world.kill_se("swoop_c")
					$anim_body.play("drill_e")
					$box_a.set_deferred("disabled", true)
					$box_b.set_deferred("disabled", false)
					id = 2
					state = 7
		
		if state == 8:
			
			if velocity.y > -90:
				velocity.y -= 5
			
			if global_position.y < camera.limit_top + 96:
				velocity.y = 0
				global_position.y = camera.limit_top + 96
				drill_bats = 0
				drill_time = 30
				state = 0
	
	if world.boss_hp <= 140 and !c_active and state == 0:
		id = 0
		orig_vel = velocity
		velocity = Vector2(0, 0)
		orig_state = state
		$wings.hide()
		$anim_body.play("drill_e")
		state = 9
	
	if flash > 0:
		flash_delay += 1
		flash -= 1
		
		if flash_delay > 3:
			flash_delay = 0
		
		if flash_delay == 1:
			$wings.hide()
			$body.hide()
			$flash.show()
		
		if flash_delay == 3:
			$flash.hide()
			$body.show()
			if $anim_body.get_current_animation() != "up" and $anim_body.get_current_animation() != "down":
				$wings.show()
	
	if flash == 0 and hit:
		$flash.hide()
		$body.show()
		if $anim_body.get_current_animation() != "up" and $anim_body.get_current_animation() != "down":
			$wings.show()
		flash_delay = 0
		hit = false
	
	if touch and player.hurt_timer == 0 and player.blink_timer == 0 and !player.hurt_swap:
		if $anim_body.get_current_animation() != "drill":
			damage = 40
		else:
			damage = 60
		global.player_life[int(player.swap)] -= damage
		player.damage()

	velocity = move_and_slide(velocity, Vector2(0, -1))
	
	if is_on_floor() and state == 5:
		velocity.y = 0
		world.sound("swoop_c")
		$anim_body.play("drill_d")
		for b in range(1, 5):
			var bat = load("res://scenes/bosses/bat.tscn").instance()
			bat.set_deferred("global_position", Vector2(global_position.x, global_position.y + 12))
			bat.spd_mod += drill_bats
			bat.state = b + 2
			bat.velocity.y = -200
			world.get_child(1).add_child(bat)
			bat.start_pos = global_position
		if c_active:
			for b in range(1, 5):
				var bat = load("res://scenes/bosses/bat.tscn").instance()
				bat.set_deferred("global_position", Vector2(clone.global_position.x, clone.global_position.y + 12))
				bat.spd_mod += drill_bats
				bat.state = b + 2
				bat.velocity.y = -200
				world.get_child(1).add_child(bat)
				bat.start_pos = global_position
		state = 6
	
	#Heart behaviors.
	if h_state == 0:
		c_heart.global_position = global_position
	elif h_state == 1:
		if c_heart.global_position.x < clone.global_position.x and h_dir == 1:
			h_vel.x = 180 * delta
		elif c_heart.global_position.x >= clone.global_position.x and h_dir == 1:
			c_heart.global_position = clone.global_position
			world.sound("swoop_b")
			h_state = 2
		
		if c_heart.global_position.x > clone.global_position.x and h_dir == -1:
			h_vel.x = -180 * delta
		elif c_heart.global_position.x <= clone.global_position.x and h_dir == -1:
			c_heart.global_position = clone.global_position
			world.sound("swoop_b")
			h_state = 2
		
		c_heart.global_position += h_vel
	
	if h_state == 2:
		if c_flash > 0:
			c_f_delay += 1
			c_flash -= 1
			
			if c_f_delay > 3:
				c_f_delay = 0
			
			if c_f_delay == 1:
				clone.get_child(0).show()
				clone.get_child(1).show()
				c_heart.hide()
			
			if c_f_delay == 3:
				clone.get_child(0).hide()
				clone.get_child(1).hide()
				c_heart.show()
		
		if c_flash == 0:
			if $wings.is_visible():
				clone.get_child(0).show()
			clone.get_child(1).show()
			c_heart.hide()
			c_active = true
			$anim_body.play("idle")
			$anim_wings.play("flap")
			h_state = 3
			id = 2
			clone.get_child(3).get_child(0).set_deferred("disabled", false)
			state = 0

	#Clone behaviors.
	#Match Y axis
	clone.global_position.y = global_position.y
	
	#Mirror X axis
	var distance = global_position.x - center
	clone.global_position.x = center + -distance
	
	#Mimic animations.
	#Wings
	clone.get_child(0).frame = $wings.frame
	clone.get_child(0).offset.y = $wings.offset.y
	if flash == 0 and c_active:
		if $wings.is_visible() and !clone.get_child(0).is_visible():
			clone.get_child(0).show()
		elif !$wings.is_visible() and clone.get_child(0).is_visible():
			clone.get_child(0).hide()
	
	#body
	clone.get_child(1).frame = $body.frame
	clone.get_child(1).offset.y = $body.offset.y
	
	if $body.flip_h:
		clone.get_child(0).position.x = 1
		clone.get_child(0).flip_h = false
		clone.get_child(1).flip_h = false
	else:
		clone.get_child(0).position.x = -1
		clone.get_child(0).flip_h = true
		clone.get_child(1).flip_h = true
	
	if world.boss_hp <= 0:
		world.kill_music()
		world.sound("death")
		var enemy_kill = get_tree().get_nodes_in_group('enemies')
		for i in enemy_kill:
			if i.name == "swoop_clone":
				var boom = load("res://scenes/effects/l_explode.tscn").instance()
				boom.global_position = clone.global_position
				world.get_child(3).add_child(boom)
			else:
				var boom = load("res://scenes/effects/s_explode.tscn").instance()
				boom.global_position = i.global_position
				world.get_child(3).add_child(boom)
			i.queue_free()
		world.enemy_count = 0
		for n in range(16):
			var boom = world.DEATH_BOOM.instance()
			boom.global_position = global_position
			boom.id = n
			world.get_child(3).add_child(boom)
		queue_free()

func _on_body_anim_finished(anim_name):
	if anim_name == "intro":
		world.fill_b_meter = true
	
	if anim_name == "kiss":
		make_bat = false
		if $body.flip_h:
			velocity.x = 90
		else:
			velocity.x = -90
		$anim_body.play("idle")
		state = 0
	
	if anim_name == "drill_b":
		id = 0
		$anim_body.play("drill_c")
		velocity.y = -200
		state = 5
	
	if anim_name == "drill_e":
		if state != 9:
			$anim_wings.play("end_drill")
			$anim_body.play("drill_a")
			$wings.show()
		else:
			$anim_wings.play("end_drill")
			$anim_body.play("clone_a")
			c_heart.show()
			$wings.show()

func _on_anim_wings_finished(anim_name):
	if anim_name == "begin_drill":
		$anim_body.play("drill_b")
		$wings.hide()
		$box_a.set_deferred("disabled", true)
		$box_b.set_deferred("disabled", false)
	
	if anim_name == "end_drill":
		if state != 9:
			$anim_body.play("idle")
			$anim_wings.play("flap")
			state = 8
		else:
			$anim_body.play("clone_b")
			world.sound("swoop_a")
			h_state = 1
			if c_heart.global_position.x < clone.global_position.x:
				h_dir = 1
			else:
				h_dir = -1

func play_anim(anim):
	$anim_body.play(anim)

func _on_hitbox_body_entered(body):
	if body.is_in_group("weapons"):
		#Get weapon and boss id for the damage table.
		if !body.reflect:
			world.enemy_dmg(id, body.id)
			#If not flashing, damage the boss
			if world.damage != 0:
				if flash == 0:
					world.sound("hit")
					flash = 20
					hit = true
					world.boss_hp -= world.damage
				#Edit this for individual weapon behaviors.
				if body.property == 0:
					body.queue_free()
				elif body.property == 2:
					if world.damage < world.boss_hp:
						body.queue_free()
				elif body.property == 3:
					body.dist = 1
			else:
				if body.property != 3:
					body.reflect = true
				else:
					body.dist = 1
	
	if body.name == "player":
		touch = true

func _on_hitbox_body_exited(body):
	if body.name == "player":
		touch = false
