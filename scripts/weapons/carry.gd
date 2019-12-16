extends RigidBody2D

onready var world = get_parent().get_parent()

var time = 320
var f_delay = 0

func _ready():
	if $block_det.get_overlapping_bodies() == []:
		$shoot.play()
		$anim.play("idle")

# warning-ignore:unused_argument
func _physics_process(delta):
	#Decrease the timer.
	if time > 0:
		time -= 1
	
	#If the time has reached a certain point, start flashing the object.
	if time <= 60:
		f_delay += 1
	
	#Make Carry flash.
	if f_delay == 1:
		$sprite.hide()
	
	if f_delay == 3:
		$sprite.show()
	
	#loop f_delay
	if f_delay > 3:
		f_delay = 0
	
	#When the timer reaches 0, kill the object.
	if time == 0:
		kill()

# warning-ignore:unused_argument
func _on_body_entered(body):
	kill()

func kill():
		var explode = load('res://scenes/effects/s_explode.tscn').instance()
		world.get_child(3).add_child(explode)
		explode.position = position
		queue_free()
		world.adaptors = 0