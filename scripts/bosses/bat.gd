extends KinematicBody2D

onready var world = get_parent().get_parent()
onready var player = world.get_child(2)
onready var camera = player.get_child(9)

var start = 0
var state = 0
var cooldown = 60
var start_pos = Vector2()

var velocity = Vector2()
var spd_mod = 1

var touch = false
var damage = 40

var hp = 2

func _ready():
	if state == 0:
		$anim.play("appear")
	else:
		$anim.play("flap")

func _physics_process(delta):
	
	if spd_mod > 1:
		spd_mod = 1.75
	
	match state:
		0:
			if start == 0:
				velocity = Vector2(-10, -20)
			else:
				velocity = Vector2(10, -20)
		1:
			if global_position.x < player.global_position.x and velocity.x < 80:
				velocity.x += 10
			elif global_position.x > player.global_position.x and velocity.x > -80:
				velocity.x -= 10
			
			if global_position.y < player.global_position.y and velocity.y < 80:
				velocity.y += 10
			elif global_position.y > player.global_position.y and velocity.y > -80:
				velocity.y -= 10
		2:
			if velocity.x < 0:
				velocity.x += 5
			elif velocity.x > 0:
				velocity.x -= 5
			
			if velocity.y < 0:
				velocity.y += 5
			elif velocity.y > 0:
				velocity.y -= 5
			
			cooldown -= 1
			
			if cooldown == 0:
				state = 1
				cooldown = 60
		3:
			velocity.x = -20 * spd_mod
		4:
			velocity.x = -60 * spd_mod
		5:
			velocity.x = 20 * spd_mod
		6:
			velocity.x = 60 * spd_mod
		7:
			velocity.x = 0
			velocity.y = -400
			
			if global_position.y < camera.limit_top + 16:
				var boom = load("res://scenes/effects/s_explode.tscn").instance()
				boom.global_position = global_position
				world.get_child(3).add_child(boom)
				queue_free()
	
	if touch and player.hurt_timer == 0 and player.blink_timer == 0 and !player.hurt_swap:
		global.player_life[int(player.swap)] -= damage
		player.damage()
	
	velocity = move_and_slide(velocity, Vector2(0, -1))

	if state > 2 and state < 7:
		velocity.y += 900 * delta
		
		if global_position.y > start_pos.y + 16:
			var boom = load("res://scenes/effects/s_explode.tscn").instance()
			boom.global_position = global_position
			world.get_child(3).add_child(boom)
			queue_free()
	
	if hp == 0:
		var boom = load("res://scenes/effects/s_explode.tscn").instance()
		boom.global_position = global_position
		world.get_child(3).add_child(boom)
		queue_free()
		hp -= 1

func _on_anim_finished(anim_name):
	if anim_name == "appear":
		$anim.play("flap")
		velocity = Vector2(0, 0)
		state = 1

func _on_hitbox_body_entered(body):
	print(body.name)
	if state < 3:
		if body.is_in_group("weapons"):
			if body.id != 5:
				if !body.reflect:
					if body.property == 0:
						body.queue_free()
					elif body.property == 3:
						if body.level == 0:
							body.dist = 1
					world.sound("hit")
					var boom = load("res://scenes/effects/s_explode.tscn").instance()
					boom.global_position = global_position
					world.get_child(3).add_child(boom)
					queue_free()
			else:
				state = 7
				$anim.stop()
				body.boing()
			
	
	if body.name =="player":
		
		if player.r_boost or player.s_kick:
			world.sound("hit")
			var boom = load("res://scenes/effects/s_explode.tscn").instance()
			boom.global_position = global_position
			world.get_child(3).add_child(boom)
			queue_free()
		
		if state < 3:
			if !player.r_boost and !player.s_kick:
				touch = true
			velocity.x = -velocity.x
			velocity.y = -velocity.y
			state = 2
			hp -= 1
		else:
			if !player.r_boost and !player.s_kick:
				touch = true

func _on_hitbox_body_exited(body):
	if body.name =="player":
		touch = false

func boom():
	world.sound("hit")
	var boom = load("res://scenes/effects/s_explode.tscn").instance()
	boom.global_position = global_position
	world.get_child(3).add_child(boom)
	queue_free()
