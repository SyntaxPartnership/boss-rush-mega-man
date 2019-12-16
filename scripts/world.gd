extends Node2D

signal scrolling
signal close_gate

onready var objects = $graphic/spawn_tiles/objects
onready var items = $graphic/spawn_tiles/items
onready var enemies = $graphic/spawn_tiles/enemy_map

#Object constants
const DEATH_BOOM = preload('res://scenes/effects/s_explode_loop.tscn')

# warning-ignore:unused_class_variable
var fade_state

#Determines player position in the game world.
var pos = Vector2()
var player_tilepos = Vector2()
var stand_on
var overlap
var ladder_set
var ladder_top
var player_room = Vector2(0, 0)
var spawn_pt
var boss = false
var hurt_swap = false
var dead = false
var dead_delay = 24
var restart = 360
var life_en = 0
var wpn_en = 0
var heal_delay = 0
var id = 0
var p_menu = false
var swapping = false
var shots = 0
var adaptors = 0

#Item Drops
var item = []

#Camera values
var res = Vector2()
var center = Vector2()

var cam_move = 0
var cam_allow = []
var scroll = false
var scroll_len = 0
var scroll_spd = 4

#Replace with better functions later
var rooms = 0
var prev_room = Vector2(0, 0)
var endless = false
var endless_rms = []
var screens = 0
var shake = 0
var enemy_count = 0

#Reference. The following dictionary contains data for the rooms loaded into the game. The key is the room coordinates. The first four numbers hold values for cam_allow.
#The final two hold how many rooms that particular area can scroll before stopping and which direction to scroll (1 for right, -1 for left). If rooms has a 0, ignore the
#scrolling section of the code, as it will only change the screen transitions.

var room_data = {
				#Null and void due to the game only having single rooms.
				}

var boss_rooms = {#Insert boss room coordinates here.
				}

# warning-ignore:unused_class_variable
var got_items = {
				}

#Color Variables.
var palette = [Color('#000000'), Color('#000000'), Color('#000000')]

var tele_timer = 60
var tele_dest

#Special effects
var spl_trigger = false
var bbl_count = 0

func _ready():
	res = get_viewport_rect().size
	
	#Hide Object and Enemy Layers
	objects.hide()
	enemies.hide()
	items.hide()
	
	#Spawn stage objects.
	spawn_objects()
	
	#Add Continue and Spawn Scripts here
	cam_allow = [1, 1, 1, 1]
	
	#Set lives counter.
	$hud/hud/lives.set_text(str(global.lives))
	
	#Set player position and reset camera.
	for spawn in $coll_mask/spawn_pts.get_used_cells():
		var spawn_id = $coll_mask/spawn_pts.get_cellv(spawn)
		var spawn_type = $coll_mask/spawn_pts.tile_set.tile_get_name(spawn_id)
		if spawn_type in ['sp_'+str(global.level_id)+'_'+str(global.cont_id)]:
			var spawn_pos = $coll_mask/spawn_pts.map_to_world(spawn)
			$player.position.x = spawn_pos.x + $coll_mask/spawn_pts.cell_size.x
			$player.position.y = spawn_pos.y + $coll_mask/spawn_pts.cell_size.y / 2
			
	pos = $player.position
	player_room = Vector2(floor(pos.x / 256), floor(pos.y / 240))

	$player/camera.limit_top = (player_room.y*240)
	$player/camera.limit_bottom = (player_room.y*240)+240
	$player/camera.limit_left = (player_room.x*256)
	$player/camera.limit_right = (player_room.x*256)+256
	
	_rooms()
		

# warning-ignore:unused_argument
func _input(event):
	#Weapon Swapping.
	if $player.can_move:
		#L and R Button.
		if Input.is_action_just_pressed("prev"):
			global.player_weap[int($player.swap)] -= 1
			$player.w_icon = 64
			kill_weapons()
			palette_swap()
		if Input.is_action_just_pressed("next"):
			global.player_weap[int($player.swap)] += 1
			$player.w_icon = 64
			kill_weapons()
			palette_swap()
		
		#Skip Unacquired Weapons.
		if Input.is_action_just_pressed("next"):
			#Skip Rush/Proto Jet if if playing as Mega/Proto Man and hasn't been acquired. Skip altogether if playing as Bass.
			if global.player_weap[int($player.swap)] == 2 and !global.rp_jet[0] or global.player_weap[int($player.swap)] == 2 and global.player != 0:
				global.player_weap[int($player.swap)] += 1
			#Skip unacquired Master Weapons
			if global.player_weap[int($player.swap)] == 3 and !global.weapon1[0]:
				global.player_weap[int($player.swap)] += 1
			if global.player_weap[int($player.swap)] == 4 and !global.weapon2[0]:
				global.player_weap[int($player.swap)] += 1
			if global.player_weap[int($player.swap)] == 5 and !global.weapon3[0]:
				global.player_weap[int($player.swap)] += 1
			if global.player_weap[int($player.swap)] == 6 and !global.weapon4[0]:
				global.player_weap[int($player.swap)] += 1
			if global.player_weap[int($player.swap)] == 7 and !global.weapon5[0]:
				global.player_weap[int($player.swap)] += 1
			if global.player_weap[int($player.swap)] == 8 and !global.weapon6[0]:
				global.player_weap[int($player.swap)] += 1
			if global.player_weap[int($player.swap)] == 9 and !global.weapon7[0]:
				global.player_weap[int($player.swap)] += 1
			if global.player_weap[int($player.swap)] == 10 and !global.weapon8[0]:
				global.player_weap[int($player.swap)] += 1
			#Skip player specific adaptors.
			if global.player_weap[int($player.swap)] == 11 and !global.beat[0] and global.player == 0:
				global.player_weap[int($player.swap)] += 1
			if global.player_weap[int($player.swap)] == 11 and !global.tango[0] and global.player == 1:
				global.player_weap[int($player.swap)] += 1
			if global.player_weap[int($player.swap)] == 11 and !global.reggae[0] and global.player == 2:
				global.player_weap[int($player.swap)] += 1
		
		if Input.is_action_just_pressed("prev"):
			#These skips are done in reverse order to make them move to the next item seemlessly.
			if global.player_weap[int($player.swap)] == 11 and !global.beat[0] and global.player == 0:
				global.player_weap[int($player.swap)] -= 1
			if global.player_weap[int($player.swap)] == 11 and !global.tango[0] and global.player == 1:
				global.player_weap[int($player.swap)] -= 1
			if global.player_weap[int($player.swap)] == 11 and !global.reggae[0] and global.player == 2:
				global.player_weap[int($player.swap)] -= 1
			#Master Weapons
			if global.player_weap[int($player.swap)] == 10 and !global.weapon8[0]:
				global.player_weap[int($player.swap)] -= 1
			if global.player_weap[int($player.swap)] == 9 and !global.weapon7[0]:
				global.player_weap[int($player.swap)] -= 1
			if global.player_weap[int($player.swap)] == 8 and !global.weapon6[0]:
				global.player_weap[int($player.swap)] -= 1
			if global.player_weap[int($player.swap)] == 7 and !global.weapon5[0]:
				global.player_weap[int($player.swap)] -= 1
			if global.player_weap[int($player.swap)] == 6 and !global.weapon4[0]:
				global.player_weap[int($player.swap)] -= 1
			if global.player_weap[int($player.swap)] == 5 and !global.weapon3[0]:
				global.player_weap[int($player.swap)] -= 1
			if global.player_weap[int($player.swap)] == 4 and !global.weapon2[0]:
				global.player_weap[int($player.swap)] -= 1
			if global.player_weap[int($player.swap)] == 3 and !global.weapon1[0]:
				global.player_weap[int($player.swap)] -= 1
			#Rush/Proto Jet
			if global.player_weap[int($player.swap)] == 2 and !global.rp_jet[0] or global.player_weap[int($player.swap)] == 2 and global.player != 0:
				global.player_weap[int($player.swap)] -= 1
	
		#Loop the value.
		if global.player_weap[int($player.swap)] < 0:
			global.player_weap[int($player.swap)] = 11
		elif global.player_weap[int($player.swap)] > 11:
			global.player_weap[int($player.swap)] = 0
		
		#Start swap process.
		if Input.is_action_just_pressed('select') and !swapping and $player.blink_timer == 0 and $player.blink == 0:
			if $player.act_st != 13 and !$player.slide:
				if global.player_life[int(!$player.swap)] != 0:
					kill_weapons()
					$player/audio/charge.stop()
					$player.shot_delay = 0
					$player.c_flash = 0
					$player.charge = 0
					$player.w_icon = 0
					$player.shot_state($player.NORMAL)
					$player/sprite/weap_icon_lr.hide()
					$player.hide()
					$player.can_move = false
					swapping = true
					swap_out()
					if !$player.swap:
						$player.swap = true
					else:
						$player.swap = false
					swap()
					swap_in()
					$pause/pause_menu.menu_color()
					$pause/pause_menu.set_names()
					$pause/pause_menu.hide_icons()
					$pause/pause_menu.wpn_menu()
					get_tree().paused = true
			
#		palette_swap()
	
		#Pause menu
		if Input.is_action_just_pressed('start') and !$pause/pause_menu.start and !swapping:
			$pause/pause_menu.kill_wpn = global.player_weap[int($player.swap)]
			$audio/se/menu.play()
			p_menu = true
			$fade/fade.state = 6
			$fade/fade.end = true
			$player.can_move = false
			get_tree().paused = true
	
	else:
		#Return to the game.
		if Input.is_action_just_pressed('start') or Input.is_action_just_pressed('jump'):
			if $pause/pause_menu.menu == 0:
				if $pause/pause_menu.start:
					if $pause/pause_menu.kill_wpn != global.player_weap[int($player.swap)]:
						kill_weapons()
					$audio/se/bling.play()
					p_menu = false
					$fade/fade.state = 8
					$fade/fade.end = true
					$pause/pause_menu.start = false
		
	
func _camera():
	#Calculate player position.
	pos = $player.position
	pos = Vector2(floor(pos.x), floor(pos.y))
	
	#Get Center of the screen.
	center = $player/camera.get_camera_screen_center()
	center = Vector2(floor(center.x), floor(center.y))
	
	#Basic screen shaking effect. Change if needed.
	if shake > 0:
		$player/camera.set_offset(Vector2(rand_range(-2.0, 2.0), rand_range(-3.0, 3.0)))
		shake -= 1
	
	if shake == 0:
		$player/camera.set_offset(Vector2(0, 0))
	
	#FOR FUTURE REFERENCE: The cam_allow stores values for up, down, left, right in that order in the array.
	
	#Scroll up (Edge of screen)
	if pos.y < $player/camera.limit_top and cam_allow[0] == 1 and !scroll:
		kill_enemies()
		scroll = true
		scroll_len = -res.y
		cam_move = 1
		kill_effects()
		kill_weapons()
		emit_signal("scrolling")
	
	#Scroll down (Edge of screen)
	if pos.y > $player/camera.limit_bottom and cam_allow[1] == 1 and !scroll:
		kill_enemies()
		scroll = true
		scroll_len = res.y
		cam_move = 2
		kill_effects()
		kill_weapons()
		emit_signal("scrolling")
	
	#Scroll left (Edge of screen)
	if pos.x < $player/camera.limit_left + 4 and cam_allow[2] == 1 and !scroll:
		kill_enemies()
		$player/camera.limit_left = center.x - (res.x / 2)
		$player/camera.limit_right = center.x + (res.x / 2)
		scroll = true
		scroll_len = -res.x
		cam_move = 3
		kill_effects()
		kill_weapons()
		emit_signal("scrolling")
	
	#Scroll right (Edge of screen)
	if pos.x > $player/camera.limit_right - 4 and cam_allow[3] == 1 and !scroll:
		kill_enemies()
		$player/camera.limit_left = center.x - (res.x / 2)
		$player/camera.limit_right = center.x + (res.x / 2)
		scroll = true
		scroll_len = res.x
		cam_move = 4
		kill_effects()
		kill_weapons()
		emit_signal("scrolling")
	
	#Pan the camera
	if cam_move == 1 and scroll_len != 0:
		$player/camera.limit_top -= scroll_spd
		$player/camera.limit_bottom -= scroll_spd
		if !$player.gate:
			$player.position.y -= 0.125
		else:
			$player.position.y -= 0.9
		scroll_len += scroll_spd
	if cam_move == 2 and scroll_len != 0:
		$player/camera.limit_top += scroll_spd
		$player/camera.limit_bottom += scroll_spd
		if !$player.gate:
			$player.position.y += 0.125
		else:
			$player.position.y += 0.9
		scroll_len -= scroll_spd
	if cam_move == 3 and scroll_len != 0:
		$player/camera.limit_left -= scroll_spd
		$player/camera.limit_right -= scroll_spd
		if !$player.gate:
			$player.position.x -= 0.5
		else:
			$player.position.x -= 0.75
		scroll_len += scroll_spd
	if cam_move == 4 and scroll_len != 0:
		$player/camera.limit_left += scroll_spd
		$player/camera.limit_right += scroll_spd
		if !$player.gate:
			$player.position.x += 0.5
		else:
			$player.position.x += 0.75
		scroll_len -= scroll_spd
	
	#Resume Control
	if cam_move != 0 and scroll_len == 0:
		if !$player.gate:
			scroll = false
			cam_move = 0
			emit_signal("scrolling")
		else:
			emit_signal("close_gate")
	
	#Check room to see if camera value changes. This will only check rooms when the game is
	#not performing a screen transition.
	if prev_room != player_room and !scroll:
		prev_room = player_room
		_rooms()
		
#	Certain special conditions for allowing camera movement can be allowed as well. Such as player position within a room.
#	if $player.position.y < ($player/camera.limit_bottom - 120) and player_room == Vector2(7, 10) and !scroll:
#		_rooms()
#
#	if $player.position.y > ($player/camera.limit_bottom - 120) and player_room == Vector2(7, 10) and !scroll:
#		_rooms()

func _rooms():
	#This section handles the Left/Right camera limits and toggles which direction the screen
	#is allowed to scroll based on the player_room value.
	print(player_room)
	
	#This function also houses the counter for Endless Mode.
	if endless:
		if !endless_rms.has(player_room):
			endless_rms.insert(endless_rms.size(), player_room)
			screens += 1
	
	#Add function here to clear endless_rms to prevent lag. (Example: When the player reaches a teleporter, clear endless_rms)
	
	if room_data.has(str(player_room)):
		#Set camera allow values.
		cam_allow[0] = room_data.get(str(player_room))[0]
		cam_allow[1] = room_data.get(str(player_room))[1]
		cam_allow[2] = room_data.get(str(player_room))[2]
		cam_allow[3] = room_data.get(str(player_room))[3]
		#Set scrolling.
		if room_data.get(str(player_room))[4] != 0:
			#Is it a single room area?
			if room_data.get(str(player_room))[4] != 1:
				if room_data.get(str(player_room))[5] == 1:
					$player/camera.limit_right = $player/camera.limit_left + (res.x * room_data.get(str(player_room))[4])
				else:
					$player/camera.limit_left = $player/camera.limit_right - (res.x * room_data.get(str(player_room))[4])
			else:
				$player/camera.limit_right = (player_room.x * res.x) + res.x
				$player/camera.limit_left = player_room.x * res.x
				
			
		#Check tilemap for enemies. If so, place them.
	if enemy_count == 0:
		var enemy_loc = []
		var enemy_name = []
		
		var x_tiles = $player/camera.limit_left / 16
		var y_tiles = player_room.y * 15
		
		if room_data.has(str(player_room)):
			rooms = room_data.get(str(player_room))[4]
		else:
			rooms = 1
		
		for y in range(y_tiles, y_tiles + 15):
			#Use separate actions depending on if the room is in the dictionary or not.
			for x in range(x_tiles, x_tiles + (rooms * 16)):
				if enemies.get_cell(x, y) != -1:
						enemy_loc.append(Vector2(x, y))
		
		for id in(enemy_loc):
			var e_id = enemies.get_cellv(id)
			var e_type = enemies.tile_set.tile_get_name(e_id)
			if !enemy_name.has(e_type):
				enemy_name.append(e_type)
			if e_type in enemy_name:
				var e = load("res://scenes/enemies/"+e_type+".tscn").instance()
				var e_pos = enemies.map_to_world(id)
				e.position = e_pos + (enemies.cell_size / 2)
				$graphic/spawn_tiles.add_child(e)
				enemy_count += 1
		
		#Make items appear.
		var see_item = get_tree().get_nodes_in_group('items')
		
		for s in see_item:
			s.get_child(0).show()
	
#warning-ignore:unused_argument
func _process(delta):
	_camera()
	#Print Shit
	
	#Get other player information.
	player_tilepos = $coll_mask/tiles.world_to_map(pos)
	stand_on = $coll_mask/tiles.get_cellv(Vector2(player_tilepos.x, player_tilepos.y + 1))
	overlap = $coll_mask/tiles.get_cellv(player_tilepos)
	ladder_set = (player_tilepos.x * 16) + 8
	ladder_top = $coll_mask/tiles.map_to_world(player_tilepos)
	player_room = Vector2(floor(pos.x / 256), floor(pos.y / 240))
	spawn_pt = $coll_mask/spawn_pts.get_cellv($coll_mask/spawn_pts.world_to_map(Vector2(pos.x - 4, pos.y)))
	
	#Pause the game if life_en or wpn_en is greater than 0.
	if wpn_en != 0 and !get_tree().paused and !p_menu or life_en != 0 and !get_tree().paused and !p_menu:
		get_tree().paused = true
	
	#Refill the necessary energy.
	if wpn_en != 0 or life_en != 0:
		heal_delay += 1
	
	#Loop the counter
	if heal_delay > 1:
		heal_delay = 0
	
	#Refill life
	if life_en > 0 and heal_delay == 1:
		$audio/se/meter.play()
		global.player_life[int($player.swap)] += 10
		life_en -= 10
	
	#Refill weapons
	if wpn_en > 0 and heal_delay == 1:
		$audio/se/meter.play()
		$player.wpn_lvl[id][int($player.swap) + 1] += 10
		wpn_en -= 10
	
	#Allow the player to move again.
	if life_en == 0 and wpn_en == 0 and get_tree().paused and !p_menu and !hurt_swap:
		get_tree().paused = false
	
	#Check to see if the player's weapons or adaptors have gone beyond the screen.
	var get_weaps = get_tree().get_nodes_in_group("weapons")
	var get_adaps = get_tree().get_nodes_in_group("adaptors")
	
	if get_weaps.size() > 0 or get_adaps.size() > 0:
		for w in get_weaps:
			if w.global_position.y < $player/camera.limit_top - 16 or w.global_position.y > $player/camera.limit_bottom + 16 or w.global_position.x < $player/camera.get_camera_screen_center().x - 144 or w.global_position.x > $player/camera.get_camera_screen_center().x + 144:
				w._on_screen_exited()
		
		for a in get_adaps:
			if a.global_position.y < $player/camera.limit_top - 16 or a.global_position.y > $player/camera.limit_bottom + 16 or a.global_position.x < $player/camera.get_camera_screen_center().x - 144 or a.global_position.x > $player/camera.get_camera_screen_center().x + 144:
				a._on_screen_exited()
	
	#Force the player to swap if one character dies.
	if global.player_life[0] <= 0 and global.player_life[1] > 0 and !$player.swap or global.player_life[0] > 0 and global.player_life[1] <= 0 and $player.swap:
		if !hurt_swap:
			hurt_swap = true
			if $player.act_st != 13 and !$player.slide:
				kill_weapons()
				kill_effects()
				$player/audio/charge.stop()
				$player/audio/hurt.stop()
				$player.shot_delay = 0
				$player.c_flash = 0
				$player.charge = 0
				$player.w_icon = 0
				$player.hurt_timer = 0
				$player.blink_timer = 96
				$player.hurt_swap = true
				$player.shot_state($player.NORMAL)
				$player/sprite/weap_icon_lr.hide()
				$player.hide()
				swapping = true
				swap_out()
				if !$player.swap:
					$player.swap = true
				else:
					$player.swap = false
				swap()
				$pause/pause_menu.menu_color()
				$pause/pause_menu.set_names()
				$pause/pause_menu.wpn_menu()
				swap_in()
				get_tree().paused = true
	
	#If the player is dead, run the kill script.
	if $player.position.y > $player/camera.limit_bottom + 24 and !dead:
		global.player_life[0] = 0
		global.player_life[1] = 0
		dead = true
		$player.can_move = false
		get_tree().paused = true
		$player.hide()
		
	if global.player_life[0] <= 0 and global.player_life[1] <= 0 and !dead:
		dead = true
		$player.can_move = false
		get_tree().paused = true
	
	if dead and dead_delay > -1:
		dead_delay -= 1
	
	if dead and dead_delay == 0:
		if $player.is_visible():
			$audio/se/death.play()
			$player.hide()
			for n in range(16):
				var boom = DEATH_BOOM.instance()
				boom.position = $player.position
				boom.id = n
				$overlap.add_child(boom)
		else:
			$audio/se/death.play()
		get_tree().paused = false
			
	if dead and dead_delay < 0 and restart > -1:
		restart -= 1
	
	if dead and dead_delay < 0 and restart == 0:
		if !$fade/fade.end:
			$fade/fade.state = 4
			$fade/fade.end = true
	
	#Right Analog Stick
	
	#Teleporters
	if spawn_pt != -1 and $player.is_on_floor():
		if spawn_pt >= 49 and spawn_pt <= 68 and !$player.lock_ctrl:
			$player.lock_ctrl = true
			$player.anim_state(2)
			$player.slide = false
			$player.slide_timer = 0
			tele_timer = 60
			tele_dest = spawn_pt + 20
	
	if $player.lock_ctrl and tele_timer > -1:
		tele_timer -= 1
	
	if tele_timer == 0:
		$player.can_move = false
		$audio/se/appear.play()
		$player/anim.play('appear1')
			
	
	#Special Effects
	if overlap == 7 and !spl_trigger:
		splash()
		spl_trigger = true
	elif overlap != 7 and spl_trigger:
		spl_trigger = false
		
	if overlap == 6 or overlap == 12 or overlap == 13:
		if bbl_count == 0 and !scroll:
			bubble()
		
	
	#Debug Menus and Statistics.
	
	#Debug Menu
	if Input.is_key_pressed(KEY_F1) and global.debug_menu == 0:
		global.debug_menu += 1
		get_tree().paused = true
		$debug_menu/menu.show()
	if !Input.is_key_pressed(KEY_F1) and global.debug_menu == 1:
		global.debug_menu += 1
	if Input.is_key_pressed(KEY_F1) and global.debug_menu == 2:
		global.debug_menu += 1
		get_tree().paused = false
		$debug_menu/menu.hide()
	if !Input.is_key_pressed(KEY_F1) and global.debug_menu == 3:
		global.debug_menu = 0
	
	#Debug stats
	if Input.is_key_pressed(KEY_F2) and global.debug_stats == 0:
		global.debug_stats += 1
		get_tree().paused = true
		$debug_stats/debug.show()
	if !Input.is_key_pressed(KEY_F2) and global.debug_stats == 1:
		global.debug_stats += 1
	if Input.is_key_pressed(KEY_F2) and global.debug_stats == 2:
		global.debug_stats += 1
		get_tree().paused = false
		$debug_stats/debug.hide()
	if !Input.is_key_pressed(KEY_F2) and global.debug_stats == 3:
		global.debug_stats = 0
	
	#Debug Stats
	if global.debug_stats == 1:
#		#Debug Information.
#		$debug1/posx.set_text(str(pos.x))				#Player X Position
#		$debug1/posy.set_text(str(pos.y))				#Player Y Position
#		$debug1/tpos.set_text(str(player_tilepos))		#Tile that the player is occupying
#		$debug1/room.set_text(str(player_room))			#Room that the player is occupying
#		$debug1/cam_allow.set_text(str(cam_allow))		#Which way the camera can pan, if at all.
#		$debug1/state.set_text(str($player.state))		#Which state the player is in.
#		$debug1/anim.set_text(str($player.anim))		#Which animation is playing.
#		$debug1/anim.set_uppercase(true)				#Set anim text to uppercase.
#
#		if stand_on == -1:								#Tile ID that the player is standing on.
#			$debug1/stand_on.set_text('NULL')
#		if stand_on == 0:
#			$debug1/stand_on.set_text('FLOOR')
#		if stand_on == 1:
#			$debug1/stand_on.set_text('SNOW')
#		if stand_on == 2:
#			$debug1/stand_on.set_text('ICE')
#		if stand_on == 3:
#			$debug1/stand_on.set_text('LADDER')
#		if stand_on == 5:
#			$debug1/stand_on.set_text('DEATH')
#		if stand_on == 6 or stand_on == 7:
#			$debug1/stand_on.set_text('WATER')
#		if stand_on == 8:
#			$debug1/stand_on.set_text('SLW R CONV')
#		if stand_on == 9:
#			$debug1/stand_on.set_text('FST R CONV')
#		if stand_on == 10:
#			$debug1/stand_on.set_text('SLW L CONV')
#		if stand_on == 11:
#			$debug1/stand_on.set_text('FST L CONV')
#
#		if overlap == -1:								#Tile the player is overlapping. Add to for new tiles.
#			$debug1/overlap.set_text('NULL')
#		if overlap == 3:
#			$debug1/overlap.set_text('LADDER')
#		if overlap == 4:
#			$debug1/overlap.set_text('LADDER')
#		if overlap == 6 or overlap == 7:
#			$debug1/overlap.set_text('WATER')
#
#		$debug1/ladder_set.set_text(str(ladder_set))	#X coordinate of where the player will be snapped to when grabbing a ladder.
#		$debug1/xvelocity.set_text(str(floor($player.velocity.x)))
#		$debug1/yvelocity.set_text(str(floor($player.velocity.y)))
#		$debug1/act_state.set_text(str($player.act_state))
#		$debug1/act_state.set_uppercase(true)
#		$debug1/collide.set_text(str($player.tile_name))
#		$debug1/collide.set_uppercase(true)
		
		$debug_stats/debug/fps.set_text(str(Engine.get_frames_per_second()))#Display frames per second.
	
#	if shots < 0:
#		shots = 0

#These functions handle the states of the fade in node.
func _on_fade_fadein():
	
	if $fade/fade.state == 3 and $player.lock_ctrl:
		$player/anim.stop(true)
		$player.show()
		$audio/se/appear.play()
		$player/anim.play('appear1')
		$player.lock_ctrl = false
	
	if $fade/fade.state == 7:
		$pause/pause_menu.start = true
	
	if $fade/fade.state == 9:
		get_tree().paused = false
		$player.can_move = true

func _on_fade_fadeout():
	if $fade/fade.state == 2:

		for teleport in $coll_mask/spawn_pts.get_used_cells():
			var tele_id = $coll_mask/spawn_pts.get_cellv(teleport)
			if tele_id == tele_dest:
				var tele_pos = $coll_mask/spawn_pts.map_to_world(teleport)
			
				$player.position.x = tele_pos.x + $coll_mask/spawn_pts.cell_size.x
				$player.position.y = tele_pos.y + $coll_mask/spawn_pts.cell_size.y / 2

		$player/camera.limit_top = ((floor($player.position.y/240))*240)
		$player/camera.limit_bottom = ((floor($player.position.y/240))*240)+240
		$player/camera.limit_left = ((floor($player.position.x/256))*256)
		$player/camera.limit_right = ((floor($player.position.x/256))*256)+256

		$fade/fade.begin = true
		$fade/fade.state = 3
	
	if $fade/fade.state == 4:
		if global.lives > 0:
			global.player_life[0] = 280
			if global.player_id[1] != 99:
				global.player_life[1] = 280
			global.player_weap[0] = 0
			global.player_weap[1] = 0
			global.lives -= 1
# warning-ignore:return_value_discarded
			get_tree().reload_current_scene()
		else:
			global.game_over = true
# warning-ignore:return_value_discarded
			get_tree().change_scene("res://scenes/menu.tscn")
	
	if $fade/fade.state == 6:
		$pause/pause_menu.show()
		$fade/fade.begin = true
		$fade/fade.state = 7
	
	if $fade/fade.state == 8:
		$pause/pause_menu.hide()
		$fade/fade.begin = true
		$fade/fade.state = 9

func palette_swap():
	#Set palettes for the player.
	#Character specific palettes.
	#Mega Man
	if global.player == 0:
		#Default palette
		if global.player_weap[int($player.swap)] == 0 or global.player_weap[int($player.swap)] == 11:
			if $player.charge == 0:
				palette[0] = global.black
				palette[1] = global.blue2
				palette[2] = global.blue1
		
			#Charge 1
			if $player.charge >= 32 and $player.charge < 96 and $player.c_flash == 0:
				palette[0] = global.black
			if $player.charge >= 32 and $player.charge < 48 and $player.c_flash == 2:
				palette[0] = global.pink3
			if $player.charge >= 48 and $player.charge < 64 and $player.c_flash == 2:
				palette[0] = global.pink2
			if $player.charge >= 64 and $player.charge < 96 and $player.c_flash == 2:
				palette[0] = global.pink1
				
			#Charge 2
			if $player.charge >= 96 and $player.c_flash == 0:
				palette[0] = global.black
				palette[1] = global.blue2
				palette[2] = global.blue1
			if $player.charge >= 96 and $player.c_flash == 2:
				palette[0] = global.blue2
				palette[1] = global.blue1
				palette[2] = global.black
			if $player.charge >= 96 and $player.c_flash == 4:
				palette[0] = global.blue1
				palette[1] = global.black
				palette[2] = global.blue2
			if $player.charge >= 96 and $player.c_flash == 6:
				palette[1] = global.grey0
	
	#Proto Man
	if global.player == 1:
		if global.player_weap[int($player.swap)] == 0:
			if $player.charge == 0:
				palette[0] = global.black
				palette[1] = global.red3
				palette[2] = global.grey1
		
			#Charge 1
			if $player.charge >= 32 and $player.charge < 96 and $player.c_flash == 0:
				palette[0] = global.black
			if $player.charge >= 32 and $player.charge < 48 and $player.c_flash == 2:
				palette[0] = global.purple3
			if $player.charge >= 48 and $player.charge < 64 and $player.c_flash == 2:
				palette[0] = global.purple2
			if $player.charge >= 64 and $player.charge < 96 and $player.c_flash == 2:
				palette[0] = global.purple1
				
			#Charge 2
			if $player.charge >= 96 and $player.c_flash == 0:
				palette[0] = global.black
				palette[1] = global.red3
				palette[2] = global.grey1
			if $player.charge >= 96 and $player.c_flash == 2:
				palette[0] = global.red3
				palette[1] = global.grey1
				palette[2] = global.black
			if $player.charge >= 96 and $player.c_flash == 4:
				palette[0] = global.grey1
				palette[1] = global.black
				palette[2] = global.red3
			if $player.charge >= 96 and $player.c_flash == 6:
				palette[1] = global.yellow0
		
		if global.player_weap[int($player.swap)] == 11:
			palette[0] = global.black
			palette[1] = global.green2
			palette[2] = global.blue0
			
	#Bass
	if global.player == 2:
		if global.player_weap[int($player.swap)] == 0:
			palette[0] = global.black
			palette[1] = global.grey2
			palette[2] = global.brown1
		if global.player_weap[int($player.swap)] == 1:
			palette[0] = global.black
			palette[1] = global.grey2
			palette[2] = global.purple2
		if global.player_weap[int($player.swap)] == 11:
			palette[0] = global.black
			palette[1] = global.pink1
			palette[2] = global.yellow0
	
	#Shared Palettes.
	#Rush/Proto Jet.
	if global.player != 2:
		if global.player_weap[int($player.swap)] == 1 or global.player_weap[int($player.swap)] == 2:
			palette[0] = global.black
			palette[1] = global.red3
			palette[2] = global.white
	
	#Master Weapons.
	if global.player_weap[int($player.swap)] == 3:
		palette[0] = global.black
		palette[1] = global.brown3
		palette[2] = global.brown1
	if global.player_weap[int($player.swap)] == 4:
		palette[0] = global.black
		palette[1] = global.blue3
		palette[2] = global.grey2
	if global.player_weap[int($player.swap)] == 5:
		palette[0] = global.black
		palette[1] = global.green3
		palette[2] = global.lime1
	if global.player_weap[int($player.swap)] == 6:
		palette[0] = global.black
		palette[1] = global.grey3
		palette[2] = global.grey0
	if global.player_weap[int($player.swap)] == 7:
		palette[0] = global.black
		palette[1] = global.purple3
		palette[2] = global.purple1
	if global.player_weap[int($player.swap)] == 8:
		palette[0] = global.black
		palette[1] = global.grey2
		palette[2] = global.yellow1
	if global.player_weap[int($player.swap)] == 9:
		palette[0] = global.black
		palette[1] = global.pink2
		palette[2] = global.white
	if global.player_weap[int($player.swap)] == 10:
		palette[0] = global.black
		palette[1] = global.rblue2
		palette[2] = global.yellow0
	
	#Set weapon icon.
	if global.player_weap[int($player.swap)] == 0:
		if global.player != 2:
			$player/sprite/weap_icon_lr.set_frame(0)
		else:
			$player/sprite/weap_icon_lr.set_frame(1)
	if global.player_weap[int($player.swap)] == 1:
		if global.player == 0:
			$player/sprite/weap_icon_lr.set_frame(2)
		elif global.player == 1:
			$player/sprite/weap_icon_lr.set_frame(4)
		elif global.player == 2:
			$player/sprite/weap_icon_lr.set_frame(6)
	if global.player_weap[int($player.swap)] == 2:
		if global.player == 0:
			$player/sprite/weap_icon_lr.set_frame(3)
		elif global.player == 1:
			$player/sprite/weap_icon_lr.set_frame(5)
	if global.player_weap[int($player.swap)] == 3:
		$player/sprite/weap_icon_lr.set_frame(7)
	if global.player_weap[int($player.swap)] == 4:
		$player/sprite/weap_icon_lr.set_frame(8)
	if global.player_weap[int($player.swap)] == 5:
		$player/sprite/weap_icon_lr.set_frame(9)
	if global.player_weap[int($player.swap)] == 6:
		$player/sprite/weap_icon_lr.set_frame(10)
	if global.player_weap[int($player.swap)] == 7:
		$player/sprite/weap_icon_lr.set_frame(11)
	if global.player_weap[int($player.swap)] == 8:
		$player/sprite/weap_icon_lr.set_frame(12)
	if global.player_weap[int($player.swap)] == 9:
		$player/sprite/weap_icon_lr.set_frame(13)
	if global.player_weap[int($player.swap)] == 10:
		$player/sprite/weap_icon_lr.set_frame(14)
	if global.player_weap[int($player.swap)] == 11:
		if global.player == 0:
			$player/sprite/weap_icon_lr.set_frame(15)
		elif global.player == 1:
			$player/sprite/weap_icon_lr.set_frame(16)
		elif global.player == 2:
			$player/sprite/weap_icon_lr.set_frame(17)
	
			
	#Set Colors
	#Player Sprites
	$player/sprite.material.set_shader_param('r_col1', palette[0])
	$player/sprite.material.set_shader_param('r_col2', palette[1])
	$player/sprite.material.set_shader_param('r_col3', palette[2])
	
	#HUD
	$hud/hud/weap.material.set_shader_param('r_col2', palette[1])
	$hud/hud/weap.material.set_shader_param('r_col3', palette[2])
	
	#Items
	var items = get_tree().get_nodes_in_group('items')
	for i in items:
		i.material.set_shader_param('r_col1', palette[0])
		i.material.set_shader_param('r_col2', palette[1])
		i.material.set_shader_param('r_col3', palette[2])
	
func spawn_objects():
	#Scan tilemap for objects.
	for cell in objects.get_used_cells():
		var id = objects.get_cellv(cell)
		var type = objects.tile_set.tile_get_name(id)
		#Get object ID and load into the level.
		if type in ['vert_gate', 'horiz_gate']:
			var c = load('res://scenes/objects/'+type+'.tscn').instance()
			var pos = objects.map_to_world(cell)
			c.position = pos + (objects.cell_size / 2)
			$graphic.add_child(c)
	
	var item_id = 1
	
	#Scan tilemap for items.
	for i in items.get_used_cells():
		var i_id = items.get_cellv(i)
		var i_type = items.tile_set.tile_get_name(i_id)
		#Get items and load into the level.
		if i_type in ['bolt_s', 'bolt_l', 'life_s', 'life_l', 'wpn_s', 'wpn_l', 'e_tank', 'm_tank', '1up']:
			var i_load = load('res://scenes/objects/'+i_type+'.tscn').instance()
			var i_pos = items.map_to_world(i)
			#Set item type numbers.
			if i_type == 'bolt_s':
				i_load.type = 0
			if i_type == 'bolt_l':
				i_load.type = 1
			if i_type == 'life_s':
				i_load.type = 2
			if i_type == 'life_l':
				i_load.type = 3
			if i_type == 'wpn_s':
				i_load.type = 4
			if i_type == 'wpn_l':
				i_load.type = 5
			if i_type == 'e_tank':
				i_load.type = 6
			if i_type == 'm_tank':
				i_load.type = 7
			if i_type == '1up':
				i_load.type = 8
			
			#Set item ID number.
			i_load.id = item_id
			item_id += 1
			
			#Spawn item
			i_load.position = i_pos + (items.cell_size / 2)
			$graphic.add_child(i_load)
			
			#Add item to the dictionary.
			if !global.temp_items.has(i_load.id):
				global.temp_items[i_load.id] = false
	
	#Delete items that have been collected.
	var i_check = get_tree().get_nodes_in_group('items')
	for ch in i_check:
		if global.temp_items.get(ch.id):
			ch.queue_free()

func splash():
	if !dead:
		$audio/se/splash.stop()
		$audio/se/splash.play()
		var splash = load('res://scenes/effects/splash.tscn').instance()
		$overlap.add_child(splash)
		splash.position.x = $player.position.x
		splash.position.y = $coll_mask/tiles.map_to_world(player_tilepos).y - 2

func bubble():
	if !dead:
		var bubble = load('res://scenes/effects/bubble.tscn').instance()
		$overlap.add_child(bubble)
		bubble.position = $player.position
		bbl_count += 1

func swap_out():
	#Spawn the leaving sprite.
	var out = load('res://scenes/player/other/plyr_out.tscn').instance()
	if hurt_swap:
		out.hurt = true
	$overlap.add_child(out)
	out.position = $player.position

func swap_in():
	#Spawn the inbound sprite.
	var p_in = load('res://scenes/player/other/plyr_in.tscn').instance()
	$overlap.add_child(p_in)
	p_in.position.x = $player.position.x
	p_in.position.y = $player.position.y - 240

func kill_effects():
	#Use this to kill special effect sprites when scrolling.
	var effects = get_tree().get_nodes_in_group('effects')
	for bubble in effects:
		bubble.queue_free()
	for splash in effects:
		splash.queue_free()
	bbl_count = 0
	
	#This function will also make collectible items invisible until the next area is loaded.
	var set_item = get_tree().get_nodes_in_group('items')
	for s in set_item:
		s.get_child(0).hide()

func kill_weapons():
	var wpns = get_tree().get_nodes_in_group('weapons')
	for i in wpns:
		i.queue_free()
	var adapt = get_tree().get_nodes_in_group('adaptors')
	for a in adapt:
		a.queue_free()
	shots = 0
	adaptors = 0

func kill_enemies():
	var bullet_kill = get_tree().get_nodes_in_group('enemy_bullet')
	for b in bullet_kill:
		b.queue_free()
	var enemy_kill = get_tree().get_nodes_in_group('enemies')
	for i in enemy_kill:
		i.queue_free()
	enemy_count = 0

func _on_teleport():
	if tele_timer <= 0:
		$player.hide()
		$fade/fade.state = 2
		$fade/fade.end = true

func swap():
	if global.player != global.player_id[int($player.swap)]:
		global.player = global.player_id[int($player.swap)]
		$player.change_char()
		palette_swap()

func item_drop():
	#Calculate drop rate and set item to spawn. (Instancing is done via the enemy's script.)
	item = []
	var item_table = {
		0 : ["", null],
		1 : ["bolt_l", 1],
		2 : ["bolt_s", 0],
		3 : ["life_l", 3],
		4 : ["life_s", 2],
		5 : ["wpn_l", 5],
		6 : ["wpn_s", 4],
		7 : ["1up", 8]
		}
	
	var rate = floor(rand_range(1, 128))
	
	#Drop rates are based on MM1/2 values
	if rate == 1:
		item = item_table.get(7)
	if rate >= 2 and rate <= 6:
		item = item_table.get(5)
	if rate >= 7 and rate <= 11:
		item = item_table.get(3)
	if rate >= 12 and rate <= 16:
		item = item_table.get(1)
	if rate >= 17 and rate <= 42:
		item = item_table.get(6)
	if rate >= 43 and rate <= 58:
		item = item_table.get(4)
	if rate >= 59 and rate <= 74:
		item = item_table.get(2)
	if rate >= 75:
		item = item_table.get(0)

func _on_player_whstl_end():
	play_music()

func play_music():
	$audio/music/glow.play()

func sound(sfx):
	for s in $audio/se.get_children():
		if s.name == sfx:
			s.play()
