extends Node2D

onready var world = get_parent().get_parent()
onready var player = world.get_child(2)
onready var camera = player.get_child(9)

const SPEED = 200
const SFORCE = 200

var velocity = Vector2.ZERO
var acceleration = Vector2.ZERO
var angle = 0
var final_vel = Vector2.ZERO

var time = 12

var move = false

var damage = 60

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

func seek():
	var steer = Vector2.ZERO
	var desired = (player.position - position).normalized() * SPEED
	steer = (desired - velocity).normalized() * SFORCE
	return steer

func _physics_process(delta):
	
	if time > 0:
		acceleration = Vector2(0, -1) * SPEED
		time -= 1
	else:
		acceleration += seek()
		
	velocity += acceleration * delta
	velocity = velocity.clamped(SPEED)
	
	var get_angle = velocity.angle()
	angle = stepify(get_angle, PI / 4)
	
	final_vel = Vector2(cos(angle), sin(angle))
	
	sprt_del -= 1
	
	if sprt_del == 0:
		if f_offset == 0:
			f_offset = 8
		else:
			f_offset = 0
		
		sprt_del = 2
	
	$sprite.frame = frame.get(Vector2(round(final_vel.x), round(final_vel.y))) + f_offset
	
	position += final_vel * (SPEED * delta)

func _on_hitbox_body_entered(body):
	if body.is_in_group("weapons") or body.is_in_group("adaptor_dmg"):
		if !body.reflect:
			if body.property == 0:
				body.queue_free()
			elif body.property == 3:
				if body.level == 0:
					body.dist = 1
			var boom = load("res://scenes/effects/l_explode.tscn").instance()
			boom.position = global_position
			world.get_child(3).add_child(boom)
			queue_free()
	
	if body.name == "player":		
		if player.hurt_timer == 0 and player.blink_timer == 0 and !player.hurt_swap and !player.r_boost:
			if player.r_boost:
				player.r_boost = false
			global.player_life[int(player.swap)] -= damage
			player.damage()
		
		var boom = load("res://scenes/effects/l_explode.tscn").instance()
		boom.position = global_position
		world.get_child(3).add_child(boom)
		queue_free()

func kill_gaby():
	pass
