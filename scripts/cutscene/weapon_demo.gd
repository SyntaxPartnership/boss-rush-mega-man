extends Node2D

const ROCK_NORM = preload('res://assets/sprites/player/mega-norm.png')
const ROCK_THROW = preload('res://assets/sprites/player/mega-throw.png')
const BLUES_NORM = preload('res://assets/sprites/player/proto-norm-shld.png')
const BLUES_THROW = preload('res://assets/sprites/player/proto-throw-shld.png')
const FORTE_NORM = preload('res://assets/sprites/player/bass-norm.png')
const FORTE_THROW = preload('res://assets/sprites/player/bass-throw.png')

const RUN_SPEED = 90
const JUMP_SPEED = -310
const GRAVITY = 900

var x_dir = 0
var new_x = 0
var vel = Vector2.ZERO
var throw = false
var skick = false
var skick_time = 0
var sk_rebound = false
var skr_time = 8
var sk_vel = Vector2.ZERO
var thrw_delay = 20
var state = 0
var new_state = 0
var start_timer = false
var act_timer = 30

enum {APPEAR, IDLE, LILSTEP, RUN, JUMP, RBOOST, SKICK_AIR, SKICK_SLD}

# Called when the node enters the scene tree for the first time.
func _ready():
	match global.player:
		0:
			$demo_plyr/sprite.texture = ROCK_NORM
		1:
			$demo_plyr/sprite.texture = BLUES_NORM
		2:
			$demo_plyr/sprite.texture = FORTE_NORM

func _process(delta):
	
	if state == 0:
		return
	
	if act_timer > 0 and start_timer:
		act_timer -= 1
	
	if act_timer == 0:
		match state:
			2:
				match global.player_weap[0]:
					1:
						x_dir = 1
						change_anim("skick_ground")
						$skick/anim.play("ground")
						$skick.show()
						skick = true
						skick_time = 15
						state += 1
			4:
				jump(1)
				state += 1
		
		start_timer = false
		act_timer = 30
	
	match state:
		1:
			audio.play_sound("appear")
			change_anim("teleport")
			$demo_plyr/sprite.show()
			state += 1
		5:
			if vel.y > 0:
				x_dir = 1
				skick = true
				skick_time = 15
				$skick/anim.play("air")
				$skick.show()
				state += 1
		
	if throw and thrw_delay > 0:
		thrw_delay -= 1
	
	if thrw_delay == 0:
		throw = false
		change_sprite(throw)
		thrw_delay = 20

func _physics_process(delta):
	
	if state == 0:
		return
	
	if state > 1:
		
		if !skick:
			if x_dir != new_x:
				if $demo_plyr.is_on_floor():
					vel.x = x_dir * RUN_SPEED
					new_x = x_dir
			else:
				vel.x = 0
		
		if !skick and !sk_rebound:
			if $demo_plyr.is_on_floor() and $demo_plyr/anim.current_animation == "run" or !$demo_plyr.is_on_floor():
				vel.x = x_dir * RUN_SPEED
		else:
			if $demo_plyr.is_on_floor():
				vel.x = (x_dir * RUN_SPEED) * 2
				
				if skick_time > 0:
					skick_time -= 1
				
				if skick_time == 0:
					kill_skick()
				
			else:
				if !sk_rebound:
					vel.x = (x_dir * RUN_SPEED) * 3
				else:
					vel.x = -x_dir * RUN_SPEED
					
					if sk_rebound and skr_time > 0:
						skr_time -= 1
						
					if skr_time == 0:
						state = 0
		
		if !skick:
			vel.y += GRAVITY * delta
		else:
			vel.y = 270
		
		vel = $demo_plyr.move_and_slide(vel, Vector2(0, -1))
		
		if !$demo_plyr.is_on_floor():
			if !skick:
				change_anim("jump")
			else:
				change_anim("skick_air")
		elif $demo_plyr.is_on_floor() and $demo_plyr/anim.current_animation == "jump":
			if x_dir != 0:
				change_anim("run")
			else:
				if global.player != 1:
					change_anim("idle1")
				else:
					change_anim("idle2")
	
	#Swoop Kick node.
	if !sk_rebound:
		$skick.position = $demo_plyr.position
	else:
		if $skick/enemybox/box.is_disabled():
			$skick/enemybox/box.set_disabled(false)
		
		sk_vel = Vector2(RUN_SPEED * 3, 270)
		
		sk_vel = $skick.move_and_slide(sk_vel, Vector2(0, -1))
		
		if sk_rebound and $skick.is_on_floor():
			if $skick/anim.current_animation != "ground":
				$skick/anim.play("ground")
					
	#Print Shit.
	if new_state != state:
		print("State: ",state,", Timer(",start_timer,"): ",act_timer)
		new_state = state

func jump(j_mod):
	vel.y = JUMP_SPEED * j_mod

func kill_skick():
	skick = false
	
	if $demo_plyr.is_on_floor():
		if global.player != 1:
			change_anim("idle1")
		else:
			change_anim("idle2")
		x_dir = 0
		state += 1
	
	if $demo_plyr.is_on_floor():
		$skick.hide()
		start_timer = true

func change_anim(anim_name):
	$demo_plyr/anim.play(anim_name)

func change_sprite(state):
	match global.player:
		0:
			if !throw:
				$demo_plyr/sprite.texture = ROCK_NORM
			else:
				$demo_plyr/sprite.texture = ROCK_THROW
		1:
			if !throw:
				$demo_plyr/sprite.texture = BLUES_NORM
			else:
				$demo_plyr/sprite.texture = BLUES_THROW
		2:
			if !throw:
				$demo_plyr/sprite.texture = FORTE_NORM
			else:
				$demo_plyr/sprite.texture = FORTE_THROW

func _on_anim_done(anim_name):
	match anim_name:
		"teleport":
			if global.player != 1:
				change_anim("idle1")
			else:
				change_anim("idle2")
			start_timer = true
		
		"lilstep":
			if x_dir != 0:
				change_anim("run")
			else:
				if global.player != 1:
					change_anim("idle1")
				else:
					change_anim("idle2")

func _on_enemy_box_area_entered(area):
	
	area.queue_free()
	
	if skick and !$demo_plyr.is_on_floor() and !sk_rebound:
		kill_skick()
		jump(0.5)
		$skick/enemybox/box.set_disabled(false)
		sk_rebound = true

func _on_enemybox_skick_entered(area):
	area.queue_free()
