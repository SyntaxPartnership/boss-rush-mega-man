extends KinematicBody2D

onready var world = get_parent().get_parent()
onready var roto = get_tree().get_nodes_in_group("roto")

const GRAVITY = 900

var velocity = Vector2()

var overlap = []

func _physics_process(delta):
	
	velocity.y += GRAVITY * delta
	
	velocity = move_and_slide(velocity, Vector2(0, -1))
	
	overlap = $hit_box.get_overlapping_bodies()
	if overlap != []:
		for body in overlap:
			if body.name == "player":
				boom()
	
	if is_on_floor():
		boom()

func boom():
	world.sound("roto_b")
	world.shake = 4
	if roto[0].bomb_side:
		for i in range(0, 2):
			var side = load('res://scenes/bosses/roto_side.tscn').instance()
			side.global_position = global_position
			if i == 1:
				side.get_child(0).flip_h = true
			world.get_child(3).add_child(side)
	var boom = load('res://scenes/bosses/roto_explode.tscn').instance()
	boom.global_position = global_position
	world.get_child(3).add_child(boom)
	roto[0].bomb_side = false
	queue_free()
