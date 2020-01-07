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
var get_boss = false

var touch = false
var damage = 20

var offset = 0

var spawn = 0

func _ready():
	$anim.play("idle")

func _physics_process(delta):
	
	#Boom_time and kick_time are always subtracted.
	if boom_time > 0:
		boom_time -= 1

	if kick and kick_time > 0:
		kick_time -= 1

	#Get distance to player.
	dist = player.global_position.distance_to(global_position)

	#If the player is close enough, trigger kick action.
	if dist <= 30 and !kick:
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
		fly = true

	if boom_time == 0 and fly:
		spawn_boss()
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
		spawn = 1
		spawn_boss()
		var boom = load("res://scenes/effects/l_explode.tscn").instance()
		boom.global_position = global_position
		world.get_child(3).add_child(boom)
		body.queue_free()
		queue_free()
	
	if body.name == "player":
		touch = true

func _on_hitbox_body_exited(body):
	if body.name == "player":
		touch = false

func spawn_boss():
	if !get_boss:
		var boss = load("res://scenes/bosses/swoop.tscn").instance()
		var clone = load("res://scenes/bosses/swoop_clone.tscn").instance()
		if spawn == 0:
			boss.global_position = global_position
			clone.global_position = global_position
		else:
			boss.global_position.x = global_position.x
			clone.global_position.x = global_position.x
			boss.global_position.y = camera.limit_top - 32
			clone.global_position.y = camera.limit_top - 32
		world.get_child(1).add_child(clone)
		world.get_child(1).add_child(boss)
		
		world.boss = true
		world.play_music("boss")
		player.no_input(true)
		get_boss = true