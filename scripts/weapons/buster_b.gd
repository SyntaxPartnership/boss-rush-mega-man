extends KinematicBody2D

onready var world = get_parent().get_parent()
onready var player = world.get_child(2)
onready var p_sprite = player.get_child(3)

const SPEED = 300

var x_dir = 0
var y_dir = 0

var reflect = false

var ref_dink = false

var id = 0
var property = 0

var velocity = Vector2()

func _ready():
	#Change the sound effect to whatever is needed.
	audio.play_sound("shoot_a")
	world.shot_num += 1
	
	#Set direction if necessary
	if p_sprite.flip_h:
		$sprite.flip_h = true
	
	if player.bass_dir != '-up':
		if player.shot_dir == 0:
			x_dir = -1
		else:
			x_dir = 1
	else:
		x_dir = 0
	
	if player.bass_dir == '-up' or player.bass_dir == '-d-up':
		y_dir = -1
	elif player.bass_dir == '-d-down':
		y_dir = 1
	else:
		y_dir = 0

func _physics_process(delta):
	
	if !reflect:
		velocity.x = x_dir * SPEED
		velocity.y = y_dir * SPEED
	else:
		if !ref_dink:
			audio.play_sound("dink")
			ref_dink = true
		
		velocity.x = -x_dir * SPEED
		velocity.y = -1 * SPEED
	
	velocity = move_and_slide(velocity, Vector2(0, -1))
	
	#Edit this when items become available.
	if is_on_floor() or is_on_ceiling() or is_on_wall():
		world.shots -= 1
		queue_free()

func _on_screen_exited():
	world.shots -= 1
	queue_free()
