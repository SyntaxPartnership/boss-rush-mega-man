extends KinematicBody2D

onready var world = get_parent().get_parent()
onready var player = world.get_child(2)
onready var camera = player.get_child(9)

var id = 4
const CHOKE = 3

const GRAVITY = 900
const JUMP_STR = -400

var intro = true
var fill_bar = true

var state = 0
var spr_offset = Vector2()
var spr_shake = 0
var thrusters = false
var thr_strt = -1
var thr_frame = 0
var thr_delay = 0
var thr_state = -1

var thrst_pos = {
	0 : Vector2(-1, 22),
	1 : Vector2(1, 22),
	2 : Vector2(0, 22),
	4 : Vector2(19, 2),
	5 : Vector2(-19, 2),
}

var thrst_data = {
	5 : [0, 0, Vector2(0, 22)],
	9 : [1, 0, Vector2(1, 22)],
	10 : [2, 4, Vector2(-19, 2)],
}

func _ready():
	$anim.play("fade_in")
	
	$sprite.flip_h = true
	

func _physics_process(delta):
	
	#Make the boss shake when her shields clang together.
	if spr_shake > 0:
		spr_offset = Vector2(rand_range(-2, 2), rand_range(-2, 2))
		$sprite.offset = spr_offset
		$thrusters/sprite.offset = $sprite.offset
		spr_shake -= 1
	
	if spr_shake == 0 and spr_offset != Vector2(0, 0):
		spr_offset = Vector2(0, 0)
		$sprite.offset = spr_offset
		$thrusters/sprite.offset = $sprite.offset
	
	if $sprite.frame == 8 and spr_shake == 0:
		spr_shake = 8
	
	#Display the thruster sprites appropriately.
	#Check sprite frame.
	if thrst_data.has($sprite.frame) and thrusters:
		#If frame is in dict, pull data and set frames.
		if thr_state != thrst_data.get($sprite.frame)[0]:
			print($sprite.frame)
			if thr_strt != thrst_data.get($sprite.frame)[1]:
				thr_strt = thrst_data.get($sprite.frame)[1]
				$thrusters/sprite.frame = thr_strt
				thr_delay = 0
				thr_frame = 0
			if !$sprite.flip_h:
				$thrusters/sprite.position.x = -thrst_data.get($sprite.frame)[2].x
			else:
				$thrusters/sprite.position.x = thrst_data.get($sprite.frame)[2].x
			$thrusters/sprite.position.y = thrst_data.get($sprite.frame)[2].y
			$thrusters/sprite.flip_h = $sprite.flip_h
			$thrusters.show()
			thr_state = thrst_data.get($sprite.frame)[0]
	
	#Animate the thrusters.
	if thrusters:
		thr_delay += 1
	
	if thr_delay > 3:
		thr_frame += 1
		
		if thr_frame > 1:
			thr_frame = 0
	
		$thrusters/sprite.frame = thr_strt + thr_frame
		thr_delay = 0

func play_anim(anim):
	$anim.play(anim)

func _on_anim_finished(anim_name):
	match anim_name:
		"fade_in":
			thrusters = true
			world.boss = true
			world.play_music("boss")
			$anim.play("move_to")
			$tween.interpolate_property(self, "position", position, position + Vector2(-88, 64), 0.75, Tween.TRANS_LINEAR, Tween.EASE_IN)
			$tween.start()
		
		"intro":
			world.fill_b_meter = true
		
		"close":
			if state == 0:
				$anim.play("fly")
				state = 1

func _on_tween_completed(object, key):
	$anim.play("intro")
