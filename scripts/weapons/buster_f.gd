extends KinematicBody2D

onready var world = get_parent().get_parent()
onready var player = world.get_child(2)
onready var p_sprite = player.get_child(3)
onready var start_pos = p_sprite.get_child(1)

const SPEED = 300

var dir = 0

var reflect = false
var ret = false

var ref_dink = false

var id = 2
var property = 2

var move = false

var strt_p = Vector2()

var velocity = Vector2()

func _ready():
	#Change the sound effect to whatever is needed.
	$audio/shoot.play()
	
	world.shot_num += 1

	$anim.play("appear")

	#Set direction if necessary
	if p_sprite.flip_h:
		$sprite.flip_h = true

	if player.shot_dir == 0:
		$hitbox_m.position.x = -5
		$hitbox_l.position.x = -9
		dir = -1
	else:
		$hitbox_m.position.x = 5
		$hitbox_l.position.x = 9
		dir = 1

func _physics_process(delta):

	if move:
		match $sprite.frame:
			0:
				if $hitbox_s.is_disabled():
					$hitbox_s.set_disabled(false)
					$hitbox_m.set_disabled(true)
					$hitbox_l.set_disabled(true)
			3:
				if $hitbox_m.is_disabled():
					$hitbox_s.set_disabled(true)
					$hitbox_m.set_disabled(false)
					$hitbox_l.set_disabled(true)
			4:
				if $hitbox_l.is_disabled():
					$hitbox_s.set_disabled(true)
					$hitbox_m.set_disabled(true)
					$hitbox_l.set_disabled(false)
			
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

func ret():
	pass
