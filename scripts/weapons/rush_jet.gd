extends KinematicBody2D

onready var world = get_parent().get_parent()
onready var player = world.get_child(2)
onready var camera = world.get_child(2).get_child(9)

const X_VEL = 60
const Y_VEL = 30
const BEAM_SPD = 400

var time_start = false
var time = 240
var f_delay = 0
var use_energy = 0
var y_dir = 0
var on_floor = false
var leave = false
var flying = false
var play = false
var wall = false
var velocity = Vector2()

func _ready():
	$anim.play("beam")

func _physics_process(delta):
	#Check to see if Rush has room to land.
	if position.y > player.position.y - 32 and $block_det.get_overlapping_bodies() == []:
		if !leave and !on_floor:
			$hitbox.set_disabled(false)
	
	if player.rush_jet:
		y_dir = int(Input.is_action_pressed("down")) - int(Input.is_action_pressed("up"))
	else:
		y_dir = 0
			
	if !leave and !on_floor:
		velocity.y = BEAM_SPD
	elif leave:
		velocity.y = -BEAM_SPD
	
	if flying:
		if !$sprite.flip_h:
			velocity.x = X_VEL
		else:
			velocity.x = -X_VEL
		velocity.y = y_dir * Y_VEL
		
		use_energy += 1
		
		if use_energy == 16:
			global.rp_jet[int(player.swap) + 1] -= 10
			use_energy = 0
	
	velocity = move_and_slide(velocity, Vector2(0, -1))
	
	#Check for collision with an obstacle.
	for idx in range(get_slide_count()):
		var collision = get_slide_collision(idx)
		
		#Kill Rush
		if is_on_wall():
			if collision.collider.name in ['tiles', 'snow', 'death', 'slw_conv_l', 'slw_conv_r', 'fst_conv_l', 'fst_conv_r', 'ice', 'anti-weap']:
				velocity.y = 0
				velocity.x = 0
				flying = false
				wall = true
				$anim.play("appear")
				$standbox/box.set_disabled(true)
	#If Rush stays too long, he will leave the area.
	if time_start and time > -1:
		time -= 1
	
	#If time reaches a certain point, begin flash animation.
	if time <= 60 and time > -1 and !leave:
		f_delay += 1
	
	if f_delay == 1:
		$sprite.hide()

	if f_delay == 3:
		$sprite.show()
	
	#Loop f_delay
	if f_delay > 3:
		f_delay = 0
	
	#If Rush's timer reaches 0.
	if time == 0 and !wall:
		wall = true
		$sprite.show()
		f_delay = 0
		$anim.play("appear")
		$standbox/box.set_disabled(true)
	
	#If energy releaches 0.
	if global.rp_jet[int(player.swap) + 1] == 0 and !wall:
		velocity.y = 0
		velocity.x = 0
		flying = false
		wall = true
		$anim.play("appear")
		$standbox/box.set_disabled(true)
	
	if !on_floor and is_on_floor():
		$anim.play("appear")
		on_floor = true
	
	#When the player jumps onto Rush, engage the flying functions.
	if !play and player.rush_jet:
		time_start = false
		time = 240
		f_delay = 0
		$sprite.show()
		if $sprite.flip_h:
			player.shot_dir = 0
		else:
			player.shot_dir = 1
		player.get_child(3).flip_h = $sprite.flip_h
		$anim.play("flying")
		play = true
		flying = true
	
	if global_position.y > camera.limit_bottom + 16:
		_on_screen_exited()

func _on_anim_finished(anim_name):
	if anim_name == "appear":
		if on_floor and !leave:
			$sprite.flip_h = player.get_child(3).flip_h
			$anim.play("transform")
		
		if wall:
			$hitbox.set_disabled(true)
			$anim.play("beam")
			leave = true
	
	if anim_name == "transform":
		$anim.play("idle")
		$standbox/box.set_disabled(false)
		time_start = true

func _on_screen_exited():
	queue_free()
	world.adaptors = 0
