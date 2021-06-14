extends KinematicBody2D

onready var world = get_parent().get_parent().get_parent()
onready var player = world.get_child(2)
onready var camera = player.get_child(9)

const DELAY_MAX = 60

var dir = -1

var delay = 0

var top = 0
var bottom = 0

func _ready():
	top = camera.limit_top + 8
	bottom = camera.limit_bottom - 8
	
	delay = DELAY_MAX

func _physics_process(delta):
	
	#Subtract from delay
	if delay > 0:
		delay -= 1
	
	#Move spike when delay hits 0.
	if delay == 0:
		if global_position.y > top and dir == -1:
			global_position.y -= 2
		
		if global_position.y < bottom and dir == 1:
			global_position.y += 2
		
		if global_position.y == top and dir == -1 or global_position.y == bottom and dir == 1:
			dir = -dir
			delay = DELAY_MAX

func _on_top_check_body_entered(body):
	if body.name != "player":
		if dir == -1:
			dir = -dir
			delay = DELAY_MAX

func _on_bottom_check_body_entered(body):
	if body.name != "player":
		if dir == 1:
			dir = -dir
			delay = DELAY_MAX

func _on_plyr_check_body_entered(body):
	if body.name == "player":
		if !world.dead and player.blink_timer == 0 and player.hurt_timer == 0:
			global.player_life[0] = 0
			global.player_life[1] = 0
			world.dead = true
			player.can_move = false
			audio.stop_all_music()
			get_tree().paused = true
