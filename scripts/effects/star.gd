extends KinematicBody2D

const SPEED = 150

var angle = Vector2.ZERO
var velocity = Vector2.ZERO

var kill = 60

func _ready():
	$anim.play("grow")

func _physics_process(delta):
	
	kill -= 1
	
	if kill == 0:
		queue_free()
	
	position -= angle * (SPEED * delta)
