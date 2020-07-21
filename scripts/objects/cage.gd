extends Node2D

onready var world = get_parent().get_parent().get_parent()
onready var player = world.get_child(2)
onready var camera = player.get_child(9)

var mouth_delay = 6
var plyr_damaged = 0
var mouth_flap = false

var frame = 0
var frame_offset = 0
var final_frame = 0

var bosses = 0
var cage_open = false
var end_state = 0
var wily_spd = Vector2()
var scoot = 2

var kidnap = false
var kdnp_delay = 60
var leave_delay = 120

var door_dir = {
	Vector2(8, 6) : 1,
	Vector2(8, 10) : 1,
	Vector2(13, 6) : -1,
	Vector2(13, 10) : -1,
}

var placement = {
	Vector2(7, 6) : Vector2(2176, 1484),
	Vector2(7, 10) : Vector2(2176, 2444),
	Vector2(14, 6) : Vector2(3456, 1484),
	Vector2(14, 10) : Vector2(3456, 2444)
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
			kdnp_delay = 60
			leave_delay = 120
	
	#Animate Fugue taking Wily.
	if world.boss_hp <= 0 and !kidnap and world.boss:
		kidnap = true
	
	if kidnap and $wily.is_visible_in_tree():
		kdnp_delay -= 1
		
		if kdnp_delay == 0:
			#Check to see how many bosses are remaining.
			bosses = int(global.weapon1[0]) + int(global.weapon2[0]) + int(global.weapon3[0]) + int(global.weapon4[0])
			if bosses < 3:
				$fugue.show()
				$anim.play("teleport")
	
	if $anim.get_current_animation() == "hover":
		leave_delay -= 1
	
	if leave_delay == 0 and bosses < 3:
		$wily.hide()
		$anim.play_backwards("teleport")
	
	#Animate Wily escaping.
	if bosses >= 3 and player.cutscene and player.is_on_floor() and cage_open:
		
		if player.anim_st != player.LOOKUP and end_state == 0:
			player.anim_state(player.LOOKUP)
		
		leave_delay -= 1
		
		if leave_delay == 0:
			
			#Replace the doors with fake doors.
			for g in get_tree().get_nodes_in_group('vert_gate'):
				g.disable(true)
				var fake = load('res://scenes/objects/fake_gate.tscn').instance()
				fake.position = g.global_position
				world.get_child(1).get_child(1).add_child(fake)
				world.get_child(1).get_child(1).move_child(fake, 3)
			
			$anim_b.play("door")
			if door_dir.has(world.player_room):
				player.anim_state(player.IDLE)
				player.x_dir = door_dir.get(world.player_room)
				if player.x_dir == -1:
					$wily.flip_h = true
				self.move_child($wily, 1)
				$anim.play("wily-fall")
				world.sound('fall')
				end_state += 1
	
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
	if $wily.frame != final_frame and !cage_open:
		$wily.frame = final_frame
	
	match end_state:
		1:
			wily_spd.y += 10 * delta
			if wily_spd.y > 500:
				wily_spd.y = 500
			$wily.position.y += wily_spd.y
			
			if $wily.global_position.y > camera.limit_bottom - 47:
				$wily.global_position.y = camera.limit_bottom - 47
				player.x_dir = 0
				world.kill_se('fall')
				world.sound('faceplant')
				$anim.play("wily-land")
				end_state += 1
		
		2:
			if player.anim_st == player.IDLE:
				if $wily.global_position.x > player.global_position.x:
					player.x_dir = 1
				else:
					player.x_dir = -1
				end_state += 1
		
		3:
			player.x_dir = 0
			end_state += 1
		
		4:
			if $wily.frame == 10:
				if $wily.flip_h:
					$wily.position.x += 0.25
				else:
					$wily.position.x -= 0.25
		5:
			if $wily.global_position.x > camera.limit_left + 20 and $wily.global_position.x < camera.limit_right - 20:
				if $wily.flip_h:
					$wily.position.x -= 2
				else:
					$wily.position.x += 2
			else:
				$anim.stop()
				world.sound('shutter')
				for f in get_tree().get_nodes_in_group('fake_gate'):
					f.get_child(1).play('opening')
				end_state += 1
		
		6:
			for f in get_tree().get_nodes_in_group('fake_gate'):
				if f.open:
					$anim.play("wily-run")
					end_state = 7
		
		7:
			if $wily.global_position.x > camera.limit_left - 20 and $wily.global_position.x < camera.limit_right + 20:
				if $wily.flip_h:
					$wily.position.x -= 2
				else:
					$wily.position.x += 2
			else:
				$wily.hide()
				world.sound('shutter')
				for f in get_tree().get_nodes_in_group('fake_gate'):
					f.get_child(1).play_backwards('opening')
				end_state += 1
		8:
			for f in get_tree().get_nodes_in_group('fake_gate'):
				if f.closed:
					f.queue_free()
					
					for g in get_tree().get_nodes_in_group('vert_gate'):
						g.disable(false)
					
					end_state = 9
		
		9:
			world.play_music('main')
			player.cutscene(false)
			end_state = 10
					

func _on_anim_finished(anim_name):
	match anim_name:
		"teleport":
			if kidnap:
				if leave_delay > 0:
					$anim.play("hover")
				else:
					$fugue.hide()
		
		"wily-land":
			$anim.play("wily-blink")
		
		"wily-blink":
			$anim.play("wily-shuffle")
		
		"wily-shuffle":
			if scoot > 0:
				$anim.play("wily-shuffle")
				scoot -= 1
			else:
				if $wily.flip_h:
					$wily.flip_h = false
				else:
					$wily.flip_h = true
				$anim.play("wily-run")
				end_state += 1
				


