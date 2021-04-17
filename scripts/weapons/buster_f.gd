extends KinematicBody2D

onready var world = get_parent().get_parent()
onready var player = world.get_child(2)
onready var p_sprite = player.get_child(3)
onready var start_pos = p_sprite.get_child(1)

const SPEED = 300

var dir = 0

var reflect = false

var ref_dink = false

var id = 1
var property = 2

var move = false

var strt_p = Vector2()

var velocity = Vector2()

func _ready():
	#Change the sound effect to whatever is needed.
	$audio/shoot.play()

	$anim.play("appear")

	#Set direction if necessary
	if p_sprite.flip_h:
		$sprite.flip_h = true

	if player.shot_dir == 0:
		dir = -1
	else:
		dir = 1

func _physics_process(delta):

	if move:
		if $hitbox.is_disabled():
			$hitbox.set_disabled(false)
			
		if !reflect:
			velocity.x = dir * SPEED
		else:
			if !ref_dink:
				$audio/reflect.play()
				$anim.play("reflect")
				ref_dink = true
			
			velocity.x = -dir * SPEED
	
			velocity.y = -SPEED
	
		velocity = move_and_slide(velocity, Vector2(0, -1))

func _on_screen_exited():
	world.shots -= 2
	player.cooldown = false
	queue_free()

func _on_anim_finished(anim_name):
	if anim_name == 'appear':
		$anim.play("loop")
		move = true
