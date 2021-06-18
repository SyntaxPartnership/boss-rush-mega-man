extends Node2D

onready var world = get_parent().get_parent()
onready var player = world.get_child(2)

var id = 4
var property = 4

var reflect = false

func _ready():
	world.shot_num += 1
	$anim.play("boom")
	audio.play_sound("big_explode")
	
	if !player.r_boost and !player.cutscene:
		player.anim_state(player.RBOOST)
		if player.jumps != 0:
			player.jumps -= 1
		player.velocity.y = (player.JUMP_SPEED * 0.855) * player.jump_mod
		player.slide = false
		player.r_boost = true

func _on_boom_finished(_anim_name):
	queue_free()

func _on_screen_exited():
	_on_boom_finished("boom")
