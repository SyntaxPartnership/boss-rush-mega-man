extends Node2D

onready var world = get_parent().get_parent()
onready var player = world.get_child(2)
onready var camera = player.get_child(9)

const SPEED = 120

var velocity = Vector2(0, -1)

var time = 24

var sprt_del = 2
var f_offset = 1
var frame = {
	Vector2(0, 0) : 0,
	Vector2(0, -1) : 0,
	Vector2(-1, -1) : 1,
	Vector2(-1, 0) : 2,
	Vector2(-1, 1) : 3,
	Vector2(0, 1) : 4,
	Vector2(1, 1) : 5,
	Vector2(1, 0) : 6,
	Vector2(1, -1) : 7
}

func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	time -= 1
	sprt_del -= 1
	
	if sprt_del == 0:
		if f_offset == 0:
			f_offset = 8
		else:
			f_offset = 0
		
		$sprite.frame = frame.get(velocity) + f_offset
		
		sprt_del = 2

	if time == 0:
		var get_angle = get_angle_to(player.position)
		var get_vect = Vector2(round(cos(get_angle)), round(sin(get_angle)))

		if velocity.x < get_vect.x:
			velocity.x += 1
		elif velocity.x > get_vect.x:
			velocity.x -= 1
		if velocity.y < get_vect.y:
			velocity.y += 1
		elif velocity.y > get_vect.y:
			velocity.y -= 1
		
		$sprite.frame = frame.get(velocity) + f_offset
		
		time = 8

	position += velocity * (SPEED * delta)
