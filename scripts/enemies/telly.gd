extends Node2D

onready var world = get_parent().get_parent().get_parent()
onready var player = world.get_child(2)

var damage = 20

var dink = false

func _ready():
	$anim.play("idle")

func _physics_process(delta):
	
	var detect = $detect.get_overlapping_bodies()
	if detect != []:
		for body in detect:
			if body.name == "player":
				if player.r_boost:
					if player.global_position.x > global_position.x - 11 and player.global_position.x < global_position.x + 11 and player.global_position.y < global_position.y:
						player.velocity.y = (player.JUMP_SPEED * 0.855) / player.jump_mod
					var boom = load("res://scenes/effects/s_explode.tscn").instance()
					boom.global_position = global_position
					world.get_child(3).add_child(boom)
					queue_free()
				else:
					if player.hurt_timer == 0 and player.blink_timer == 0 and !player.hurt_swap and !player.r_boost:
						global.player_life[int(player.swap)] -= damage
						player.damage()
