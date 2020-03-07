extends Node2D

onready var world = get_parent().get_parent().get_parent()
onready var player = world.get_child(2)
onready var camera = player.get_child(9)

var damage = 20

var dist = 32

var dink = false

var move = false
var dir = -1

func _ready():
	
	if global_position.x < camera.limit_left + 128:
		dir = 1
		$wall.position.x = -$wall.position.x
	
	$anim.play("idle")

func _physics_process(delta):
	
	if move:
		global_position.x += dir
		
		if $wall.get_overlapping_bodies() != []:
			dir = -dir
			$wall.position.x = -$wall.position.x
		
		dist -= 1
		
		if dist == 0:
			$anim.play("idle")
			dist = 32
			move = false
	
	var detect = $detect.get_overlapping_bodies()
	if detect != []:
		for body in detect:
			if body.name == "player":
				if player.r_boost:
					if !dink:
						world.sound("dink")
						$anim.play("move")
						move = true
						dink = true
					if player.global_position.x > global_position.x - 11 and player.global_position.x < global_position.x + 11 and player.global_position.y < global_position.y:
						player.velocity.y = (player.JUMP_SPEED * 0.855) / player.jump_mod
				else:
					if player.hurt_timer == 0 and player.blink_timer == 0 and !player.hurt_swap and !player.r_boost:
						global.player_life[int(player.swap)] -= damage
						player.damage()
	else:
		dink = false
