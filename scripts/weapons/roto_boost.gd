extends Node2D

onready var world = get_parent().get_parent()
onready var player = world.get_child(2)

func _ready():
	$anim.play("boom")
	world.sound("big_explode")
	
	if !player.r_boost:
		player.anim_state(player.RBOOST)
		if player.jumps != 0:
			player.jumps -= 1
		player.velocity.y = player.JUMP_SPEED * player.jump_mod
		player.slide = false
		player.r_boost = true

func _on_boom_finished(anim_name):
	queue_free()
