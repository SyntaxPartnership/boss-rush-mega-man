extends Node2D

onready var world = get_parent().get_parent()
onready var player = world.get_child(2)

var id = 3
var property = 4

func _ready():
	
	world.sound("s_kick")
	
	if !player.is_on_floor() and !player.wall:
		$anim.play("air")
		player.s_kick = true
	else:
		$anim.play("air")
		player.s_kick = true

func _physics_process(delta):
	
	if player.wall:
		player.s_kick = false
	
	global_position = player.global_position
	$sprite.flip_h = player.get_child(3).flip_h
	
	if player.is_on_floor():
		$anim.play("ground")
	else:
		$anim.play("air")
	
	if !player.s_kick:
		queue_free()
