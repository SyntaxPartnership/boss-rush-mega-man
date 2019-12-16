extends KinematicBody2D

onready var world = get_parent().get_parent()
onready var player = world.get_child(2)
onready var camera = world.get_child(2).get_child(9)

const SPEED = 400

var time = 240
var f_delay = 0
var on_floor = false
var leave = false
var used = false
var used_time = 60
var velocity = Vector2()

func _ready():
	$anim.play("beam")

func _physics_process(delta):
	
	#Check to see if Rush has room to land.
	if position.y > player.position.y - 32 and $block_det.get_overlapping_bodies() == []:
		if !leave:
			$box.set_disabled(false)
		
	#Move Rush's sprite.
	if !on_floor:
		velocity.y = SPEED
	else:
		if leave:
			velocity.y = -SPEED
	
	velocity = move_and_slide(velocity, Vector2(0, -1))
	
	#Begin coil functions.
	if is_on_floor() and !on_floor:
		$anim.play("appear")
		on_floor = true
		$block_det/box.set_disabled(true)
		
	#If Rush stays too long, he will leave the area.
	if !used and time > -1:
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
	
	#If the player used Rush, then start a second timer.
	if used and used_time > -1:
		used_time -= 1
	
	#If either timer expires, make Rush leave.
	if time == 0 or used_time == 0:
		$sprite.show()
		f_delay = 0
		$anim.play("appear")
	
	#If Rush falls below the screen, kill him.
	if global_position.y > camera.limit_bottom + 16:
		_on_screen_exited()
	
func _on_anim_finished(anim_name):
	if anim_name == "appear":
		if !used and time > 0:
			$anim.play("idle")
			$sprite.flip_h = player.get_child(3).flip_h
			$jump_box/box.set_disabled(false)
		
		if used_time <= 0 or time <= 0:
			$anim.play("beam")
			leave = true
			$box.set_disabled(true)

func _on_plyr_entered(body):
	if player.position.y < position.y and player.velocity.y > 0:
		time = 240
		used = true
		$sprite.show()
		player.rush_coil = true
		player.velocity.y = player.JUMP_SPEED * 1.6
		$jump_box.set_deferred('monitoring', false)
		$anim.play("used")
		global.rp_coil[int(player.swap)+1] -= 20

func _on_screen_exited():
	#If Rush is not on screen, kill him.
	world.adaptors = 0
	queue_free()
