extends Node2D

onready var world = get_parent().get_parent()
onready var camera = world.get_child(2).get_child(9)
onready var player = world.get_child(2)

var velocity = Vector2()
var overlap = []
var damage = 20

func _ready():
	$anim.play("idle")

func _physics_process(delta):
	
	if $sprite.flip_h:
		velocity.x = 150
	else:
		velocity.x = -150
	
	global_position.x += velocity.x * delta
	
	if global_position.x < camera.limit_left - 8 or global_position.x > camera.limit_right + 8:
		queue_free()
	
	overlap = $hit_box.get_overlapping_bodies()
	if overlap != []:
		for body in overlap:
			if body.name == "player":
				if player.hurt_timer == 0 and player.blink_timer == 0 and !player.hurt_swap:
					global.player_life[int(player.swap)] -= damage
					player.damage()
