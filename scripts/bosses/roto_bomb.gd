extends KinematicBody2D

onready var world = get_parent().get_parent()
onready var roto = get_tree().get_nodes_in_group("roto")

const GRAVITY = 900

var velocity = Vector2()

var property = 8

var id = 8

var reflect = false

var rebound = false

var overlap = []

func _physics_process(delta):
	
	overlap = $hit_box.get_overlapping_bodies()
	if overlap != []:
		for body in overlap:
			if body.name == "player" and !rebound:
				boom()
			if body.name == "attack_shield":
				reverse()
	
	if !rebound:
		velocity.y += GRAVITY * delta
	
	velocity = move_and_slide(velocity, Vector2(0, -1))
	
	if is_on_floor() or is_on_ceiling():
		boom()


func reverse():
	if !rebound:
		world.sound('dink')
		velocity.y = -velocity.y
		self.remove_from_group('enemies')
		self.add_to_group('weapons')
		self.set_collision_mask_bit(5, true)
		rebound = true


func boom():
	world.sound("roto_b")
	world.shake = 4
	if roto[0].bomb_side and !rebound:
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
