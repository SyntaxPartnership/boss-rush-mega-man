extends KinematicBody2D

onready var offset_x = $sprite.offset.x

const GRAVITY = 900

var velocity = Vector2()

var state = 0

var wiggle = 0
var wiggle_time = 120

# Called when the node enters the scene tree for the first time.
func _ready():
	$anim.play("fall")
	velocity.y = 0

func _physics_process(delta):
	
	if state == 1:
		wiggle -= 1
		
		if wiggle == 0:
			if $sprite.offset.x == 0:
				$sprite.offset.x = -1
				wiggle = 2
			elif $sprite.offset.x == -1:
				$sprite.offset.x = 1
				wiggle = 2
			elif $sprite.offset.x == 1:
				$sprite.offset.x = 0
				wiggle = 40
		
	
	velocity.y += GRAVITY * delta
	
	if velocity.y > 500:
		velocity.y = 500
	
	velocity = move_and_slide(velocity, Vector2(0, -1))
	
	if is_on_floor() and state == 0:
		$anim.play("faceplant")
		wiggle = 40
		state = 1
