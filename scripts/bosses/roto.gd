extends KinematicBody2D

onready var world = get_parent().get_parent()
onready var camera = world.get_child(2).get_child(9)
onready var player = world.get_child(2)

var intro_tele = 0
var intro = true
var intro_delay = 30
var fill_bar = false

func _ready():
	
	#Set position and starting animation.
	global_position.x = camera.limit_left + 40
	global_position.y = camera.limit_top + 128
	
	$anim.play("teleport")

func _physics_process(delta):
	
	if fill_bar:
		if intro_delay > 0:
			intro_delay -= 1
		
		if intro_delay == 1:
			$anim.play("intro")

func _on_anim_finished(anim_name):
	print(anim_name)
	
	if anim_name == "teleport" and intro:
		match intro_tele:
			0:
				$anim.play_backwards("teleport")
				intro_tele += 1
			1:
				global_position.x = camera.limit_left + 40
				global_position.y = camera.limit_top + 64
				$anim.play("teleport")
				intro_tele += 1
			2:
				$anim.play_backwards("teleport")
				intro_tele += 1
			3:
				global_position.x = camera.limit_left + 128
				global_position.y = camera.limit_top + 136
				$anim.play("teleport")
				intro_tele += 1
			4:
				$anim.play_backwards("teleport")
				intro_tele += 1
			5:
				global_position.x = camera.limit_right - 40
				global_position.y = camera.limit_top + 64
				$anim.play("teleport")
				intro_tele += 1
			6:
				$anim.play_backwards("teleport")
				intro_tele += 1
			7:
				global_position.x = camera.limit_right - 40
				global_position.y = camera.limit_top + 136
				$anim.play("teleport")
				intro_tele += 1
			8:
				$anim.play("idle")
				fill_bar = true
	
	if anim_name == "intro":
		world.fill_b_meter = true

func play_anim(anim):
	$anim.play(anim)
