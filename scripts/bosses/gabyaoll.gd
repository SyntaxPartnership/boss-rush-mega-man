extends KinematicBody2D

onready var world = get_parent().get_parent()
onready var player = world.get_child(2)
onready var camera = player.get_child(9)

const SPEED = 40

var prev_t = 0
var type = 0
var move = false
var dir = 0

var missiles = 0
var time = 60
var state = 0
var fire = false
var elec_st = 0
var sic_em = 0
var drop = false
var reverse = false

var velocity = Vector2()

var damage = 30
var beam_dmg = 60

var overlap = []

var kill_weap = []

func _ready():
	$anim_b.play("elec")
	
	if type == 1:
		time = round(rand_range(10, 60))
	
	if drop:
		$anim_a.play("idle-"+str(type - 1))
		$sprite.show()

func _physics_process(delta):
	
	if prev_t != type and !move:
		$anim_a.play("idle-"+str(type - 1))
		$sprite.show()
	
	if move:
		sic_em = floor(global_position.y - player.global_position.y)
		
		if !fire:
			if is_on_floor():
				
				if dir == 0:
					if player.global_position.x < global_position.x:
						dir = -1
					else:
						dir = 1
				
				if type != 1:
					velocity.x = dir * SPEED
				else:
					if sic_em != 3:
						velocity.x = dir * SPEED
					else:
						velocity.x = dir * (SPEED * 3)
		else:
			velocity.x = 0
		velocity.y += 900 * delta
		
		velocity = move_and_slide(velocity, Vector2(0, -1))
		
		if type > 1:
			time -= 1
			
		if type == 2:
			if time == 0:
				match elec_st:
					2:
						$sprite/elec.hide()
						$beam_box/beam.set_deferred('disabled', true)
						elec_st = 0
						time = 60
					1:
						$sprite/elec.show()
						world.sound('elec')
						$beam_box/beam.set_deferred('disabled', false)
						$anim_a.play("idle-1")
						time = 60
						elec_st += 1
					0:
						$anim_a.play("warning-1")
						elec_st += 1
						time = 60
		elif type == 3:
			if time == 0:
				if !fire and missiles < 2:
					$anim_a.play("fire-2")
					var missile = load("res://scenes/bosses/missile.tscn").instance()
					missile.position = global_position + Vector2(0, -8)
					world.get_child(3).add_child(missile)
					fire = true
					missiles += 1
					time = 90
		
		overlap = $hitbox.get_overlapping_bodies()
		
		if overlap != []:
			for body in overlap:
				if body.name == 'player':
					if body.s_kick:
						body.kick_rebound()
						kill_gaby()
					else:
						damage = 30
						world.calc_damage(body, self)
				
				if body.name == 'attack_shield':
					body._on_screen_exited()
					kill_gaby()
				
				if body.name == "scuttle_puck":
					if !reverse:
						dir = -dir
						if body.bounce == 1:
							body.bounce = 0
						else:
							body.bounce = 1
						reverse = true
		
		kill_weap = $beam_box.get_overlapping_bodies()
		
		if kill_weap != []:
			for body in kill_weap:
				if body.is_in_group('weapons') and body.is_in_group("adaptor_dmg"):
					if body.name != 'roto_boost' and body.name != 'mega_arm':
						var boom = load("res://scenes/effects/s_explode.tscn").instance()
						boom.global_position = body.global_position
						world.get_child(3).add_child(boom)
						body.queue_free()
					if body.name == 'mega_arm':
						if !body.ret:
							body.ret()
				
				if body.name == 'player':
					damage = 60
					world.calc_damage(body, self)
		
		if global_position.x < camera.limit_left + 32 or global_position.x > camera.limit_right - 32:
			kill_gaby()

func kill_gaby():
	var boom = load("res://scenes/effects/l_explode.tscn").instance()
	boom.global_position = global_position
	world.get_child(3).add_child(boom)
	queue_free()

func _on_anim_a_finished(anim_name):
	if anim_name == "fire-2":
		fire = false

func do_damage(body):
	match body.name:
		'player':
			if player.hurt_timer == 0 and player.blink_timer == 0 and !player.hurt_swap and !player.r_boost:
				if player.r_boost:
					player.r_boost = false
				global.player_life[int(player.swap)] -= damage
				player.damage()
