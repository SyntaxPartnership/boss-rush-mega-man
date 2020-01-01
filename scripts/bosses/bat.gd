extends KinematicBody2D

onready var world = get_parent().get_parent()
onready var player = world.get_child(2)

var start = 0
var state = 0
var cooldown = 60

var velocity = Vector2()

var touch = false
var damage = 40

func _ready():
	$anim.play("appear")

func _physics_process(delta):
	
	match state:
		0:
			if start == 0:
				velocity = Vector2(-10, -20)
			else:
				velocity = Vector2(10, -20)
		1:
			if global_position.x < player.global_position.x and velocity.x < 100:
				velocity.x += 10
			elif global_position.x > player.global_position.x and velocity.x > -100:
				velocity.x -= 10
			
			if global_position.y < player.global_position.y and velocity.y < 100:
				velocity.y += 10
			elif global_position.y > player.global_position.y and velocity.y > -100:
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
	
	if touch and player.hurt_timer == 0 and player.blink_timer == 0 and !player.hurt_swap:
		global.player_life[int(player.swap)] -= damage
		player.damage()
	
	velocity = move_and_slide(velocity, Vector2(0, -1))

func _on_anim_finished(anim_name):
	if anim_name == "appear":
		$anim.play("flap")
		velocity = Vector2(0, 0)
		state = 1

func _on_hitbox_body_entered(body):
	if body.is_in_group("weapons"):
		body.queue_free()
		world.sound("hit")
		var boom = load("res://scenes/effects/s_explode.tscn").instance()
		boom.global_position = global_position
		world.get_child(3).add_child(boom)
		queue_free()
	
	if body.name =="player":
		touch = true
		velocity.x = -velocity.x
		velocity.y = -velocity.y
		state = 2

func _on_hitbox_body_exited(body):
	if body.name =="player":
		touch = false
