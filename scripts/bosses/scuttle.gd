extends KinematicBody2D

onready var world = get_parent().get_parent()
onready var camera = world.get_child(2).get_child(9)
onready var player = world.get_child(2)

const GRAVITY = 900
const JUMP_STR = -300

var intro = true
var intro_bnce = 0
var p_intro = false
var intro_delay = 40
var fill_bar = false
var spin_spawn = false
var spinner

var velocity = Vector2()
var left_bar = 0
var right_bar = 0

func _ready():
	$anim.play("spin")
	
	left_bar = camera.limit_left + 40
	right_bar = camera.limit_right - 40
	
	global_position.x = camera.limit_left + 128
	global_position.y = camera.limit_top + 69
	
	velocity.y = -200
	velocity.x = -95

func _physics_process(delta):
	
	if p_intro:
		intro_delay -= 1
		
		if intro_delay == 0:
			$anim.play("intro")
	
	velocity.y += GRAVITY * delta
	
	velocity = move_and_slide(velocity, Vector2(0, -1))
	
	if !is_on_floor() and intro_bnce == 1:
		if velocity.y < 0:
			$anim.play("jump")
		else:
			$anim.play("fall")
	
	if intro and is_on_floor():
		velocity.x = 0
		match intro_bnce:
			0:
				velocity.y = -200
				$sprite.flip_h = true
				intro_bnce += 1
		
		if $anim.get_current_animation() == "fall" and intro_bnce == 1:
			$anim.play("land")
			intro_bnce += 1
		
	
	#Animations.
	if $anim.get_current_animation() == "intro":
		match $sprite.frame:
			2:
				if intro_bnce == 2:
					var spin = load("res://scenes/bosses/spin.tscn").instance()
					spinner = spin
					spin.position.x = global_position.x + 12
					spin.position.y = global_position.y - 16
					world.get_child(3).add_child(spin)
					intro_bnce += 1
			3:
				spinner.get_child(0).offset.y = -1
			4:
				spinner.get_child(0).offset.y = 0
	
	#Kill the intro spinner.
	if spinner != null:
		if spinner.global_position.x < left_bar - 16:
			spinner.kill()
			spinner = null
			world.fill_b_meter = true

func play_anim(anim):
	$anim.play(anim)

func _on_anim_finished(anim_name):
	
	match anim_name:
		"intro":
			spinner.velocity = Vector2(-90, -310)
			spinner.set_grav = true
		
		"land":
			if intro:
				$anim.play("idle")
				p_intro = true
	
	
