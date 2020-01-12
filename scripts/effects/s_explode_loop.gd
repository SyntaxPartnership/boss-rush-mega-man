extends Node2D

onready var world = get_parent().get_parent()

var id = 0
var dir = Vector2()
var speed
var velocity

func _ready():
	

	
	$anim.play('anim')
	
	match id:
		0:
			dir = Vector2(0, -1)
			speed = 90
		1:
			dir = Vector2(1, -1)
			speed = 70
		2:
			dir = Vector2(1, 0)
			speed = 90
		3:
			dir = Vector2(1, 1)
			speed = 70
		4:
			dir = Vector2(0, 1)
			speed = 90
		5:
			dir = Vector2(-1, 1)
			speed = 70
		6:
			dir = Vector2(-1, 0)
			speed = 90
		7:
			dir = Vector2(-1, -1)
			speed = 70
		8:
			dir = Vector2(0, -1)
			speed = 45
		9:
			dir = Vector2(1, -1)
			speed = 35
		10:
			dir = Vector2(1, 0)
			speed = 45
		11:
			dir = Vector2(1, 1)
			speed = 35
		12:
			dir = Vector2(0, 1)
			speed = 45
		13:
			dir = Vector2(-1, 1)
			speed = 35
		14:
			dir = Vector2(-1, 0)
			speed = 45
		15:
			dir = Vector2(-1, -1)
			speed = 35

func _physics_process(delta):
	
	if id <16:
		position += (dir * speed) * delta

func _on_screen_exited():
	queue_free()
