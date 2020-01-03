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
var bat = 0
var make_bat = false

var velocity = Vector2()

var flash = 0
var flash_delay = 0
var hit = false

var touch = false
var damage = 0

func _ready():
	$anim_wings.play("flap")
	
	if global_position.y > camera.limit_top + 96:
		up = true

func _physics_process(delta):
	
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
			$box.disabled = false
	
	#Simulate the wings flapping.
	if $wings.frame < 3:
		$wings.offset.y = -$wings.frame
		$body.offset.y = -$wings.frame
	
	if !intro and !fill_bar:
		if state == 0:
			if is_on_wall():
				
				#Generate a random number:
				randomize()
				swoop = floor(rand_range(0, 10))
				
				var bat_num = get_tree().get_nodes_in_group("bats")
				
				if bat_num.size() < 4:
					bat = floor(rand_range(16, 128))
				
				if swoop <= 3:
					state = 1
					$anim_body.play("down")
					$anim_wings.play("idle")
					$wings.hide()
					velocity.y = 400
				
				if $body.flip_h:
					$body.flip_h = false
					$wings.flip_h = false
				else:
					$body.flip_h = true
					$wings.flip_h = true
				$bat_spawn.position.x = -$bat_spawn.position.x

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
				var bat = load("res://scenes/bosses/bat.tscn").instance()
				bat.global_position = $bat_spawn.global_position
				world.get_child(1).add_child(bat)
				if $body.flip_h:
					bat.start = 0
				else:
					bat.start = 1
				make_bat = true
	
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
	
	if world.boss_hp <= 0:
		world.kill_music()
		var enemy_kill = get_tree().get_nodes_in_group('enemies')
		for i in enemy_kill:
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

func play_anim(anim):
	$anim_body.play(anim)

func _on_hitbox_body_entered(body):
	if body.is_in_group("weapons"):
		#Get weapon and boss id for the damage table.
		world.enemy_dmg(id, body.id)
		#If not flashing, damage the boss
		if world.damage != 0:
			if flash == 0:
				world.sound("hit")
				flash = 24
				hit = true
				world.boss_hp -= world.damage
			#Edit this for individual weapon behaviors.
			body.queue_free()
		else:
			body.reflect = true
	
	if body.name == "player":
		touch = true

func _on_hitbox_body_exited(body):
	if body.name == "player":
		touch = false
