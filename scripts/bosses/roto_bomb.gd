extends KinematicBody2D

onready var world = get_parent().get_parent()

const GRAVITY = 900

var velocity = Vector2()

func _physics_process(delta):
	velocity.y += GRAVITY * delta
	
	velocity = move_and_slide(velocity, Vector2(0, -1))
	
	#Add function in case the bomb strikes the player.
	
	if is_on_floor():
		var boom = load('res://scenes/bosses/roto_explode.tscn').instance()
		boom.global_position = global_position
		world.get_child(3).add_child(boom)
		queue_free()
