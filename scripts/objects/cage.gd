extends Node2D

onready var world = get_parent().get_parent().get_parent()
onready var player = world.get_child(2)

var mouth_delay = 6
var plyr_damaged = 0
var mouth_flap = false

var frame = 0
var frame_offset = 0
var final_frame = 0

var kidnap = false
var kdnp_delay = 30

var placement = {
	Vector2(7, 6) : Vector2(2176, 1484),
	Vector2(7, 10) : Vector2(2176, 2443),
	Vector2(14, 6) : Vector2(3456, 1484),
	Vector2(14, 10) : Vector2(3456, 2443)
}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	
	#Set the cage into the appropriate room.
	if placement.has(world.player_room):
		if global_position != placement.get(world.player_room):
			global_position = placement.get(world.player_room)
			kidnap = false
			kdnp_delay = 8
	
	#Animate Fugue taking Wily.
	if world.boss_hp <= 0 and !kidnap and world.boss:
		kidnap = true
	
	if kidnap:
		kdnp_delay -= 1
		
		if kdnp_delay == 0:
			#Check to see how many bosses are remaining.
			var bosses = int(global.boss1_clear) + int(global.boss2_clear) + int(global.boss3_clear) + int(global.boss4_clear)
			if bosses < 4:
				$fugue.show()
				$fugue/anim.play("teleport")
	
	#Track the player's location within the room
	if player.global_position.x < global_position.x - 24 and frame != 1:
		frame = 1
	elif player.global_position.x > global_position.x + 24 and frame != 2:
		frame = 2
	elif player.global_position.x > global_position.x - 24 and player.global_position.x < global_position.x + 24 and frame != 0:
		frame = 0
	
	if player.hurt_timer != 0 and plyr_damaged == 0:
		plyr_damaged = 48
		mouth_flap = true
	
	if plyr_damaged > 0:
		mouth_delay -= 1
		plyr_damaged -= 1
		
		if mouth_delay == 0:
			if frame_offset == 3:
				frame_offset = 0
			elif frame_offset == 0:
				frame_offset = 3
			mouth_delay = 8
		
	if plyr_damaged == 0 and mouth_flap:
		mouth_delay = 8
		frame_offset = 0
		mouth_flap = false
	
	final_frame = frame + frame_offset
	
	#If the sprite frame doesn't match, match it.
	if $wily.frame != final_frame:
		$wily.frame = final_frame
