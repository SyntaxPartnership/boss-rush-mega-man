extends KinematicBody2D

var radius = Vector2(2, 0.2)
var rotation_duration = 5.0
var offset = 0

var move_down = 180

func _ready():
	$anim.play("idle")

func _physics_process(delta):
	
	offset += 2 * PI * delta / float(rotation_duration)
	offset = wrapf(offset, -PI, PI)
	var new_pos = Vector2()
	new_pos.x = cos(offset) * radius.x
	new_pos.y = sin(offset) * radius.y
	global_position += new_pos
	
	if move_down > 0:
		global_position.y += 0.40
		move_down -= 1
	
	if new_pos.x > 0 and $sprite.flip_h:
		$sprite.flip_h = false
	elif new_pos.x < 0 and !$sprite.flip_h:
		$sprite.flip_h = true
