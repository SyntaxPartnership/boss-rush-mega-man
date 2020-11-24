extends KinematicBody2D

const GRAVITY = 900

var velocity = Vector2()
var plyr_det = []

func _physics_process(delta):
	
	velocity.y += GRAVITY * delta
	
	velocity = move_and_slide(velocity)
	
	plyr_det = $box.get_overlapping_bodies()
