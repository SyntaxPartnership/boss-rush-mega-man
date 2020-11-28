extends KinematicBody2D

onready var world = get_parent().get_parent().get_parent()
onready var camera = world.get_child(2).get_child(9)
onready var player = world.get_child(2)

export var radius = Vector2.ONE * 256 # Distance on the x and y axis to orbit around the controller
export var rotation_duration := 4.0 # How many seconds it takes for one platform to complete one rotation

var boom_time = 300
var kick_time = 40
var dist = 0
var fly = false
var kick = false
var up = false
var boing = false
var get_boss = false
var dead = false

var touch = false
var damage = 20

var offset = 0

var spawn = 0

func _ready():
	$anim.play("idle")
	world.play_music('for_you')

func _physics_process(delta):
	
	if !boing:
	#Boom_time and kick_time are always subtracted.
		if boom_time > 0:
			boom_time -= 1
	
		if kick and kick_time > 0:
			kick_time -= 1
	
		#Get distance to player.
		dist = player.global_position.distance_to(global_position)
	
		#If the player is close enough, trigger kick action.
		if dist <= 30 and !kick and !fly:
			world.kill_music()
			$anim.play("idle2")
			kick = true
	
		if kick_time == 0 and !fly:
			if dist <= 30:
				$anim.play("kick")
			kick_time = 40
		
		if $sprite.frame == 4:
			$hitbox/kick_box.set_deferred("disabled", false)
		else:
			$hitbox/kick_box.set_deferred("disabled", true)
	
		if boom_time == 0 and !fly:
			$anim.play("float")
			boom_time = 400
			world.kill_music()
			fly = true
	
		if boom_time == 0 and fly and !dead:
			dead = true
	
	else:
		global_position.y -= 12
		
		if global_position.y < camera.limit_top + 16:
			spawn = 1
			dead = true
	
	if dead and !get_boss:
		if !get_boss:
			var boss = load("res://scenes/bosses/swoop.tscn").instance()
			var clone = load("res://scenes/bosses/swoop_clone.tscn").instance()
			if spawn == 0:
				boss.set_deferred("global_position", global_position)
				boss.up = true
				clone.set_deferred("global_position", global_position)
			else:
				boss.set_deferred("global_position", Vector2(global_position.x, camera.limit_top - 32))
				clone.set_deferred("global_position", Vector2(global_position.x, camera.limit_top - 32))
			world.get_child(1).add_child(clone)
			world.get_child(1).add_child(boss)
			world.boss = true
			world.play_music("boss")
			player.no_input(true)
			get_boss = true
		#Spawn explosion sprite.
		var boom = load("res://scenes/effects/l_explode.tscn").instance()
		boom.global_position = global_position
		world.get_child(3).add_child(boom)
		queue_free()

	if fly:
		if position.y > camera.limit_top + 120 and !up:
			position.y -= 0.5
		else:
			if !up:
				up = true
			offset += 2 * PI * delta / float(rotation_duration)
			offset = wrapf(offset, -PI, PI)
			
			var new_pos = Vector2()
			
			new_pos.x = cos(offset) * radius.x
			new_pos.y = sin(offset) * radius.y
			position = global_position + new_pos
	
	if touch and player.hurt_timer == 0 and player.blink_timer == 0 and !player.hurt_swap:
		global.player_life[int(player.swap)] -= damage
		player.damage()

func _on_anim_finished(anim_name):
	if anim_name == "kick":
		$anim.play("idle2")

func _on_hitbox_body_entered(body):
	if body.is_in_group("weapons"):
		world.kill_music()
		if body.name == "scuttle_puck":
			boing = true
			$anim.play("boing")
			body.velocity.x = 0
			body.boing = true
			body.get_child(1).play("boing")
			world.sound("boing")
		else:
			if body.property != 3:
				body.queue_free()
			else:
				body.dist = 1
			if !dead:
				spawn = 1
				dead = true
	
	if body.name == "player":
		touch = true

func _on_hitbox_body_exited(body):
	if body.name == "player":
		touch = false
