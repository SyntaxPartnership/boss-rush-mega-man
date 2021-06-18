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
var skr_time = 0
var blink = -1
var hits = 0
var sk_vel = Vector2.ZERO
var thrw_delay = 20
var state = 0
var new_state = 0
var start_timer = false
var act_timer = 80

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
	
	for e in get_tree().get_nodes_in_group('enemy'):
		match global.player_weap[0]:
			1:
				match e.name:
					"telly":
						e.get_child(1).set_deferred('disabled', false)
						e.show()
					"telly2":
						e.get_child(1).set_deferred('disabled', false)
						e.show()
					"telly3":
						e.get_child(1).set_deferred('disabled', false)
						e.show()
			2:
				match e.name:
					"telly":
						e.get_child(1).set_deferred('disabled', false)
						e.show()
					"telly4":
						e.get_child(1).set_deferred('disabled', false)
						e.show()
					"telly5":
						e.get_child(1).set_deferred('disabled', false)
						e.show()
			3:
				match e.name:
					"met":
						e.get_child(1).set_deferred('disabled', false)
						e.show()
					"met2":
						e.get_child(1).set_deferred('disabled', false)
						e.show()
			4:
				match e.name:
					"telly2":
						e.get_child(1).set_deferred('disabled', false)
						e.show()
					"met2":
						e.get_child(1).set_deferred('disabled', false)
						e.show()
			
	
	$enemies/anim.play("idle")

func _process(delta):
	
	if skr_time > 0:
		if blink > -1:
			blink -= 1
			
		if blink == 0:
			if $demo_plyr/sprite.is_visible_in_tree():
				$demo_plyr/sprite.hide()
			else:
				$demo_plyr/sprite.show()
		
		if blink == -1:
			blink = 1
	
	if state == 0 or state == 99:
		return
	
	if act_timer > 0 and start_timer:
		act_timer -= 1
	
	if act_timer == 0:
		match state:
			2:
				match global.player_weap[0]:
					1:
						audio.play_sound('s_kick')
						x_dir = 1
						change_anim("skick_ground")
						$skick/anim.play("ground")
						$skick.show()
						var smoke = load('res://scenes/effects/slide_smoke.tscn').instance()
						smoke.position = $demo_plyr.position + Vector2(0, 7)
						$overlap.add_child(smoke)
						skick = true
						skick_time = 15
						state += 1
					2:
						var rb = load('res://scenes/player/weapons/roto_boost.tscn').instance()
						rb.position = $demo_plyr.position + Vector2(0, 12)
						$overlap.add_child(rb)
#			4:
#				jump(1)
#				state += 1
		
		start_timer = false
		act_timer = 80
	
	match state:
		1:
			audio.play_sound("appear")
			change_anim("teleport")
			$demo_plyr/sprite.show()
			state += 1
		5:
			if $demo_plyr.position.x >= $enemies/telly2.position.x - 20:
				x_dir = 0
				jump(1)
				state += 1
		6:
			if vel.y > 0:
				x_dir = 1
				skick = true
				skick_time = 15
				$skick/anim.play("air")
				$skick.show()
		
	if throw and thrw_delay > 0:
		thrw_delay -= 1
	
	if thrw_delay == 0:
		throw = false
		change_sprite(throw)
		thrw_delay = 20

func _physics_process(delta):
	
	if state == 0 or state == 99:
		return
	
	if state > 1 and state != 99:
		
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
					pass
#					kill_skick()
				
			else:
				if !sk_rebound:
					vel.x = (x_dir * RUN_SPEED) * 3
				else:
					vel.x = -x_dir * RUN_SPEED
					
					if sk_rebound and skr_time > 0:
						skr_time -= 1
						
					if skr_time == 0:
						match hits:
							1:
								x_dir = 0
							2:
								start_text()
		
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
			$skick/enemybox/box.set_deferred('disabled', false)
		
		sk_vel = Vector2(RUN_SPEED * 3, 270)
		
		sk_vel = $skick.move_and_slide(sk_vel, Vector2(0, -1))
		
		if $skick.is_on_floor():
			if $skick/anim.current_animation != "ground":
				$skick/anim.play("ground")
		
		if $skick.is_on_wall():
			x_dir = 1
			change_anim('lilstep')
			state += 1
			$skick.hide()
			$skick/enemybox/box.set_deferred('disabled', true)
			sk_rebound = false
			
					
	#Print Shit.
	if new_state != state:
		print("State: ",state,", Timer(",start_timer,"): ",act_timer,', X Direction: ',x_dir)
		new_state = state

func jump(j_mod):
	vel.y = JUMP_SPEED * j_mod

func kill_skick():
	skick_time = 0
	skick = false
	
	if $demo_plyr.is_on_floor():
		if global.player != 1:
			change_anim("idle1")
		else:
			change_anim("idle2")
		state += 1
	
#	if $demo_plyr.is_on_floor():
#		$skick.hide()
#		start_timer = true

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
	
	audio.play_sound('hit')
	var boom = load('res://scenes/effects/s_explode.tscn').instance()
	boom.position = area.position
	$overlap.add_child(boom)
	area.hide()
	area.get_child(1).set_deferred('disabled', true)
	
	if skick and !sk_rebound:
		if !$demo_plyr.is_on_floor():
			skr_time = 8
		else:
			skr_time = 12
		blink = 1
		kill_skick()
		jump(0.5)
		$skick/enemybox/box.set_deferred('disabled', false)
		sk_rebound = true
	
	hits += 1

func _on_enemybox_skick_entered(area):
	audio.play_sound('hit')
	var boom = load('res://scenes/effects/s_explode.tscn').instance()
	boom.position = area.position
	$overlap.add_child(boom)
	area.hide()
	area.get_child(1).set_deferred('disabled', true)

func start_text():
	for p in get_tree().get_nodes_in_group("pause"):
		p.stop()
	state = 99
