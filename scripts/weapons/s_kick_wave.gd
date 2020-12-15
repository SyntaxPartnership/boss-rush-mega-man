extends KinematicBody2D

onready var world = get_parent().get_parent()

var id = 3
var property = 4
var reflect = false

var velocity = Vector2.ZERO
var ground_time = 15

const XSPD = 90
const YSPD = 270

func _ready():
	if !is_on_floor():
		$anim.play("air")

func _physics_process(delta):
	
	#Set sprite according to direction.
	if $sprite.flip_h and $sprite.position.x != 1:
		$sprite.position.x = 1
	elif !$sprite.flip_h and $sprite.position.x != -1:
		$sprite.position.x = -1
	
	if is_on_floor():
		
		ground_time -= 1
		
		if $anim.current_animation != "ground":
			$anim.play("ground")
		
		if $sprite.flip_h:
			velocity.x = XSPD * -2
		else:
			velocity.x = XSPD * 2
	else:
		if $sprite.flip_h:
			velocity.x = XSPD * -3
		else:
			velocity.x = XSPD * 3
			
	velocity.y = 270
	
	velocity = move_and_slide(velocity, Vector2(0, -1))
	
	if ground_time == 0 or is_on_wall() or reflect:
		_on_screen_exited()

func _on_screen_exited():
	var boom = load("res://scenes/effects/s_explode.tscn").instance()
	boom.global_position = global_position
	world.get_child(3).add_child(boom)
	queue_free()
