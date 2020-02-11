extends KinematicBody2D

onready var world = get_parent().get_parent()
onready var player = world.get_child(2)
onready var camera = player.get_child(9)
onready var p_sprite = player.get_child(3)

const SPEED = 300
const RET_SPD = 500
const ST_FORCE = 50
const RET_FORCE = 70
var level = 0
var dir = Vector2()
var id = 0
var dist = 0
var ret = false
var choke = false
# warning-ignore:unused_class_variable
var choke_max = 0
var choke_delay = 0
var reflect = false

var overlap = []
var targets = []
var nearest
var f_target

var velocity = Vector2()
var accel = Vector2.ZERO

#This is a new variable that will dictate how the shot reacts when striking an enemy.
#0: Disappear
#1: Pierce
#2: Pierce if HP is equal or lower than damage.
#3: Pierce if HP is equal or lower than damage. Begin return script.
#4: Nothing
# warning-ignore:unused_class_variable
var property = 3

func _ready():
	$anim.play("idle")
	world.sound("shoot_b")
	
	get_targets()
	
	if level == 0:
		id = 1
		dist = 10
	else:
		id = 2
		if f_target == null:
			dist = 24
		else:
			dist = 32
	
	if p_sprite.flip_h:
		$sprite.flip_h = true

	if player.shot_dir == 0:
		dir.x = -1
	else:
		dir.x = 1
	
	velocity.x = dir.x * SPEED
	
	var boom = load("res://scenes/effects/s_explode.tscn").instance()
	boom.global_position = global_position
	world.get_child(3).add_child(boom)

# warning-ignore:unused_argument
func _physics_process(delta):
	
	if !choke:
		if !ret:
			if global.perma_items.get("seeker_hand") and f_target != null and level != 0:
				accel = seek()
				velocity += accel
				velocity.clamped(SPEED)
				if velocity.x < 0 and !$sprite.flip_h:
					$sprite.flip_h = true
				elif velocity.x > 0 and $sprite.flip_h:
					$sprite.flip_h = false
		else:
			if f_target != player:
				f_target = player
			accel = seek()
			velocity += accel
			velocity.clamped(RET_SPD)
			if velocity.x < 0 and $sprite.flip_h:
				$sprite.flip_h = false
			elif velocity.x > 0 and !$sprite.flip_h:
				$sprite.flip_h = true
		
#		position += velocity * delta
		velocity = move_and_slide(velocity, Vector2(0, -1))
	
	dist -= 1

	if dist == 0 and !choke:
		velocity = -velocity
		$anim.play("return")
		reflect = true
		ret = true

	if choke:
		if $sprite.flip_h:
			$sprite.offset.x -= 0.25
		else:
			$sprite.offset.x += 0.25

		if $sprite.offset.x < -1.75 or $sprite.offset.x > 1.75:
			$sprite.offset.x = 0

		if choke_delay > 0:
			choke_delay -= 1
	
	#If the player has acquire the magnet hand...
	if global.perma_items.get('magnet_hand'):
		overlap = $player_detect.get_overlapping_bodies()
		
		if overlap != []:
			for body in overlap:
				if body.is_in_group('items') and body.grab == 0:
					body.global_position = global_position
	
func _on_player_detect_body_entered(body):
	if body.name == "player":
		if ret:
			world.sound("connect")
			player.shot_state(player.NORMAL)
			world.shots = 0
			player.cooldown = false
			queue_free()

func choke_check():
	if global.perma_items.get('choke_hand'):
		if !choke:
			velocity = Vector2(0, 0)
			dir.x = 0
			dir.y = 0
			$anim.play('choke')
			choke = true
			reflect = true
			ret = true
			dist = 0
	else:
		dist = 1
		reflect = true

func seek():
	var steer = Vector2.ZERO
	var desired = Vector2.ZERO
	desired = (f_target.position - position).normalized() * SPEED
	steer = (desired - velocity).normalized() * ST_FORCE
	return steer

func get_targets():
	targets = get_tree().get_nodes_in_group("boss")
	
	if targets != []:
		nearest = targets[0]
	
	if targets.size() > 1:
		for t in targets:
			if t.global_position.x < camera.get_camera_screen_center().x + 128 and t.global_position.x > camera.get_camera_screen_center().x - 128:
				if t.global_position.distance_to(global_position) < nearest.global_position.distance_to(global_position):
					f_target = t
	else:
		f_target = nearest

func ret():
	dist = 1
	choke = false
	choke_delay = 0
	f_target = player
	velocity = -velocity
