extends KinematicBody2D

onready var world = get_parent().get_parent()
onready var player = world.get_child(2)
onready var p_sprite = player.get_child(3)

const SPEED = 300

var dir = 0

var reflect = false

var ref_dink = false

var id = 0
var property = 0

var velocity = Vector2()

func _ready():
	#Change the sound effect to whatever is needed.
	world.sound("shoot_a")

	#Set direction if necessary
	if p_sprite.flip_h:
		$sprite.flip_h = true

	if player.shot_dir == 0:
		dir = -1
	else:
		dir = 1

func _physics_process(delta):

	if !reflect:
		velocity.x = dir * SPEED
	else:
		if !ref_dink:
			world.sound("dink")
			ref_dink = true
		
		velocity.x = -dir * SPEED

		velocity.y = -SPEED

	velocity = move_and_slide(velocity, Vector2(0, -1))

func _on_screen_exited():
	world.shots -= 1
	queue_free()