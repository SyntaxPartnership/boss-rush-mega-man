extends KinematicBody2D

onready var world = get_parent().get_parent()

var set_grav = false
var velocity = Vector2()

func _ready():
	$anim.play("spin")

func _physics_process(delta):
	if set_grav:
		velocity.y += 900 * delta
		
		velocity = move_and_slide(velocity, Vector2(0, -1))

func kill():
	var boom = load("res://scenes/effects/s_explode.tscn").instance()
	boom.global_position = global_position
	world.get_child(3).add_child(boom)
	queue_free()
