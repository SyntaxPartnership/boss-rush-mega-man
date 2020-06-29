extends KinematicBody2D

onready var world = get_parent().get_parent()
onready var player = world.get_child(2)

const GRAVITY = 900
const X_SPD = 150

var id = 5
var property = 99
var reflect = false

var velocity = Vector2()
var bounce = 1
var boing = false
var can_boing = false
var kill = 0

func _ready():
	world.shot_num += 1
	$anim.play("idle")
	world.sound("shoot_a")
	
	velocity.y = -100
	
	if player.get_child(3).flip_h:
		bounce = 1
	else:
		bounce = 0

func _physics_process(delta):
	
	if bounce == 0 and !boing:
		velocity.x = X_SPD
	elif bounce == 1 and !boing:
		velocity.x = -X_SPD
	
	velocity.y += GRAVITY * delta
	
	if velocity.y > 0:
		can_boing = true
	
	velocity = move_and_slide(velocity, Vector2(0, -1))
	
	if is_on_wall():
		if bounce == 0:
			bounce = 1
		else:
			bounce = 0
		kill += 1

	if kill == 2:
		_on_boing_finished("boing")

func _on_hit_box_body_entered(body):
	if can_boing and !boing:
		if body.name == "defend":
			if !body.desp_fin:
				if body.bnce_states.has(body.state):
					body.state = 25
					boing()
				else:
					body.normal_dmg()
					_on_boing_finished(null)
			else:
				world.sound('dink')
				if bounce == 0 and !boing:
					velocity.x = X_SPD
				elif bounce == 1 and !boing:
					velocity.x = -X_SPD
		else:
			boing()
		
		if body.name == "def_bullet" and body.type == 3:
			body.master_vel = Vector2(0, -1)
			body.speed = 300
			boing()
		
		if body.name == "player" and !body.cutscene:
			player.stun = -1
			player.slap = false
			player.no_input(false)
			player.rush_coil = true
			player.velocity.y = player.JUMP_SPEED * 1.6

func _on_boing_finished(_anim_name):
	var boom = load("res://scenes/effects/s_explode.tscn").instance()
	boom.global_position = global_position
	world.get_child(3).add_child(boom)
	queue_free()

func boing():
	velocity.x = 0
	boing = true
	$anim.play("boing")
	world.sound("boing")

func _on_screen_exited():
	_on_boing_finished(null)
