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
var rboost = false
var spucka_vel = Vector2.ZERO
var spuckb_vel = Vector2.ZERO
var spa_move = false
var spb_move = false
var meta = false
var metb = false
var as_dist = 0
var as_state = 0
var as_active = false
var as_vpos = {0: Vector2(1, 0), 1: Vector2(1, -1), 2: Vector2(0, -1), 3: Vector2(-1, -1), 4: Vector2(-1, 0)}
var metshot = 0
var as_timer_active = false
var as_timer = 4
var arr_pos = 0
var as_pos_delay = 2
var hits = 0
var sk_vel = Vector2.ZERO
var thrw_delay = 20
var state = 0
var new_state = 0
var start_timer = false
var act_timer = 70

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
						change_anim('lilstep')
						x_dir = 1
						state += 1
					3:
						audio.play_sound('shoot_a')
						throw = true
						change_sprite(throw)
						$overlap/spuck.show()
						spa_move = true
						state += 1
					4:
						audio.play_sound('shoot_a')
						throw = true
						change_sprite(throw)
						$overlap/ashield.show()
						as_active = true
						state += 1
			5:
				if global.player_weap[0] == 1 or global.player_weap[0] == 2:
					change_anim('lilstep')
					x_dir = 1
					state += 1
				
			6:
				if global.player_weap[0] == 2:
					change_anim('lilstep')
					x_dir = 1
			
			7:
				if global.player_weap[0] == 3:
					change_anim('lilstep')
					x_dir = 1
					state += 1
			8:
				if global.player_weap[0] == 4:
					as_timer_active = false
					audio.play_sound('connect')
					as_state += 1
					state += 1
			10:
				if global.player_weap[0] == 4:
					as_timer_active = false
					audio.play_sound('connect')
					as_state += 1
					state += 1
			12:
				if global.player_weap[0] == 4:
					as_timer_active = false
					audio.play_sound('connect')
					as_state -= 1
					state += 1
			14:
				if global.player_weap[0] == 4:
					change_anim('lilstep')
					x_dir = 1
					state += 1
		
		start_timer = false
		act_timer = 70
	
	match state:
		1:
			audio.play_sound("appear")
			change_anim("teleport")
			$demo_plyr/sprite.show()
			state += 1
		3:
			if global.player_weap[0] == 2:
				if $demo_plyr.position.x >= $enemies/telly.position.x -16:
					x_dir = 0
					$overlap/rb_blast.position = $demo_plyr.position + Vector2(0, 12)
					$overlap/rb_blast/anim.play("boom")
					$overlap/rb_blast.show()
					audio.play_sound("big_explode")
					rboost = true
					jump(0.855)
					state += 1
					
			if global.player_weap[0] == 3:
				if $overlap/spuck.position.x >= $enemies/met.position.x:
					audio.play_sound("bounce")
					$overlap/spuck/anim.play("boing")
					spa_move = false
					meta = true
					state += 1
		4:
			if global.player_weap[0] == 3:
				audio.play_sound('shoot_a')
				$overlap/spuck2.show()
				spb_move = true
				change_sprite(true)
				state += 1
				
			if global.player_weap[0] == 4:
				audio.play_sound('def_bullet')
				metshot += 1
				$overlap/metbullet.show()
				state += 1
		5:
			
			if global.player_weap[0] == 1:
				if $demo_plyr.position.x >= $enemies/telly2.position.x - 20:
					x_dir = 0
					jump(1)
					state += 1
			
			if global.player_weap[0] == 2:
				if $demo_plyr.position.x >= $enemies/telly2.position.x - 20:
					x_dir = 0
					jump(1)
					state += 1
			
			if global.player_weap[0] == 3:
				if $overlap/spuck2.position.x >= $enemies/met2.position.x:
					audio.play_sound("bounce")
					$overlap/spuck2/anim.play("boing")
					spb_move = false
					metb = true
					state += 1
			
			if global.player_weap[0] == 4:
				if $overlap/metbullet.position.x < $overlap/ashield.position.x + 8:
					audio.play_sound('dink')
					metshot += 1
					state += 1
		6:
			if global.player_weap[0] == 1:
				if vel.y > 0:
					x_dir = 1
					skick = true
					skick_time = 15
					$skick/anim.play("air")
					$skick.show()
			
			if global.player_weap[0] == 2:
				if $demo_plyr.position.x >= $enemies/telly4.position.x - 48:
					jump(1)
					state += 1
					
			if global.player_weap[0] == 4:
				if $overlap/metbullet.position.x > $enemies/met2.position.x - 4:
					audio.play_sound('hit')
					var boom = load('res://scenes/effects/s_explode.tscn').instance()
					boom.position = $enemies/met2.position
					$overlap.add_child(boom)
					$enemies/met2.hide()
					$overlap/metbullet.hide()
					metshot = 0
					state += 1
		7:
			if global.player_weap[0] == 2:
				if vel.y > -150:
					$overlap/rb_blast.position = $demo_plyr.position + Vector2(0, 12)
					$overlap/rb_blast/anim.play("boom")
					$overlap/rb_blast.show()
					audio.play_sound("big_explode")
					rboost = true
					jump(0.855)
					state += 1
			
			if global.player_weap[0] == 3:
				if $overlap/spuck.is_on_wall():
					spucka_vel.x = -150
			
			if global.player_weap[0] == 4:
				as_timer_active = true
				start_timer = true
				state += 1
		8:
			if global.player_weap[0] == 2:
				if $demo_plyr.position.x >= $enemies/telly4.position.x:
					x_dir = 0
			
			if global.player_weap[0] == 3:
				if $overlap/spuck.position.x < $demo_plyr.position.x:
					audio.play_sound("bounce")
					$overlap/spuck/anim.play("boing")
					spa_move = false
					jump(1.6)
					state += 1
		9:
			if global.player_weap[0] == 2:
				if $demo_plyr.position.x >= $enemies/telly5.position.x:
					x_dir = 0
			
			if global.player_weap[0] == 3:
				if $demo_plyr.position.y < -20:
					start_text()
			
			if global.player_weap[0] == 4:
				as_timer_active = true
				start_timer = true
				state += 1
		10:
			if global.player_weap[0] == 2:
				if vel.y > 300:
					start_text()
		11:
			if global.player_weap[0] == 4:
				$demo_plyr/arrow.flip_v = true
				as_timer_active = true
				start_timer = true
				state += 1
		13:
			if global.player_weap[0] == 4:
				start_timer = true
				state += 1
		15:
			if $demo_plyr.position.x >= $enemies/telly2.position.x:
				x_dir = 0
				jump(1)
				state += 1
		16:
			if $overlap/ashield.position.y <= $enemies/telly2.position.y:
				audio.play_sound('hit')
				var boom = load('res://scenes/effects/s_explode.tscn').instance()
				boom.position = $enemies/telly2.position
				$overlap.add_child(boom)
				$enemies/telly2.hide()
				state += 1
		17:
			if $demo_plyr.is_on_floor():
				start_text()
		
	if throw and thrw_delay > 0:
		thrw_delay -= 1
	
	if thrw_delay == 0:
		throw = false
		change_sprite(throw)
		thrw_delay = 20
	
	$overlap/ashield/sprite.frame = as_state
	
	if as_state == 1 or as_state == 3:
		as_pos_delay -= 1

		if as_pos_delay == 0:
			if state < 13:
#				as_timer_active = true
				as_state += 1
			else:
				as_state -= 1
			start_timer = true
			as_pos_delay = 2
	
	if $overlap/rb_blast.frame == 2:
		match hits:
			0:
				audio.play_sound('hit')
				var boom = load('res://scenes/effects/s_explode.tscn').instance()
				boom.position = $enemies/telly.position
				$overlap.add_child(boom)
				$enemies/telly.hide()
				$enemies/telly.get_child(1).set_deferred('disabled', true)
				hits += 1

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
			if !skick and !rboost:
				change_anim("jump")
			elif skick:
				change_anim("skick_air")
			elif rboost:
				change_anim("rboost")
		elif $demo_plyr.is_on_floor() and $demo_plyr/anim.current_animation == "jump":
			audio.play_sound('land')
			if x_dir != 0:
				change_anim("run")
			else:
				if global.player != 1:
					change_anim("idle1")
				else:
					change_anim("idle2")
		elif $demo_plyr.is_on_floor() and $demo_plyr/anim.current_animation == "rboost":
			audio.play_sound('land')
			if hits == 1:
				state += 1
				start_timer = true
			rboost = false
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
	
	#Scuttle Puck Nodes.
	if spa_move:
		if state < 7:
			spucka_vel.x = 150
		spucka_vel.y += GRAVITY * delta
		
		spucka_vel = $overlap/spuck.move_and_slide(spucka_vel, Vector2(0, -1))
	
	if spb_move:
		spuckb_vel.x = 150
		spuckb_vel.y += GRAVITY * delta
		
		spuckb_vel = $overlap/spuck2.move_and_slide(spuckb_vel, Vector2(0, -1))
	
	if meta:
		if $enemies/met.position.y > -56:
			$enemies/met.position.y -= 8
		else:
			audio.play_sound('hit')
			var boom = load('res://scenes/effects/s_explode.tscn').instance()
			boom.position = $enemies/met.position
			$overlap.add_child(boom)
			$enemies/met.hide()
			meta = false
	
	if metb:
		if $enemies/met2.position.y > -56:
			$enemies/met2.position.y -= 8
		else:
			audio.play_sound('hit')
			var boom = load('res://scenes/effects/s_explode.tscn').instance()
			boom.position = $enemies/met2.position
			$overlap.add_child(boom)
			$enemies/met2.hide()
			metb = false
	
	#Attack Shield Node.
	$overlap/ashield.position = $demo_plyr.position + as_vpos.get(as_state) * as_dist
	
	if as_active:
		if as_dist < 20:
			as_dist += 4
		else:
			if state == 3:
				state += 1
		
#	if arr_pos == 0:
#		if $demo_plyr/arrow.position.y > 0:
#			$demo_plyr/arrow.flip_v = false
#			$demo_plyr/arrow.position.y = -$demo_plyr/arrow.position.y
#
#	if arr_pos == 1:
#		if $demo_plyr/arrow.position.y < 0:
#			$demo_plyr/arrow.flip_v = true
#			$demo_plyr/arrow.position.y = -$demo_plyr/arrow.position.y
	
	match metshot:
		1:
			$overlap/metbullet.position.x -= 6
		2:
			$overlap/metbullet.position.x += 6
	
	if as_timer_active:
		if as_timer > 0:
			as_timer -= 1
		
		if as_timer == 0:
			if $demo_plyr/arrow.is_visible_in_tree():
				$demo_plyr/arrow.hide()
			else:
				$demo_plyr/arrow.show()
			as_timer = 4
	else:
		if $demo_plyr/arrow.is_visible_in_tree():
			$demo_plyr/arrow.hide()
#			state += 1
#			as_timer = 30
		
					
	#Print Shit.
	if new_state != state:
		print("State: ",state,", Timer(",start_timer,"): ",act_timer,', X Direction: ',x_dir)
		new_state = state
	
	print(as_timer_active)

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
	
	if area.name == 'telly4' and rboost:
		jump(0.855)
		x_dir = 1
		state += 1
	
	if area.name == 'telly5' and rboost:
		jump(0.855)
		state += 1
	
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

func _on_anim_rboost_finished(anim_name):
	if anim_name == "boom":
		$overlap/rb_blast.hide()

func _on_anim_boing_finished(anim_name):
	$overlap/spuck.hide()
	var boom = load('res://scenes/effects/s_explode.tscn').instance()
	boom.position = $overlap/spuck.position + Vector2(0, 12)
	$overlap.add_child(boom)
	$overlap/spuck.position = Vector2(-40, 23)
	$overlap/spuck/sprite.frame = 0

func _on_anim_boingb_finished(anim_name):
	$overlap/spuck2.hide()
	var boom = load('res://scenes/effects/s_explode.tscn').instance()
	boom.position = $overlap/spuck2.position + Vector2(0, 12)
	$overlap.add_child(boom)
	
	audio.play_sound('shoot_a')
	throw = true
	change_sprite(throw)
	$overlap/spuck.show()
	spa_move = true
	start_timer = true
	state += 1
