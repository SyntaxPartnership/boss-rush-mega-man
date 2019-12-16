extends KinematicBody2D

onready var world = get_parent().get_parent()
onready var player = world.get_child(2)

const GRAVITY = 900

var x_spd = 0

var damage = 10

var dir = 0
var velocity = Vector2()

func _ready():
	$anim.play("idle")
	
	velocity.y = -350

func _physics_process(delta):
	
	#Set which direction the projectile will fly.
	if $sprite.flip_h:
		dir = -1
	else:
		dir = 1
	
	velocity.x = x_spd * dir
	velocity.y += GRAVITY * delta
	
	velocity = move_and_slide(velocity, Vector2(0, -1))
	
	if is_on_ceiling() or is_on_floor() or is_on_wall():
		kill()

func _on_hit_box_body_entered(body):
	if body.name == "player":
		if player.hurt_timer == 0 and player.blink_timer == 0 and !player.hurt_swap:
			global.player_life[int(player.swap)] -= damage
			player.damage()
			kill()

func kill():
	var boom = load("res://scenes/effects/s_explode.tscn").instance()
	boom.global_position = global_position
	world.get_child(3).add_child(boom)
	queue_free()
