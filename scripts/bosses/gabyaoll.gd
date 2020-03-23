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

var velocity = Vector2()

func _ready():
	$anim_b.play("elec")

func _physics_process(delta):
	
	if prev_t != type and !move:
		$anim_a.play("idle-"+str(type - 1))
		$sprite.show()
	
	if move:
		sic_em = floor(global_position.y - player.global_position.y)
		
		if !fire:
			if type != 1:
				velocity.x = dir * SPEED
			else:
				if sic_em != 3:
					velocity.x = dir * SPEED
				else:
					velocity.x = dir * (SPEED * 3)
		else:
			velocity.x = 0
		velocity.y == 900 * delta
		
		velocity = move_and_slide(velocity, Vector2(0, -1))
		
		if type > 1:
			time -= 1
			
		if type == 2:
			if time == 0:
				match elec_st:
					2:
						$sprite/elec.hide()
						elec_st = 0
						time = 60
					1:
						$sprite/elec.show()
						$anim_a.play("idle-1")
						time = 60
						elec_st += 1
					0:
						$anim_a.play("warning-1")
						elec_st += 1
						time = 60
		elif type == 3:
			if time == 0:
				if !fire and missiles < 1:
					$anim_a.play("fire-2")
					var missile = load("res://scenes/bosses/missile.tscn").instance()
					missile.position = player.global_position + Vector2(0, -16)
					world.get_child(3).add_child(missile)
					fire = true
					missiles += 1
					time = 60
		
		if global_position.x < camera.limit_left + 32 or global_position.x > camera.limit_right - 32:
			var boom = load("res://scenes/effects/l_explode.tscn").instance()
			boom.global_position = global_position
			world.get_child(3).add_child(boom)
			queue_free()

func _on_anim_a_finished(anim_name):
	if anim_name == "fire-2":
		fire = false
