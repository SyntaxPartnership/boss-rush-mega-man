extends KinematicBody2D

onready var world = get_parent().get_parent()
onready var player = world.get_child(2)

var touch = false
var damage = 0

func _physics_process(delta):
	if touch and player.hurt_timer == 0 and player.blink_timer == 0 and !player.hurt_swap:
		if $body.frame == 10 or $body.frame == 11 or $body.frame == 12 or $body.frame == 13:
			damage = 60
		else:
			damage = 40
		global.player_life[int(player.swap)] -= damage
		player.damage()

func _on_hitbox_body_entered(body):
	if body.name == "player":
		touch = true

func _on_hitbox_body_exited(body):
	if body.name == "player":
		touch = false

