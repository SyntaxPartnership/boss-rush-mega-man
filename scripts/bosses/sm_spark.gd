extends KinematicBody2D

onready var world = get_parent().get_parent()
onready var player = world.get_child(2)
onready var camera = player.get_child(9)

const GRAVITY = 900

var damage = 20

var overlap = []

var scoot = false

var velocity = Vector2()

func _ready():
	$anim.play("spark")
	
	velocity.y = -200

func _physics_process(delta):
	
	velocity.y += GRAVITY * delta
	
	velocity = move_and_slide(velocity, Vector2(0, -1))
	
	overlap = $hit_box.get_overlapping_bodies()
	
	if overlap != []:
		for body in overlap:
			if body.name == 'player':
				if player.hurt_timer == 0 and player.blink_timer == 0 and !player.hurt_swap and !player.r_boost:
					if player.r_boost:
						player.r_boost = false
					global.player_life[int(player.swap)] -= damage
					player.damage()
	
	if is_on_floor() and !scoot:
		if velocity.x > 0:
			velocity.x = 200
		elif velocity.x < 0:
			velocity.x = -200
		scoot = true
	
	if is_on_wall():
		var boom = load("res://scenes/effects/s_explode.tscn").instance()
		boom.global_position = global_position
		world.get_child(3).add_child(boom)
		queue_free()
