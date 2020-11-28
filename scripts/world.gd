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

var get_scrn_txt = {
	0 : "YOU GOT\n\n\n   SWOOP KICK",
	1 : "YOU GOT\n\n\n   ROTO BOOST",
	2 : "YOU GOT\n\n\n   SPRING PUCK",
	3 : "YOU GOT\n\n\n   ATTACK SHIELD"
}

#Determines player position in the game world.
var pos = Vector2()
var player_tilepos = Vector2()
var stand_on
var overlap
var ladder_set
var ladder_top
var player_room = Vector2(0, 0)
var spawn_pt
var arr_blnk = 0
var arr_up = false
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
var dink = false

var fill_b_meter = false
var boss_hp = 280
var boss_delay = 60
var ready_boss = false
var wall_delay = 60
var elec_wall = false
var d_delay = 60
var d_appear = false

var boss_dead = false
var end_delay = 360
var end_stage = true
var end_state = 0
var end_style = 0
var leave_delay = 120

var wpn_txt_delay = 6
var drop_back = 180
var which_wpn = 0

var floor_boom = 8
var boom_delay = 0

var opn_lk_delay = 60
var opn_look_cnt = -1

var blink_delay = 30
var blink_cnt = 0

var mntr_frame = 0
var mntr_rand = 4
var show_boss = 0
var j_delay = 16

var j_release = 0

var opening = 0

var og_limits = []
var c_offset_mod = 0
var shake_delay = 2
var shake_x = 0
var shake_y = 0

#Shop values
var shop_active = false
var auto_dist = 0
var shop_state = 0
var shop_page = 0
var shop_pos = 0
var shop_rand = 0
var menu_flsh = 0
var icon_flsh = 0
var screws = 0
var prices = [100, 250, 200, -1, -1, -1]
var countdown = false
var buy_rand = 0
var ret_delay = 12
var next = false

var cursor_blnk = 0
var cutsc_mode = 0
var scene = 0
var sub_scene = 0
var scene_txt = {
	0 : ["MEGAMAN:", "WHAT IS GOING ON HERE? WAS\n\nTHAT WILY IN THAT CAGE?"],
	1 : ["MEGAMAN:", "WHO WAS THAT ROBOT?"],
	2 : ["??????:", "Y-Y-YIKES!"],
	3 : ["", ""],
	4 : ["AUTO:", "YO! MAN OF MEGA!"],
	5 : ["MEGAMAN:", "AUTO? WHY ARE YOU HERE?"],
	6 : ["AUTO:", "DR. LIGHT WAS WORRIED SO I\n\nFOLLOWED YOU WITH SOME"],
	7 : ["AUTO:", "SUPPLIES. THEN I CAME ACROSS\n\nA VERY UNSAFE HOLE!"],
	8 : ["AUTO:", "THIS PLACE SURE IS A WRECK..."],
	9 : ["MEGAMAN:", "..."],
	10 : ["MEGAMAN:", "SOMETHING ISN'T RIGHT WITH\n\nTHIS PLACE. YOU HAD"],
	11 : ["MEGAMAN:", "BETTER STAY HERE WHILE I LOOK\n\nAROUND."],
	12 : ["AUTO:", "WAIT. BEFORE YOU GO, I CAN\n\nMAKE SOME ITEMS OUT OF THE"],
	13 : ["AUTO:", "JUNK LYING AROUND. BRING ME\n\nSCREWS AND I'LL WHIP THEM"],
	14 : ["AUTO:", "TOGETHER! GO AHEAD! LOOK AT\n\nMY WARES!"],
	15 : ["", ""],
	16 : ["DR. WILY:", "SO! YOU'VE MANAGED TO DEFEAT\n\nTHE ROBOT MASTERS."],
	17 : ["DR. WILY:", "I GUESS I SHOULD THANK YOU\n\nFOR RESCUING ME..."],
	18 : ["DR. WILY:", "BAH! WHAT AM I SAYING?! THIS\n\nISN'T OVER!"],
	19 : ["DR. WILY:", "EXCEPT FOR THIS DEMO."],
	20 : ["DR. WILY:", "THOSE EXTRA DOORS? I CAN'T\n\nREALLY SAY."],
	21 : ["DR. WILY:", "YOU'LL HAVE TO FIND OUT IN\n\nTHE FULL GAME."],
	22 : ["DR. WILY:", "YOU CAN NOW REFIGHT THE\n\nBOSSES FOR A BETTER TIME AND"],
	23 : ["DR. WILY:", "RANK. CAN YOU REACH RANK S?"],
	24 : ["", ""]
}

var shop_text = {
	0 : ["AUTO:", "FIND ANYTHING YOU LIKE?"],
	1 : ["AUTO:", "DON'T BE SHY! BUY WHATEVER\n\nYOU LIKE!"],
	2 : ["AUTO:", "HEY, MEGA! YOU WON'T\n\nBELIEVE THESE PRICES!"],
	3 : ["AUTO:", "WISE CHOICE!"],
	4 : ["AUTO:", "YOU WON'T FIND A BETTER DEAL\n\nANYWHERE ELSE!"],
	5 : ["AUTO:", "HERE YOU GO!"],
	6 : ["AUTO:", "YOU DON'T HAVE ENOUGH\n\nSCREWS..."],
	7 : ["AUTO:", "DON'T BE GREEDY NOW."],
	8 : ["[ENERGY REFILL]", "REFILLS LIFE AND\n\nWEAPON ENERGY."],
	9 : ["[E-TANK]", "USE TO REFILL LIFE ENERGY."],
	10 : ["[W-TANK]", "USE TO REFILL WEAPON ENERGY."],
	11 : ["[DAMAGE REDUCER]", "50% DAMAGE REDUCTION."],
	12 : ["", ""],#Extra Item 1
	13 : ["", ""],#Extra Item 2
	14 : ["AUTO:", "ARE YOU SURE?\n\n[JUMP] - YES   [FIRE] - NO"],
	15 : ["AUTO:", "SORRY... THAT ITEM ISN'T\n\nAVAILABLE YET..."],
	16 : ["AUTO:", "TAKE CARE, MEGA!"],
	17 : ["AUTO:", "OH... CHANGE YOUR MIND?"]
}

#Item Drops
var item = []

#Camera values
var res = Vector2()
var center = Vector2()

var cam_move = 0
var cam_allow = [1, 1, 1, 1]
var scroll = false
var scroll_len = 0
var scroll_spd = 4

#Replace with better functions later
var rooms = 0
var prev_room = Vector2(0, 0)
var endless = false
var endless_rms = []
var screens = 0
var shake = -1
var enemy_count = 0

#Reference. The following dictionary contains data for the rooms loaded into the game. The key is the room coordinates. The first four numbers hold values for cam_allow.
#The final two hold how many rooms that particular area can scroll before stopping and which direction to scroll (1 for right, -1 for left). If rooms has a 0, ignore the
#scrolling section of the code, as it will only change the screen transitions.

var room_data = {
				"(10, 4)" : [0, 0, 0, 0, 2, 1, 0],
				"(11, 4)" : [0, 0, 0, 0, 2, -1, 0], #Main Hub
				"(7, 6)" : [0, 0, 0, 1, 1, 1, 0], #Swoop Hub
				"(8, 6)" : [0, 0, 0, 0, 1, 1, 0], #Swoop Boss Room
				"(7, 10)" : [0, 0, 0, 1, 1, 1, 1], #Roto Hub
				"(8, 10)" : [0, 0, 0, 0, 1, 1, 1], #Roto Boss Room
				"(6, 10)" : [0, 1, 1, 1, 1, 1, 1], #Roto Challenge Room
				"(5, 11)" : [0, 0, 1, 1, 1, 1, 1],
				"(14, 6)" : [0, 0, 1, 0, 1, 1, 2], #Scuttle Hub
				"(13, 6)" : [0, 0, 0, 0, 1, 1, 2], #Scuttle Boss Room
				"(14, 10)" : [0, 0, 1, 0, 1, 1, 3], #Defend Hub
				"(13, 10)" : [0, 0, 0, 0, 1, 1, 3], #Defend Boss Room
				}

var hub_rooms = [
				Vector2(10, 4),
				Vector2(11, 4),
				Vector2(7, 6),
				Vector2(7, 10),
				Vector2(14, 6),
				Vector2(14, 10)
				]

var boss_rooms = {
				"(8, 6)" : "",
				"(8, 10)" : "res://scenes/bosses/roto.tscn",
				"(13, 6)" : "res://scenes/bosses/scuttle.tscn",
				"(13, 10)" : "res://scenes/bosses/defend.tscn",
				}

var cont_rooms = {
				Vector2(10, 4) : 1,
				Vector2(11, 4) : 1,
				Vector2(7, 6) : 2,
				Vector2(7, 10) : 3,
				Vector2(14, 6) : 4,
				Vector2(14, 10) : 5,
				}

# warning-ignore:unused_class_variable
var got_items = {
				}

#Weapon ID Refence (Because I'm fucking retarded and forgot to write them down.)
#0: Normal Shot
#1: Level 1 Mega Arm
#2: Level 2 Mega Arm
#3: Swoop Kick
#4: Roto Boost
#5: Spring Puck
#6: Attack Shield
#7: Spinning Mega Man (Roto Boost)
#8: Ricocheted Roto Bombs
#9: Ricocheted Defend Buillets

var wpn_dmg = {
				0 : [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],			#Immunity to damage.
				1 : [10, 20, 30, 20, 40, 40, 10, 20, 0, 0, 0],	#Standard enemy. All Weapons hurt it.
				2 : [10, 20, 30, 10, 40, 10, 0, 20, 0, 0, 0],		#Swoop Woman
				3 : [10, 20, 30, 10, 10, 20, 40, 10, 40, 0, 0],	#Roto Man
				4 : [10, 20, 30, 40, 0, 20, 10, 0, 0, 10, 0],		#Scuttle Woman
				5 : [10, 20, 30, 10, 10, 40, 20, 0, 0, 0, 10],		#Defend Woman
				}
				
var damage = 0

var wpn_get_anim = [0, 1, 2, 3]

#Color Variables.
var palette = [Color('#000000'), Color('#000000'), Color('#000000')]

var bmtr_pal = [Color('#000000'), Color('#000000'), Color('#000000')]

var tele_timer = -1
var tele_dest

#Special effects
var spl_trigger = false
var bbl_count = 0

#Bolt Calculations
var shot_num = 0.0
var hit_num = 0.0
var hits = 0
var start_time = 0
var time = 0
var show_time = false
var go_time = false
var deaths = false
var tanks = false
var max_bolts = 0
var accuracy = 0.0
var after_boss = false

func _ready():
	
	$graphic/spawn_tiles/shop/eddie/anim.play('idle')
	
	$hud/hud/boss.material.set_shader_param('t_col1', global.t_color1)
	$hud/hud/boss.material.set_shader_param('t_col2', global.t_color2)
	$hud/hud/boss.material.set_shader_param('t_col3', global.t_color3)
	$hud/hud/boss.material.set_shader_param('t_col4', Color('#000000'))
	
	$hud/hud/boss.material.set_shader_param('r_col1', bmtr_pal[0])
	$hud/hud/boss.material.set_shader_param('r_col4', Color('#000000'))
	
	if global.opening >= 7:
		$overlap.show()
		$graphic/stage_overlap/dark.hide()
		for m in $graphic/stage_gfx/mugshots.get_children():
			m.show()
	
	res = get_viewport_rect().size
	
	#Generate a new random seed.
	randomize()
	
	#Hide Object and Enemy Layers
	objects.hide()
	enemies.hide()
	items.hide()
	
	#Spawn stage objects.
	spawn_objects()
	
	#Set charge loop values.
	$audio/se/charge.stream.loop_mode = 1
	$audio/se/charge.stream.loop_begin = 56938
	$audio/se/charge.stream.loop_end = 62832
	
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
	
	prev_room = player_room
	
	_rooms()
	
	if global.opening == 7:
		play_music("main")
	
	if int(global.boss1_clear) + int(global.boss2_clear) + int(global.boss3_clear) + int(global.boss4_clear) == 4:
		$graphic/spawn_tiles/cage.queue_free()


# warning-ignore:unused_argument
func _input(event):
	#Weapon Swapping.
	if $player.can_move:
		#L and R Button.
		if Input.is_action_just_pressed("prev") and !$player.cutscene:
			global.player_weap[int($player.swap)] -= 1
			$player.w_icon = 64
			$player.r_boost = false
			kill_weapons()
			
			if global.player_weap[int($player.swap)] < 0:
				global.player_weap[int($player.swap)] = 5
			
			#Skip unacquired weapons.
			if global.player_weap[int($player.swap)] == 5 and !global.perma_items.get("super_adaptor"):
				global.player_weap[int($player.swap)] -= 1
			if global.player_weap[int($player.swap)] == 4 and !global.weapon4[0]:
				global.player_weap[int($player.swap)] -= 1
			if global.player_weap[int($player.swap)] == 3 and !global.weapon3[0]:
				global.player_weap[int($player.swap)] -= 1
			if global.player_weap[int($player.swap)] == 2 and !global.weapon2[0]:
				global.player_weap[int($player.swap)] -= 1
			if global.player_weap[int($player.swap)] == 1 and !global.weapon1[0]:
				global.player_weap[int($player.swap)] -= 1
			
			palette_swap()
			
		if Input.is_action_just_pressed("next") and !$player.cutscene:
			global.player_weap[int($player.swap)] += 1
			$player.w_icon = 64
			$player.r_boost = false
			kill_weapons()
			
			#Skip unacquired weapons.
			if global.player_weap[int($player.swap)] == 1 and !global.weapon1[0]:
				global.player_weap[int($player.swap)] += 1
			if global.player_weap[int($player.swap)] == 2 and !global.weapon2[0]:
				global.player_weap[int($player.swap)] += 1
			if global.player_weap[int($player.swap)] == 3 and !global.weapon3[0]:
				global.player_weap[int($player.swap)] += 1
			if global.player_weap[int($player.swap)] == 4 and !global.weapon4[0]:
				global.player_weap[int($player.swap)] += 1
			if global.player_weap[int($player.swap)] == 5 and !global.perma_items.get("super_adaptor"):
				global.player_weap[int($player.swap)] += 1
				
			if global.player_weap[int($player.swap)] > 5:
				global.player_weap[int($player.swap)] = 0
				
			palette_swap()
	
		#Pause menu
		if Input.is_action_just_pressed('start') and !$pause/pause_menu.start and !swapping and global.boss_num > 0 and !$player.no_input:
			$pause/pause_menu.kill_wpn = global.player_weap[int($player.swap)]
			sound("menu")
			kill_se("charge")
			p_menu = true
			$pause/pause_menu.start = true
			$pause/pause_menu.init_cursor()
			$player.hide()
			for i in get_tree().get_nodes_in_group('enemies'):
				i.hide()
			for b in get_tree().get_nodes_in_group('boss'):
				b.hide()
			for w in get_tree().get_nodes_in_group('weapons'):
				w.hide()
			for a in get_tree().get_nodes_in_group('adaptors'):
				a.hide()
			$hud/hud.hide()
			if $hud/boss_timer.is_visible_in_tree():
				$hud/boss_timer.hide()
			$player.can_move = false
			get_tree().paused = true
	
	else:
		#Return to the game.
		if Input.is_action_just_pressed('start') and $pause/pause_menu.menu_pos.x < 2 or Input.is_action_just_pressed('jump') and $pause/pause_menu.menu_pos.x < 2:
			if $pause/pause_menu.start:
				if $pause/pause_menu.kill_wpn != global.player_weap[int($player.swap)]:
					kill_weapons()
				$audio/se/bling.play()
				$pause/pause_menu.start = false
	
func _camera():
	#Calculate player position.
	pos = $player.position
	pos = Vector2(floor(pos.x), floor(pos.y))
	
	#Get Center of the screen.
	center = $player/camera.get_camera_screen_center()
	center = Vector2(floor(center.x), floor(center.y))
	
	#FOR FUTURE REFERENCE: The cam_allow stores values for up, down, left, right in that order in the array.
	
	if $hud/boss_timer.is_visible_in_tree() and scroll:
		if after_boss:
			reset_bolt_calc(true)
			after_boss = false
		$hud/boss_timer.hide()
		$hud/boss_timer.init()
	
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
	print("In Room: ",player_room)
	
	#This function also houses the counter for Endless Mode.
#	if endless:
#		if !endless_rms.has(player_room):
#			endless_rms.insert(endless_rms.size(), player_room)
#			screens += 1
	
	#Add function here to clear endless_rms to prevent lag. (Example: When the player reaches a teleporter, clear endless_rms)
	
	if room_data.has(str(player_room)):
		#Set camera allow values.
		cam_allow[0] = room_data.get(str(player_room))[0]
		cam_allow[1] = room_data.get(str(player_room))[1]
		cam_allow[2] = room_data.get(str(player_room))[2]
		cam_allow[3] = room_data.get(str(player_room))[3]
		which_wpn = room_data.get(str(player_room))[6]
		$wpn_get/mod_ctrl/txt.set_text(get_scrn_txt.get(which_wpn))
		
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
	
	#Set the appropriate sprite for the weapon get screen.
	$wpn_get/mod_ctrl/wpn_get2.frame = which_wpn
	
	if cont_rooms.has(player_room):
		global.cont_id = cont_rooms.get(player_room)
	
	#Prevent the player from re-entering a boss room until they've visted the main hub.
	if hub_rooms.has(player_room):
		
		var room_chk = player_room
		
		if room_chk != Vector2(10, 4) and room_chk != Vector2(11, 4):
			#Check to see if the other bosses are defeated
			if global.weapon1[0] and global.weapon2[0] and global.weapon3[0] and global.weapon4[0]:
				global.boss1_clear = true
				global.boss2_clear = true
				global.boss3_clear = true
				global.boss4_clear = true
			match which_wpn:
				0:
					$hud/hud/boss.material.set_shader_param('r_col2', global.grey1)
					$hud/hud/boss.material.set_shader_param('r_col3', global.white)
					if !global.weapon1[0] and !global.boss1_clear:
						end_style = 0
					elif global.weapon1[0] and !global.boss1_clear:
						cam_allow[3] = 0
					elif global.weapon1[0] and global.boss1_clear:
						end_style = 1
				1:
					$hud/hud/boss.material.set_shader_param('r_col2', global.blue2)
					$hud/hud/boss.material.set_shader_param('r_col3', global.white)
					if !global.weapon2[0] and !global.boss2_clear:
						end_style = 0
					elif global.weapon2[0] and !global.boss2_clear:
						cam_allow[3] = 0
					elif global.weapon2[0] and global.boss2_clear:
						end_style = 1
				2:
					$hud/hud/boss.material.set_shader_param('r_col2', global.red1)
					$hud/hud/boss.material.set_shader_param('r_col3', global.white)
					if !global.weapon3[0] and !global.boss3_clear:
						end_style = 0
					elif global.weapon3[0] and !global.boss3_clear:
						cam_allow[2] = 0
					elif global.weapon3[0] and global.boss3_clear:
						end_style = 1
				3:
					$hud/hud/boss.material.set_shader_param('r_col2', global.red2)
					$hud/hud/boss.material.set_shader_param('r_col3', global.white)
					if !global.weapon4[0] and !global.boss4_clear:
						end_style = 0
					elif global.weapon4[0] and !global.boss4_clear:
						cam_allow[2] = 0
					elif global.weapon4[0] and global.boss4_clear:
						end_style = 1
			
				
	if boss_rooms.has(str(player_room)):
		#Kill music and display the boss meter.
		kill_music()
		
		if which_wpn != 0 and which_wpn != 2 and which_wpn != 3:
			ready_boss = true
			$player.no_input(true)
		
		if which_wpn == 2:
			elec_wall = true
			$player.no_input(true)
		
		if which_wpn == 3:
			d_appear = true
			$player.no_input(true)

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
		
	og_limits = [$player/camera.limit_top, $player/camera.limit_bottom, $player/camera.limit_left, $player/camera.limit_right]
	
	if global.scene < 7:
		if global.scene == 1 and cutsc_mode == 0:#Edit for additional scenes.
			if player_room == Vector2(10, 4) or player_room == Vector2(11, 4):
				c_offset_mod = 64
				cutsc_mode = 1
		
		if cutsc_mode == 1:
			if !$scene_txt/on_off.is_visible_in_tree():
				$scene_txt.offset.y = -64
				$scene_txt/on_off.show()
			kill_music()
			$player.cutscene(true)
			global.player_weap[0] = 0
			palette_swap()
			$player/camera.limit_top = og_limits[0] + 64
			$player/camera.limit_bottom = og_limits[1] + 64
			cutsc_mode = 2
	
	if global.scene == 8:
		kill_music()
		if player_room == Vector2(7, 6):
			$graphic/spawn_tiles/demo_wily.global_position = Vector2(1920, 1585)
		elif player_room == Vector2(7, 10):
			$graphic/spawn_tiles/demo_wily.global_position = Vector2(1920, 2545)
		elif player_room == Vector2(14, 6):
			$graphic/spawn_tiles/demo_wily.global_position = Vector2(3712, 1585)
		elif player_room == Vector2(14, 10):
			$graphic/spawn_tiles/demo_wily.global_position = Vector2(3712, 2545)
		$player.cutscene(true)
		global.player_weap[0] = 0
		palette_swap()
		cutsc_mode = 1
	
	if global.scene == 9:
		if $graphic/spawn_tiles/demo_wily.is_visible_in_tree():
			$graphic/spawn_tiles/demo_wily.hide()
		
	#Remove the cage.
	var cage = get_tree().get_nodes_in_group('cage')
	if cage != []:
		
		#Make Wily appear when a room is entered.
		if !$graphic/spawn_tiles/cage/wily.is_visible_in_tree():
			if boss_rooms.has(str(player_room)):
				$graphic/spawn_tiles/cage/wily.show()
		
		if cage[0].end_state > 9:
			cage[0].queue_free()


func calc_damage(to, from):
	#Check if the player is receiving the damage or not.
	if to.is_in_group("player"):
		#If true, then check to see if the player CAN be damaged.
		if to.hurt_timer == 0 and to.blink_timer == 0 and !to.hurt_swap:
			global.player_life[int($player.swap)] -= from.damage
			to.damage()
	elif from.is_in_group("player") or from.is_in_group("weapons") or from.is_in_group("adaptor_dmg") or from.is_in_group("wall"):
		#The player is only checked due to Roto Boost or Swoop Kick being active.
		if to.is_in_group("enemies"):
			pass
		elif to.is_in_group("boss"):
			var add_count = false
			var get_id = 0
			if from.is_in_group("player"):
				#If the damage is being received from the player, set damage IDs based on the attack that struck.
				if from.s_kick:
					get_id = 3
				elif from.r_boost:
					get_id = 7
				enemy_dmg(to.id, get_id)
			else:
				#Everything else has their own IDs
				get_id = from.id
				enemy_dmg(to.id, from.id)
			if damage != 0 and !from.reflect:
				if from.is_in_group("weapons") or from.is_in_group("adaptor_dmg"):
					
					match from.property:
						null:
							print('shield')
							from._on_screen_exited()
						0:
							from._on_screen_exited()
						2:
							if damage < boss_hp:
								from._on_screen_exited()
						3:
							if damage < boss_hp:
								if to.flash == 0:
									from.choke_check()
									from.choke_max = to.CHOKE
									from.choke_delay = 6
								from.velocity = Vector2(0, 0)
						6:
							from._on_screen_exited()
						8:
							from.boom()
						99: #Spring Puck behaves differently based on who it strikes.
							if to.name == "swoop" or to.name == "roto":
								from._on_screen_exited()
				if boss_hp > 0:
					if to.flash == 0:
						if to.name == "scuttle":
							if to.state >= 6 and to.state <= 10:
								to.force_spin += 1
						sound("hit")
						boss_hp -= damage
						hit_num += 1
						add_count = true
						to.flash = 20
						to.hit = true
				else:
					if from.name != "player":
						if from.property == 3:
							if !from.ret:
								from.ret()
			else:
				if from.name != "player":
					if from.property != 3 and from.property != null:
						if !from.reflect:
							sound("dink")
							from.reflect = true
					elif from.property == null:
						if !from.reflect:
							sound("dink")
							from.reflect = true
							from._on_screen_exited()
					elif from.property == 3:
						if !from.ret:
							sound("dink")
							from.ret()
				else:
					if !dink:
						sound("dink")
						dink = true
			
			#Add additional behaviors based on damage IDs
			match get_id:
				3:
					if to.name == "swoop":
						if to.state == 1:
							to.velocity.x = to.velocity.x * 0.5
							to.velocity.y = 20
							to.get_child(0).show()
							to.get_child(6).play("idle")
							to.get_child(7).play("flap")
							to.dives = 0
							to.state = 8
				7:
					if from.name == "player":
						var dist_mul = 1
						var dist = from.global_position.x - to.global_position.x
						if to.name == "defend":
							dist_mul = 2
						if to.name != "scuttle":
							if dist <= 12 * dist_mul and dist >= -12 * dist_mul and from.global_position.y < to.global_position.y - 12 and from.velocity.y >= 0:
								if to.name == "defend": #This is for Defend only. Quickfix.
									sound('dink')
								from.velocity.y = (from.JUMP_SPEED) / from.jump_mod
						else:
							calc_damage(from, to)
		
		#Mega Arm choke function.
		if from.is_in_group("weapons") and from.property == 3 and from.choke:
			from.global_position = to.global_position
			if to.flash == 0 and from.choke_delay == 0:
				if from.choke_max > 0:
					boss_hp -= 10
					from.choke_max -= 1
					from.choke_delay = 6
					to.flash = 20
					to.hit = true
					sound("hit")
					#Make the Mega Arm return to the player if boss dies.
					if boss_hp <= 0:
						from.choke = false
						from.choke_delay = 0
			elif from.choke_max == 0 or to.id == 0:
				from.choke = false
				from.choke_delay = 0


#warning-ignore:unused_argument
func _process(delta):
	_camera()
	cutscene()
	
	#This is just to make the shop menu flash.
	if shop_state == 1 or shop_state == 9:
		menu_flsh += 1
		if menu_flsh > 1:
			menu_flsh = 0
	
	shop()
	
	#Make the fake Wily face the player.
	if $graphic/spawn_tiles/demo_wily.global_position.x > $player.global_position.x and !$graphic/spawn_tiles/demo_wily.flip_h:
		$graphic/spawn_tiles/demo_wily.flip_h = true
	elif $graphic/spawn_tiles/demo_wily.global_position.x < $player.global_position.x and $graphic/spawn_tiles/demo_wily.flip_h:
		$graphic/spawn_tiles/demo_wily.flip_h = false
	
	#Make the shop appear if the current scene is 6 or above. This is mostly to make the shop accessible when the player dies.
	if global.scene == 6 or global.scene == 9:
		if !shop_active:
			shop_active = true
	
	if shop_active and !$graphic/spawn_tiles/shop/auto.is_visible_in_tree():
		$graphic/spawn_tiles/shop/auto.show()
		$graphic/spawn_tiles/shop/eddie.show()
	
	#Shop function
	#Calculate how close the player is to Auto.
	if player_room == Vector2(10, 4):
		auto_dist = $graphic/spawn_tiles/shop/auto.global_position.x - $player.global_position.x
		
	#If the player presses up in the right spot, trigger shop sequence.
	if auto_dist < 0 and auto_dist > -16 and Input.is_action_just_pressed('up') and shop_state == 0 and shop_active:
		kill_music()
		play_music('shop - rock')
		shop_rand = round(rand_range(0, 2))
		$graphic/spawn_tiles/shop/menu/screws.set_text(str(global.bolts))
		screws = global.bolts
		$graphic/spawn_tiles/shop/menu/icon1/price1.set_text(str(prices[0]))
		$graphic/spawn_tiles/shop/menu/icon2/price2.set_text(str(prices[1]))
		$graphic/spawn_tiles/shop/menu/icon3/price3.set_text(str(prices[2]))
		$player.cutscene(true)
		shop_state = 1
	
	#Calculate time during a boss fight.
	if boss:
		
		match which_wpn:
			0:
				if global.boss1_clear:
					show_time = true
			1:
				if global.boss2_clear:
					show_time = true
			2:
				if global.boss3_clear:
					show_time = true
			3:
				if global.boss4_clear:
					show_time = true
		
		if !$hud/boss_timer.is_visible_in_tree() and show_time and !get_tree().paused:
			$hud/boss_timer/text.set_text('00:00:000')
			$hud/boss_timer.show()
		
		if go_time:
			if start_time == 0:
				start_time = OS.get_ticks_msec()
			
			if start_time != 0 and !get_tree().paused and boss_hp > 0:
				time = OS.get_ticks_msec() - start_time
				if time > 5999999:
					time = 5999999
				
			var mins = int(time / 60 / 1000)
			var secs = int(time / 1000) % 60
			var msecs = int(time) % 1000
			
			var b_time = ("%02d" % mins) + (":%02d" % secs) + (":%03d" % msecs)
			$hud/boss_timer/text.set_text(b_time)
				
		
	#Print Shit
	
	#Camera shake?
	if shake == -1:
		$player/camera.limit_top = og_limits[0]
		$player/camera.limit_bottom = og_limits[1]
		$player/camera.limit_left = og_limits[2]
		$player/camera.limit_right = og_limits[3]
		shake -= 1
		
	if shake > -1:
		if shake_delay > 0:
			shake_delay -= 1
	
			if shake_delay == 0:
				shake_x = floor(rand_range(-2, 2))
				shake_y = floor(rand_range(-2, 2))
	
				$player/camera.limit_top = og_limits[0] + shake_y
				$player/camera.limit_bottom = og_limits[1] + shake_y
				$player/camera.limit_left = og_limits[2] + shake_x
				$player/camera.limit_right = og_limits[3] + shake_x
				shake -= 1
				shake_delay = 2
	
	#Get other player information.
	player_tilepos = $coll_mask/tiles.world_to_map(pos)
	stand_on = $coll_mask/tiles.get_cellv(Vector2(player_tilepos.x, player_tilepos.y + 1))
	overlap = $coll_mask/tiles.get_cellv(player_tilepos)
	ladder_set = (player_tilepos.x * 16) + 8
	ladder_top = $coll_mask/tiles.map_to_world(player_tilepos)
	player_room = Vector2(floor(pos.x / 256), floor(pos.y / 240))
	spawn_pt = $coll_mask/spawn_pts.get_cellv($coll_mask/spawn_pts.world_to_map(Vector2(pos.x - 4, pos.y)))
	
	#Get ready to load the boss.
	
	if ready_boss and boss_delay > -1:
		boss_delay -= 1
	
	if boss_delay == 0:
		$audio/music/boss.play()
		boss = true
		#Load the boss scene(s).
		var boss = load(boss_rooms.get(str(player_room))).instance()
		$graphic.add_child(boss)
	
	if elec_wall and wall_delay > -1:
		if $player.global_position.x > $player/camera.limit_right - 40:
			$player.x_dir = -1
		else:
			$player.x_dir = 0
		
		wall_delay -= 1
	
	if wall_delay == 0:
		sound('elec')
		var e_wall_l = load('res://scenes/bosses/elec_wall.tscn').instance()
		$graphic/spawn_tiles.add_child(e_wall_l)
		e_wall_l.global_position.x = $player/camera.limit_left + 24
		e_wall_l.global_position.y = $player/camera.limit_top + 112
		var e_wall_r = load('res://scenes/bosses/elec_wall.tscn').instance()
		$graphic/spawn_tiles.add_child(e_wall_r)
		e_wall_r.global_position.y = $player/camera.limit_top + 112
		e_wall_r.global_position.x = $player/camera.limit_right - 24
		ready_boss = true
	
	if d_appear and d_delay > -1:
		d_delay -= 1
	
	if d_delay == 0:
		var defend = load('res://scenes/bosses/defend.tscn').instance()
		defend.position.x = $player/camera.limit_left + 128
		defend.position.y = $player/camera.limit_top + 120
		$graphic.add_child(defend)

	#Check player health. If maxed, set life_en to 0.
	if life_en > 0:
		if global.player_life[0] == 280:
			life_en = 0
	
	#Check player's equipped weapon.
	if wpn_en > 0:
		if global.player_weap[0] != 0:
			match global.player_weap[0]:
				1:
					if global.weapon1[1] == 280:
						wpn_en = 0
				2:
					if global.weapon2[1] == 280:
						wpn_en = 0
				3:
					if global.weapon3[1] == 280:
						wpn_en = 0
				4:
					if global.weapon4[1] == 280:
						wpn_en = 0
		else:
			wpn_en = 0
	
	#Pause the game if life_en or wpn_en is greater than 0.
	if wpn_en != 0 and !get_tree().paused and !p_menu or life_en != 0 and !get_tree().paused and !p_menu:
		get_tree().paused = true
	
	#Refill the necessary energy.
	if wpn_en != 0 or life_en != 0 or boss and fill_b_meter:
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
	if global.player_life[0] != 0:
		if wpn_en > 0 and heal_delay == 1:
			$audio/se/meter.play()
			match global.player_weap[0]:
				1:
					global.weapon1[1] += 10
				2:
					global.weapon2[1] += 10
				3:
					global.weapon3[1] += 10
				4:
					global.weapon4[1] += 10
			wpn_en -= 10
	
	#Boss Meters.
	if $hud/hud/boss.value < boss_hp and heal_delay == 1 and boss and fill_b_meter:
		$audio/se/meter.play()
		$hud/hud/boss.value += 10
	
	#Allow the player to move again.
	if life_en == 0 and wpn_en == 0 and get_tree().paused and !p_menu and !hurt_swap and !dead:
		heal_delay = 0
		get_tree().paused = false
	
	if boss and fill_b_meter and $hud/hud/boss.value == boss_hp:
		fill_b_meter = false
		for b in get_tree().get_nodes_in_group("boss"):
			b.intro = false
			match which_wpn:
				0:
					if global.boss1_clear:
						go_time = true
				1:
					if global.boss2_clear:
						go_time = true
				2:
					if global.boss3_clear:
						go_time = true
				3:
					if global.boss4_clear:
						go_time = true
			b.fill_bar = false
			match which_wpn:
				0:
					b.play_anim("idle")
				1:
					b.play_anim("spin-norm")
				2:
					b.play_anim("idle")
				3:
					b.play_anim("close")
			$player.no_input(false)
	
	#Check to see if the player's weapons or adaptors have gone beyond the screen.
	var get_weaps = get_tree().get_nodes_in_group("weapons")
	var get_adaps = get_tree().get_nodes_in_group("adaptors")
	
	if get_weaps.size() > 0 or get_adaps.size() > 0:
		for w in get_weaps:
			if w.global_position.y < $player/camera.limit_top - 16 or w.global_position.y > $player/camera.limit_bottom + 16 or w.global_position.x < $player/camera.get_camera_screen_center().x - 144 or w.global_position.x > $player/camera.get_camera_screen_center().x + 144:
				#Ignore for the Mega Arm, as it needs to return to the player.
				if global.player_weap[int($player.swap)] != 0 and global.player == 0:
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
		kill_weapons()
		kill_se("charge")
		for m in $audio/music.get_children():
			m.stop()
		
	if global.player_life[0] <= 0 and global.player_life[1] <= 0 and !dead:
		dead = true
		$player.s_kick = false
		get_tree().paused = true
		kill_se("charge")
		for m in $audio/music.get_children():
			m.stop()
	
	if dead and dead_delay > -1:
		dead_delay -= 1
	
	if dead and dead_delay == 0:
		if $player.is_visible():
			$player.s_kick = false
			$player.r_boost = false
			$audio/se/death.play()
			$player.hide()
			$player/standbox.set_deferred("disabled", true)
			$player/slidebox.set_deferred("disabled", true)
			kill_weapons()
			for n in range(16):
				var boom = DEATH_BOOM.instance()
				boom.position = $player.position
				boom.id = n
				$overlap.add_child(boom)
		else:
			$audio/se/death.play()
		$player.can_move = false
		get_tree().paused = false
			
	if dead and dead_delay < 0 and restart > -1:
		restart -= 1
	
	if dead and dead_delay < 0 and restart == 0:
		if !$fade/fade.end:
			$fade/fade.state = 4
			$fade/fade.end = true
	
	#Right Analog Stick
	
	#Teleporters
	if arr_up:
		arr_blnk += 4
	else:
		arr_blnk += 1
	
	if arr_blnk > 15:
		arr_blnk = 0
		
	if arr_blnk < 8:
		$overlap/arrow.show()
	else:
		$overlap/arrow.hide()
	
	if spawn_pt != -1:
		if spawn_pt >= 8 and spawn_pt <= 27:
			match spawn_pt:
				8:
					$overlap/arrow.global_position = Vector2(2608, 1128)
					show_boss = 1
				9:
					$overlap/arrow.global_position = Vector2(1840, 1528)
				10:
					$overlap/arrow.global_position = Vector2(2656, 1128)
					show_boss = 2
				11:
					$overlap/arrow.global_position = Vector2(1840, 2488)
				12:
					$overlap/arrow.global_position = Vector2(2976, 1128)
					show_boss = 3
				13:
					$overlap/arrow.global_position = Vector2(3792, 1528)
				14:
					$overlap/arrow.global_position = Vector2(3024, 1128)
					show_boss = 4
				15:
					$overlap/arrow.global_position = Vector2(3792, 2488)
	else:
		if $overlap/arrow.global_position != Vector2(2500, 1100):
			 $overlap/arrow.global_position = Vector2(2500, 1100)
		if show_boss != 0:
			show_boss = 0
			
	
	if spawn_pt != -1 and $player.is_on_floor():
		if spawn_pt >= 8 and spawn_pt <= 27 and !$player.no_input and Input.is_action_just_pressed("up"):
			$player.no_input(true)
			$player.anim_state(2)
			$player.slide = false
			$player.slide_timer = 0
			arr_up = true
			tele_timer = 60
			tele_dest = spawn_pt + 20
	
	if $player.no_input and global.opening >= 7 and tele_timer > -1 and cutsc_mode == 0 and !boss and end_delay > 0:
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
	
	#End Stage Functions.
	if boss_hp <= 0 and !boss_dead:
		global.boss_num -= 1
		boss_dead = true
	
	if global.boss_num == 0:
		end_delay -= 1
	
	if end_delay == 0:
		if end_state == 0:
			match end_style:
				0:
					$hud/hud.hide()
					$audio/music/clear.play()
					$player.cutscene(true)
					boss = false
				1:
					play_music('main')
					boss = false
					$pause/pause_menu.hide_icons()
					cam_allow[2] = 1
					cam_allow[3] = 1
					end_delay = 360
					boss_dead = false
					boss = false
					max_bolts = 0
					ready_boss = false
					boss_delay = 60
					fill_b_meter = false
					elec_wall = false
					wall_delay = 60
					d_appear = false
					show_time = false
					go_time = false
					d_delay = 60
					boss_hp = 280
					heal_delay = 0
					drop_back = 180
					global.boss_num = 1
			
	if end_state == 1:
		if wpn_get_anim.has(global.level_id):
			if $player.global_position.x < $player/camera.limit_right - 128:
				$player.x_dir = 1
			else:
				$player.x_dir = -1
			end_state = 2
		else:
			end_state = 5
	
	if end_state == 2:
		if $player.x_dir == 1 and $player.global_position.x >= $player/camera.limit_right - 128 or $player.x_dir == -1 and $player.global_position.x <= $player/camera.limit_right - 128:
			$player.global_position.x = floor($player.global_position.x)
			$player.x_dir = 0
			$player.jump_mod = 1.75
			$player.jump_tap = true
			$player.jump = true
			$audio/se/beam_out.play()
			
		if $player.global_position.y >= $player/camera.limit_top + 80 and $player.velocity.y > 0:
			$player.global_position = Vector2(floor($player.global_position.x), floor($player.global_position.y))
			var get_wpn = load('res://scenes/effects/wpn_get.tscn').instance()
			$overlap.add_child(get_wpn)
			get_wpn.position = $player.position
			$player.global_position.y = $player/camera.limit_top + 80
			$player.velocity.y = 0
			$player.can_move = false
			end_state = 3
	
	if end_state == 4:
		$player.anim_state($player.GET_WPN)
		global.player_weap[0] = which_wpn + 1
		palette_swap()
		sound("bling")
		end_state = 5
	
	if end_state == 6:
		play_music("wpn_get")
		$fake_fade/fade.interpolate_property($fake_fade/rect, 'color', Color(0.0, 0.0, 0.0, 0.0), Color(0.0, 0.0, 0.0, 1.0), 0.125, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		$fake_fade/fade.start()
		$wpn_get/wpn_get1.frame = $player/sprite.get_frame()
		$wpn_get/wpn_get1.position = Vector2(($player.global_position.x - $player/camera.limit_left), ($player.global_position.y - $player/camera.limit_top))
		$wpn_get/wpn_get1.show()
		end_state =7
	
	if end_state == 8:
		$wpn_get/wpn_fade.interpolate_property($wpn_get/mod_ctrl, 'modulate', Color(1.0, 1.0, 1.0, 0.0), Color(1.0, 1.0, 1.0, 1.0), 0.125, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		$wpn_get/wpn_fade.interpolate_property($wpn_get/wpn_get1, 'position', $wpn_get/wpn_get1.position, $wpn_get/mod_ctrl/wpn_get2.position, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		$wpn_get/wpn_fade.interpolate_property($wpn_get/wpn_get1, 'scale', Vector2(1, 1), Vector2(3, 3), 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		$wpn_get/wpn_fade.interpolate_property($wpn_get/wpn_get1, 'modulate', Color(1.0, 1.0, 1.0, 1.0), Color(1.0, 1.0, 1.0, 0.0), 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		$wpn_get/wpn_fade.interpolate_property($wpn_get/mod_ctrl/top, 'rect_position', Vector2(0, 0), Vector2(0, -60), 0.75, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		$wpn_get/wpn_fade.interpolate_property($wpn_get/mod_ctrl/bottom, 'rect_position', Vector2(0, 0), Vector2(0, 60), 0.75, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		$wpn_get/wpn_fade.start()
		end_state = 9
	
	if end_state == 10:
		if wpn_txt_delay > 0:
			wpn_txt_delay -= 1
		
		if wpn_txt_delay == 0:
			if $wpn_get/mod_ctrl/txt.visible_characters < $wpn_get/mod_ctrl/txt.get_total_character_count():
				$wpn_get/mod_ctrl/txt.set_visible_characters($wpn_get/mod_ctrl/txt.visible_characters + 1)
				wpn_txt_delay = 6
			
			if $wpn_get/mod_ctrl/txt.visible_characters == $wpn_get/mod_ctrl/txt.get_total_character_count():
				end_state = 11
	
	if end_state == 11:
		if drop_back > 0:
			drop_back -= 1
		
		if drop_back <= 10 and $audio/music/wpn_get.get_volume_db() > -80:
			$audio/music/wpn_get.set_volume_db($audio/music/wpn_get.get_volume_db() - 8)
			
		if drop_back == 0:
			$fake_fade/fade.interpolate_property($fake_fade/rect, 'color', Color(0.0, 0.0, 0.0, 1.0), Color(0.0, 0.0, 0.0, 0.0), 0.125, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			$fake_fade/fade.start()
			$wpn_get/wpn_fade.interpolate_property($wpn_get/mod_ctrl, 'modulate', Color(1.0, 1.0, 1.0, 1.0), Color(1.0, 1.0, 1.0, 0.0), 0.125, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			$wpn_get/wpn_fade.start()
			kill_music()
			$audio/music/wpn_get.set_volume_db(0)
			end_state = 12
	
	if global.opening == 0:
		if $player.global_position.x >= $player/camera.limit_left + 96 and $player.global_position.x <= $player/camera.limit_right -96 and $player.is_on_floor():
			$player.can_move = false
			$player.cutscene(true)
			$player/anim.stop()
			$hud/hud.hide()
			global.opening = 1
	
	if global.opening == 1:
		if boom_delay > 0:
			boom_delay -= 1
		
		if boom_delay == 0 and floor_boom > 0:
			sound("big_explode")
			var l_boom = $coll_mask/tiles.map_to_world(Vector2(165, 13))
			var r_boom = $coll_mask/tiles.map_to_world(Vector2(170, 13))
			for _b in range(2):
				var boom = load("res://scenes/effects/s_explode.tscn").instance()
				boom.position.x = floor(rand_range(l_boom.x, r_boom.x + 16))
				boom.position.y = floor(rand_range(l_boom.y, l_boom.y + 16))
				$graphic.add_child(boom)
			floor_boom -= 1
			boom_delay = 8
		
		if floor_boom == 0:
			for f in range(6):
				$coll_mask/tiles.set_cellv(Vector2(165 + f, 13), -1)
				$graphic/stage_gfx/world.set_cellv(Vector2(165 + f, 13), -1)
			$graphic/stage_gfx/world.set_cellv(Vector2(164, 13), 445)
			$graphic/stage_gfx/world.set_cellv(Vector2(171, 13), 446)
			$player.can_move = true
			global.opening = 2
	
	if global.opening == 2 and $player.is_on_floor():
		
		if opn_look_cnt == -1:
			if $player/sprite.flip_h:
				opn_look_cnt = 4
			else:
				opn_look_cnt = 3
		
		opn_lk_delay -= 1
		
		if opn_lk_delay == 0:
			if opn_look_cnt > 0:
				if $player/sprite.flip_h:
					$player/sprite.flip_h = false
				else:
					$player/sprite.flip_h = true
			
			opn_lk_delay = 16
			opn_look_cnt -= 1
		
		if opn_look_cnt == 0:
			global.opening = 3
	
	if global.opening == 3:
		blink_delay -= 1
		
		if blink_delay == 0:
			if $graphic/stage_overlap/dark.is_visible_in_tree():
				$graphic/stage_overlap/dark.hide()
				$overlap.show()
			else:
				$graphic/stage_overlap/dark.show()
				$overlap.hide()
			
			if blink_cnt < 7:
				blink_delay = 4
			elif blink_cnt == 7:
				blink_delay = 16
			elif blink_cnt < 28:
				blink_delay = 1
			else:
				for m in $graphic/stage_gfx/mugshots.get_children():
					m.show()
				$graphic/stage_overlap/dark.queue_free()
				global.opening = 4
			
			blink_cnt += 1
	
	if global.opening == 4:
		
		if mntr_rand == 0:
			if mntr_frame < 3:
				mntr_rand = 4
				mntr_frame += 1
				for m in $graphic/stage_gfx/mugshots.get_children():
					m.frame = mntr_frame
			
			if mntr_frame >= 3:
				$player.anim_state($player.LOOKUP)
				global.opening = 5

	if global.opening >= 4:
			
		mntr_rand -= 1
		
		if show_boss == 0:
			if mntr_frame >= 3 and mntr_rand <= 0:
				mntr_frame = floor(rand_range(3, 8))
				mntr_rand = floor(rand_range(2, 6))
				for m in $graphic/stage_gfx/mugshots.get_children():
					m.frame = mntr_frame
		else:
			for m in $graphic/stage_gfx/mugshots.get_children():
				if m.get_frame() > 12:
					if mntr_rand == 0:
						if m.get_frame() == 14:
							$graphic/stage_gfx/mugshots/left.frame = 13
							$graphic/stage_gfx/mugshots/right.frame = 13
						elif m.get_frame() == 13:
							$graphic/stage_gfx/mugshots/left.frame = 14
							$graphic/stage_gfx/mugshots/right.frame = 14
						
						mntr_rand = 3
						
			match show_boss:
				1:
					for m in $graphic/stage_gfx/mugshots.get_children():
						if !global.weapon1[0]:
							m.frame = 9
						else:
							if m.get_frame() < 13:
								m.frame = 13
								mntr_rand = 3
				2:
					for m in $graphic/stage_gfx/mugshots.get_children():
						if !global.weapon2[0]:
							m.frame = 10
						else:
							if m.get_frame() < 13:
								m.frame = 13
								mntr_rand = 3
				3:
					for m in $graphic/stage_gfx/mugshots.get_children():
						if !global.weapon3[0]:
							m.frame = 11
						else:
							if m.get_frame() < 13:
								m.frame = 13
								mntr_rand = 3
				4:
					for m in $graphic/stage_gfx/mugshots.get_children():
						if !global.weapon4[0]:
							m.frame = 12
						else:
							if m.get_frame() < 13:
								m.frame = 13
								mntr_rand = 3
	
	if global.opening == 5:
		j_delay -= 1
		
		if j_delay == 0:
			$player.jump_tap = true
			$player.jump = true
			j_release = 4
			global.opening = 6
	
	if global.opening == 6:
		j_release -= 1
		
		if j_release == 0:
			if $player.jump:
				j_release = 90
				$player.jump_tap = false
				$player.jump = false
			else:
				$player/sprite.flip_h = false
				$player.shot_dir = 1
				$hud/hud.show()
				$player.cutscene(false)
				global.opening = 7
				play_music("main")
		
	if global.opening == 7 and mntr_frame < 3:
		mntr_frame = 3
		
# SAVE THESE FOR MMC
#	if end_state == 6:
#		$player.can_move = true
#		end_state = 7
#
#	if end_state == 7:
#		leave_delay -= 1
#
#		if leave_delay == 0:
#			sound("beam_out")
#			$player.anim_state($player.APPEAR)
#			$player.can_move = false
#
#		if $player.get_child(3).offset.y == -241 and !$fade/fade.end:
#			$fade/fade.state = 10
#			$fade/fade.begin = false
#			$fade/fade.end = true
	
	if end_state != 0:
		for a in $wpn_get/mod_ctrl/top/layera.get_children() + $wpn_get/mod_ctrl/bottom/layera.get_children():
			if a.position.x <= 8:
				a.position.x = 264
			a.position.x -= 8
		for b in $wpn_get/mod_ctrl/top/layerb.get_children() + $wpn_get/mod_ctrl/bottom/layerb.get_children():
			if b.position.x <= 5:
				b.position.x = 261
			b.position.x -= 4
		for c in $wpn_get/mod_ctrl/top/layerc.get_children() + $wpn_get/mod_ctrl/bottom/layerc.get_children():
			if c.position.x <= 4:
				c.position.x = 260
			c.position.x -= 2

#These functions handle the states of the fade in node.
func _on_fade_fadein():
	
	if $fade/fade.state == 3:
		$player/anim.stop(true)
		$player.show()
		$audio/se/appear.play()
		$player/anim.play('appear1')
		if !$player.cutscene:
			$player.no_input(false)
	
	if $fade/fade.state == 7:
		$pause/pause_menu.start = true
	
	if $fade/fade.state == 9:
		get_tree().paused = false
		$player.can_move = true

func _on_fade_fadeout():
	if $fade/fade.state == 2:
		
		arr_up = false
		
		for teleport in $coll_mask/receive_pts.get_used_cells():
			var tele_id = $coll_mask/receive_pts.get_cellv(teleport)
			if tele_id == tele_dest:
				var tele_pos = $coll_mask/receive_pts.map_to_world(teleport)
			
				$player.position.x = tele_pos.x + $coll_mask/receive_pts.cell_size.x
				$player.position.y = tele_pos.y + $coll_mask/receive_pts.cell_size.y / 2

#Edit this for MMC as well.
#		for teleport in $coll_mask/spawn_pts.get_used_cells():
#			var tele_id = $coll_mask/spawn_pts.get_cellv(teleport)
#			if tele_id == tele_dest:
#				var tele_pos = $coll_mask/spawn_pts.map_to_world(teleport)
#
#				$player.position.x = tele_pos.x + $coll_mask/spawn_pts.cell_size.x
#				$player.position.y = tele_pos.y + $coll_mask/spawn_pts.cell_size.y / 2

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
# warning-ignore:return_value_discarded
			get_tree().reload_current_scene()
	
	if $fade/fade.state == 6:
		$pause/pause_menu.show()
		$fade/fade.begin = true
		$fade/fade.state = 7
	
	if $fade/fade.state == 8:
		$pause/pause_menu.hide()
		$fade/fade.begin = true
		$fade/fade.state = 9
	
	if $fade/fade.state == 10:
		if wpn_get_anim.has(global.level_id):
# warning-ignore:return_value_discarded
			get_tree().change_scene("res://scenes/new_weap.tscn")
		else:
# warning-ignore:return_value_discarded
			get_tree().change_scene("res://scenes/stage_select.tscn")

func palette_swap():
	#Set palettes for the player.
	#Character specific palettes.
	#Mega Man
	if global.player == 0:
		#Default palette
		if global.player_weap[int($player.swap)] == 0:
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
		#Super Adaptor.
		if global.player_weap[int($player.swap)] == 5:
			palette[0] = global.black
			palette[1] = global.red3
			palette[2] = global.white
	
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
		
		if global.player_weap[int($player.swap)] == 5:
			palette[0] = global.black
			palette[1] = global.green2
			palette[2] = global.blue0
			
	#Bass
	if global.player == 2:
		if global.player_weap[int($player.swap)] == 0:
			palette[0] = global.black
			palette[1] = global.grey2
			palette[2] = global.brown1
		if global.player_weap[int($player.swap)] == 5:
			palette[0] = global.black
			palette[1] = global.grey2
			palette[2] = global.purple2
	
	#Master Weapons.
	if global.player_weap[int($player.swap)] == 1:
		palette[0] = global.black
		palette[1] = global.grey3
		palette[2] = global.pink2
	if global.player_weap[int($player.swap)] == 2:
		palette[0] = global.black
		palette[1] = global.magenta2
		palette[2] = global.blue2
	if global.player_weap[int($player.swap)] == 3:
		palette[0] = global.black
		palette[1] = global.yellow3
		palette[2] = global.brown2
	if global.player_weap[int($player.swap)] == 4:
		palette[0] = global.black
		palette[1] = global.red2
		palette[2] = global.grey2
	
	#Set weapon icon.
	if global.player_weap[int($player.swap)] == 0:
		if global.player != 2:
			$player/sprite/weap_icon_lr.set_frame(0)
		else:
			$player/sprite/weap_icon_lr.set_frame(1)
	if global.player_weap[int($player.swap)] == 1:
		$player/sprite/weap_icon_lr.set_frame(7)
	if global.player_weap[int($player.swap)] == 2:
		$player/sprite/weap_icon_lr.set_frame(8)
	if global.player_weap[int($player.swap)] == 3:
		$player/sprite/weap_icon_lr.set_frame(9)
	if global.player_weap[int($player.swap)] == 4:
		$player/sprite/weap_icon_lr.set_frame(10)
	if global.player_weap[int($player.swap)] == 5:
		$player/sprite/weap_icon_lr.set_frame(11)
	
			
	#Set Colors
	#Player Sprites
	$player/sprite.material.set_shader_param('r_col1', palette[0])
	$player/sprite.material.set_shader_param('r_col2', palette[1])
	$player/sprite.material.set_shader_param('r_col3', palette[2])
	
	#HUD
	$hud/hud/weap.material.set_shader_param('r_col2', palette[1])
	$hud/hud/weap.material.set_shader_param('r_col3', palette[2])
	
	#Items
	var item_pal = get_tree().get_nodes_in_group('items')
	for i in item_pal:
		i.material.set_shader_param('r_col1', palette[0])
		i.material.set_shader_param('r_col2', palette[1])
		i.material.set_shader_param('r_col3', palette[2])
	
func spawn_objects():
	#Scan tilemap for objects.
	for cell in objects.get_used_cells():
		var id = objects.get_cellv(cell)
		var type = objects.tile_set.tile_get_name(id)
		#Get object ID and load into the level.
		if type in ['vert_gate', 'horiz_gate', 'break_block']:
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
	if $player.shot_st == $player.HANDSHOT or $player.shot_st == $player.NO_HAND:
		$player.shot_state($player.NORMAL)
	if $player.cooldown:
		$player.cooldown = false
	$player.charge = 0
	$player.chrg_lvl = 0
	palette_swap()
	kill_se("charge")
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

func enemy_dmg(key, entry):
	if wpn_dmg.has(key):
		damage = wpn_dmg.get(key)[entry]

func _on_player_whstl_end():
	play_music("")

func play_music(ogg):
	for m in $audio/music.get_children():
		if m.name == ogg:
			m.play()

func kill_music():
	for m in $audio/music.get_children():
		m.stop()

func sound(sfx):
	for s in $audio/se.get_children():
		if s.name == sfx:
			s.play()

func kill_se(sfx):
	for s in $audio/se.get_children():
		if s.name == sfx:
			s.stop()

func _on_clear_finished():
	end_state = 1

func show_shit():
	$player.show()
	for i in get_tree().get_nodes_in_group('enemies'):
		i.show()
	for b in get_tree().get_nodes_in_group('boss'):
		b.show()
	for w in get_tree().get_nodes_in_group('weapons'):
		w.show()
	for a in get_tree().get_nodes_in_group('adaptors'):
		a.show()
	$hud/hud.show()
	$player.can_move = true
	p_menu = false

func _on_fade_tween_completed(_object, _key):
	if end_state == 7:
		end_state = 8

func _on_wpn_fade_tween_completed(object, _key):
	if object.name == "bottom":
		end_state = 10
	
	if object.name == 'mod_ctrl':
		if end_state == 12:
			match which_wpn:
				0:
					global.weapon1[0] = true
				1:
					global.weapon2[0] = true
				2:
					global.weapon3[0] = true
				3:
					global.weapon4[0] = true
				
			$pause/pause_menu.hide_icons()
			cam_allow[2] = 1
			cam_allow[3] = 1
			$wpn_get/mod_ctrl/txt.set_visible_characters(0)
			$wpn_get/mod_ctrl/top.set_position(Vector2(0, 0))
			$wpn_get/mod_ctrl/bottom.set_position(Vector2(0, 0))
			$player.can_move = true
			$player.jump_mod = 1
			end_delay = 360
			boss_dead = false
			boss = false
			max_bolts = 0
			ready_boss = false
			boss_delay = 60
			fill_b_meter = false
			elec_wall = false
			wall_delay = 60
			d_appear = false
			d_delay = 60
			boss_hp = 280
			heal_delay = 0
			drop_back = 180
			$hud/hud.show()
			global.boss_num = 1
			end_state = 0
			if $graphic/spawn_tiles/cage.bosses < 3:
				play_music('main')
				$player.cutscene(false)
			else:
				$graphic/spawn_tiles/cage.cage_open = true
			#Set appropriate cutscene, if any.
			if int(global.weapon1[0]) + int(global.weapon2[0]) + int(global.weapon3[0]) + int(global.weapon4[0]) == 1 and global.scene == 0:
				global.scene = 1

func bolt_calc():
	
	print(hit_num,', ',shot_num)
	
	if hit_num > shot_num:
		hit_num = shot_num
	
	#Calculate accuracy for later.
	accuracy = (hit_num / shot_num) * 100
	
	match which_wpn:
		0:
			if time < global.b1_time and global.boss1_clear:
				$hud/boss_timer.best_flash = true
				global.b1_time = time
		1:
			if time < global.b2_time and global.boss2_clear:
				$hud/boss_timer.best_flash = true
				global.b2_time = time
		2:
			if time < global.b3_time and global.boss3_clear:
				$hud/boss_timer.best_flash = true
				global.b3_time = time
		3:
			if time < global.b4_time and global.boss4_clear:
				$hud/boss_timer.best_flash = true
				global.b4_time = time
	
	$hud/boss_timer.show_badge = true
	after_boss = true
	
	#Choose Badge
	if hits > 0 and hits < 2:
		$hud/boss_timer.set_badge += 1
	else:
		$hud/boss_timer.set_badge += 2
	
	if accuracy < 50:
		$hud/boss_timer.set_badge += 1
	
	if time > 30000:
		$hud/boss_timer.set_badge += 1
	
	#Set value for time.
	var total_time = time
	
	#Add bolts for time
	if total_time <= 30000:
		max_bolts += 10
	elif total_time >= 30001 and total_time <= 45000:
		max_bolts += 8
	elif total_time >= 45001 and total_time <= 60000:
		max_bolts += 6
	elif total_time >= 60001 and total_time <= 75000:
		max_bolts += 4
	elif total_time >= 75001 and total_time <= 90000:
		max_bolts += 2
		
	var hits_dict = {
		0 : 10,
		1 : 8,
		2 : 6,
		3 : 4,
		4 : 2
	}
	
	#Add bolts for hits taken.
	if hits <= 4:
		max_bolts += hits_dict.get(hits)
	
	if !deaths:
		max_bolts += 5
	
	if tanks:
		max_bolts = round(max_bolts / 2)
	
	print(max_bolts)

func reset_bolt_calc(all):
	shot_num = 0.0
	hit_num = 0.0
	hits = 0
	start_time = 0
	time = 0
	if all:
		deaths = false
		tanks = false

func cutscene():
	
	if $player.cutscene:
		$hud/hud.hide()
		show_text()
	else:
		if !get_tree().paused:
			$hud/hud.show()
	
	if cutsc_mode == 1:
		if $player/camera.limit_top < og_limits[0] + 64:
			$scene_txt.offset.y -= 4
			$player/camera.limit_top += 4
			$player/camera.limit_bottom += 4
		if $player/camera.limit_top == og_limits[0] + 64:
			$scene_txt/on_off.show()
			cutsc_mode = 2
	elif cutsc_mode == 3:
		if $player/camera.limit_top > og_limits[0] - c_offset_mod:
			$scene_txt.offset.y += 4
			$player/camera.limit_top -= 4
			$player/camera.limit_bottom -= 4
		if $player/camera.limit_top == og_limits[0] - c_offset_mod:
			$player.cutscene(false)
			if shop_state != 0:
				shop_state = 0
			if c_offset_mod != 0:
				c_offset_mod = 0
			cutsc_mode = 0
	
	if $player.cutscene and cutsc_mode > 0 and cutsc_mode < 3:
		if global.scene == 1:
			
			if $player.global_position.x < 2816 and $player.x_dir == 0:
				$player.x_dir = 1
			elif $player.global_position.x > 2816 and $player.x_dir == 0:
				$player.x_dir = -1
			
			if $player.global_position.x >= 2816 - 1 and $player.global_position.x <= 2816 + 1:
				if $player.x_dir != 0:
					$player.x_dir = 0
					global.scene = 2

func show_text():
	
	if !shop_active:
		var allow = false
		if global.scene != 0:
			if $scene_txt/on_off/text.get_visible_characters() < $scene_txt/on_off/text.get_total_character_count():
				$scene_txt/on_off/text.set_visible_characters($scene_txt/on_off/text.get_visible_characters() + 1)
		
		if scene_txt.get(global.sub_scene)[0] != "":
			if global.scene > 1:
				if $scene_txt/on_off/text.get_visible_characters() == $scene_txt/on_off/text.get_total_character_count():
					
					#make the cursor blink
					cursor_blnk += 1
					
					if cursor_blnk > 5:
						if $scene_txt/on_off/next.is_visible_in_tree():
							$scene_txt/on_off/next.hide()
						else:
							$scene_txt/on_off/next.show()
						cursor_blnk = 0
					
					if !allow:
						allow = true
			else:
				if cursor_blnk != 0:
					cursor_blnk = 0
				if $scene_txt/on_off/next.is_visible_in_tree():
					$scene_txt/on_off/next.hide()
		else:
			if cursor_blnk != 0:
				cursor_blnk = 0
			if $scene_txt/on_off/next.is_visible_in_tree():
				$scene_txt/on_off/next.hide()
			match global.scene:
				2:
					if global.sub_scene == 3:
						global.scene = 3
				5:
					if global.sub_scene == 15:
						cutsc_mode = 3
						play_music("main")
						for c in get_tree().get_nodes_in_group("cutscene"):
							c.queue_free()
						$graphic/spawn_tiles/shop/auto.show()
						$graphic/spawn_tiles/shop/auto/anim.play("idle")
						$graphic/spawn_tiles/shop/eddie.show()
						$graphic/spawn_tiles/shop/eddie/anim.play("idle")
						shop_active = true
						global.scene = 6
				8:
					if global.sub_scene == 24:
						cutsc_mode = 3
						play_music("main")
						shop_active = true
						global.scene = 9
		
		if allow and Input.is_action_just_pressed("jump") and $player.cutscene:
			if cursor_blnk != 0:
				cursor_blnk = 0
			if $scene_txt/on_off/next.is_visible_in_tree():
				$scene_txt/on_off/next.hide()
			$scene_txt/on_off/text.set_visible_characters(0)
			global.sub_scene += 1
			
		if global.scene == 2 or global.scene == 5 or global.scene == 8:
			$scene_txt/on_off/name.set_text(scene_txt.get(global.sub_scene)[0])
			$scene_txt/on_off/text.set_text(scene_txt.get(global.sub_scene)[1])
		
		if global.scene == 3:
			sound("fall")
			var scene_auto = load("res://scenes/cutscene/scene_auto.tscn").instance()
			scene_auto.position.x = $graphic/spawn_tiles/shop/auto.global_position.x
			scene_auto.position.y = $player/camera.limit_top - 50
			$graphic/spawn_tiles.add_child(scene_auto)
			$player/sprite.flip_h = true
			$player.anim_state($player.LOOKUP)
			global.scene = 4

func _on_intro_finished():
	$player.anim_state($player.LOOKUP)
	sound("fall")
	var scene_eddie = load("res://scenes/cutscene/scene_eddie.tscn").instance()
	scene_eddie.position.x = $graphic/spawn_tiles/shop/auto.global_position.x - 4
	scene_eddie.position.y = $player/camera.limit_top - 28
	$graphic/spawn_tiles.add_child(scene_eddie)

func shop():
	
	#Handle animations for the shop.
	#Auto
	if shop_state != 10:
		if $scene_txt/on_off/name.get_text() == "AUTO:" and $graphic/spawn_tiles/shop/auto/anim.get_current_animation() != "talk":
			$graphic/spawn_tiles/shop/auto/anim.play('talk')
		elif $scene_txt/on_off/name.get_text() != "AUTO:" and $graphic/spawn_tiles/shop/auto/anim.get_current_animation() != "idle":
			$graphic/spawn_tiles/shop/auto/anim.play('idle')
	
	#Screw Countdown
	if shop_state == 10:
		if global.bolts != screws and !countdown:
			$graphic/spawn_tiles/shop/menu/screws/countdown.interpolate_property(self, 'screws', screws, global.bolts, 0.25)
			$graphic/spawn_tiles/shop/menu/screws/countdown.start()
			countdown = true
		
		if int($graphic/spawn_tiles/shop/menu/screws.get_text()) != screws:
			$graphic/spawn_tiles/shop/menu/screws.set_text(str(round(screws)))
		
		if screws == global.bolts and countdown:
			countdown = false
	
	if shop_active:
		
		if shop_state >= 5 and shop_state < 8:
			if !Input.is_action_pressed('jump') and !Input.is_action_pressed('fire'):
				next = true
		
		match shop_state:
			0:
				if $graphic/spawn_tiles/shop/menu.is_visible_in_tree():
					$graphic/spawn_tiles/shop/menu.hide()
			1:
				
				if menu_flsh == 1:
					$graphic/spawn_tiles/shop/menu.show()
				elif menu_flsh == 0:
					$graphic/spawn_tiles/shop/menu.hide()
				
				if $player.global_position.x < 2816:
					$player.x_dir = 1
				else:
					$player.global_position.x = 2816
					$player.x_dir = 0
					$player.hide()
					$graphic/spawn_tiles/shop/fakeplyr.show()
					$graphic/spawn_tiles/shop/menu.show()
					shop_state += 1
					
			2:
				$player.hide()
				cutsc_mode = 1
				shop_active = true
				shop_state += 1
			3:
				if cutsc_mode == 2:
					$scene_txt/on_off/text.set_visible_characters(0)
					$scene_txt/on_off/name.set_text(shop_text.get(0)[0])
					$scene_txt/on_off/text.set_text(shop_text.get(int(shop_rand))[1])
					$scene_txt/on_off.show()
					shop_state += 1
			4:
				if $scene_txt/on_off/text.get_visible_characters() == $scene_txt/on_off/text.get_total_character_count():
					cursor_blnk += 1
					
					if cursor_blnk > 5:
						if $scene_txt/on_off/next.is_visible_in_tree():
							$scene_txt/on_off/next.hide()
						else:
							$scene_txt/on_off/next.show()
						cursor_blnk = 0
					
					if !next:
							next = true
					
				else:
					if cursor_blnk != 0:
						cursor_blnk = 0
					if $scene_txt/on_off/next.is_visible_in_tree():
						$scene_txt/on_off/next.hide()
						
						
				if next and Input.is_action_just_pressed("jump"):
					cursor_blnk = 0
					if $scene_txt/on_off/next.is_visible_in_tree():
						$scene_txt/on_off/next.hide()
					$scene_txt/on_off/text.set_visible_characters(0)
					$scene_txt/on_off/name.set_text(shop_text.get(shop_pos + 8)[0])
					$scene_txt/on_off/text.set_text(shop_text.get(shop_pos + 8)[1])
					shop_state += 1
					next = false
			
			5: #Actual shop functions.
				var reset_txt = false
				
				if shop_pos == 0:
					$graphic/spawn_tiles/shop/menu/icon1.frame = 0
				else:
					$graphic/spawn_tiles/shop/menu/icon1.frame = 8
				
				if shop_pos == 1:
					$graphic/spawn_tiles/shop/menu/icon2.frame = 1
				else:
					$graphic/spawn_tiles/shop/menu/icon2.frame = 9
				
				if shop_pos == 2:
					$graphic/spawn_tiles/shop/menu/icon3.frame = 2
				else:
					$graphic/spawn_tiles/shop/menu/icon3.frame = 10
				
				if shop_pos == 3:
					$graphic/spawn_tiles/shop/menu/icon4.frame = 4
				else:
					$graphic/spawn_tiles/shop/menu/icon4.frame = 12
				
				if shop_pos == 4:
					$graphic/spawn_tiles/shop/menu/icon5.frame = 4
				else:
					$graphic/spawn_tiles/shop/menu/icon5.frame = 12
					
				if shop_pos == 5:
					$graphic/spawn_tiles/shop/menu/icon6.frame = 4
				else:
					$graphic/spawn_tiles/shop/menu/icon6.frame = 12
				
				if !reset_txt:
					if Input.is_action_just_pressed("up"):
						if shop_pos >= 3 and shop_pos <= 5:
							sound('cursor')
							shop_pos -= 3
							reset_txt = true
					
					if Input.is_action_just_pressed("down"):
						if shop_pos >= 0 and shop_pos <= 2:
							sound('cursor')
							shop_pos += 3
							reset_txt = true
					
					if Input.is_action_just_pressed("left"):
						if shop_pos > 3 and shop_pos <= 5 or shop_pos > 0 and shop_pos <= 2:
							sound('cursor')
							shop_pos -= 1
							reset_txt = true
					
					if Input.is_action_just_pressed("right"):
						if shop_pos >= 3 and shop_pos < 5 or shop_pos >= 0 and shop_pos < 2:
							sound('cursor')
							shop_pos += 1
							reset_txt = true
				
				#Display the appropriate text.
				if reset_txt:
					$scene_txt/on_off/text.set_visible_characters(0)
					if shop_pos >= 0 and shop_pos <=2:
						$scene_txt/on_off/name.set_text(shop_text.get(shop_pos + 8)[0])
						$scene_txt/on_off/text.set_text(shop_text.get(shop_pos + 8)[1])
					else: #These items are currently unavailable.
						$scene_txt/on_off/name.set_text(shop_text.get(15)[0])
						$scene_txt/on_off/text.set_text(shop_text.get(15)[1])
					reset_txt = false
				
				if next and Input.is_action_just_pressed("jump"):
					$scene_txt/on_off/text.set_visible_characters(0)
					#Begin checks.
					
					#Check item and see if available.
					if prices[shop_pos] == -1:
						sound('buzz')
					else:
						#Item IS available, check bolts.
						if global.bolts >= prices[shop_pos]:
							#Check if maximum obtained.
							if shop_pos == 0:#Check Life and Weapon Energy
								var hp_mp = global.player_life[0] + global.weapon1[1] + global.weapon2[1] + global.weapon3[1] + global.weapon4[1]
								if hp_mp == 1400:
									sound('buzz')
									$scene_txt/on_off/name.set_text(shop_text.get(7)[0])
									$scene_txt/on_off/text.set_text(shop_text.get(7)[1])
								else:
									$scene_txt/on_off/name.set_text(shop_text.get(14)[0])
									$scene_txt/on_off/text.set_text(shop_text.get(14)[1])
									shop_state = 6
							if shop_pos == 1:
								if global.etanks == 4:
									sound('buzz')
									$scene_txt/on_off/name.set_text(shop_text.get(7)[0])
									$scene_txt/on_off/text.set_text(shop_text.get(7)[1])
								else:
									$scene_txt/on_off/name.set_text(shop_text.get(14)[0])
									$scene_txt/on_off/text.set_text(shop_text.get(14)[1])
									shop_state = 6
							if shop_pos == 2:
								if global.wtanks == 1:
									sound('buzz')
									$scene_txt/on_off/name.set_text(shop_text.get(7)[0])
									$scene_txt/on_off/text.set_text(shop_text.get(7)[1])
								else:
									$scene_txt/on_off/name.set_text(shop_text.get(14)[0])
									$scene_txt/on_off/text.set_text(shop_text.get(14)[1])
									shop_state = 6
						else:
							sound('buzz')
							$scene_txt/on_off/name.set_text(shop_text.get(6)[0])
							$scene_txt/on_off/text.set_text(shop_text.get(6)[1])
					next = false
					
				#Cancel out of shop
				elif next and Input.is_action_just_pressed("fire"):
					$scene_txt/on_off/text.set_visible_characters(0)
					$scene_txt/on_off/name.set_text(shop_text.get(16)[0])
					$scene_txt/on_off/text.set_text(shop_text.get(16)[1])
					next = false
					shop_state = 8
			6:
				if next and Input.is_action_just_pressed("jump"):
					#Start tween for the screw countdown
					
					buy_rand = int(round(rand_range(3, 5)))
					
					$scene_txt/on_off/text.set_visible_characters(0)
					$scene_txt/on_off/name.set_text(shop_text.get(buy_rand)[0])
					$scene_txt/on_off/text.set_text(shop_text.get(buy_rand)[1])
					
					sound('buy')
					global.bolts -= prices[shop_pos]
					$graphic/spawn_tiles/shop/fakeplyr.frame = 1
					
					$graphic/spawn_tiles/shop/eddie/anim.play("spit-a")
					
					shop_state = 10
					next = false
				elif next and Input.is_action_just_pressed("fire"):
					$scene_txt/on_off/text.set_visible_characters(0)
					$scene_txt/on_off/name.set_text(shop_text.get(17)[0])
					$scene_txt/on_off/text.set_text(shop_text.get(17)[1])
					shop_state = 7
					next = false
			
			7:
				if next and Input.is_action_just_pressed("jump") or Input.is_action_just_pressed("fire"):
					$scene_txt/on_off/text.set_visible_characters(0)
					if shop_pos >= 0 and shop_pos <=2:
						$scene_txt/on_off/name.set_text(shop_text.get(shop_pos + 8)[0])
						$scene_txt/on_off/text.set_text(shop_text.get(shop_pos + 8)[1])
					else: #These items are currently unavailable.
						$scene_txt/on_off/name.set_text(shop_text.get(15)[0])
						$scene_txt/on_off/text.set_text(shop_text.get(15)[1])
					shop_state = 5
					next = false
			
			8: #Cancel out of shop.
				if $scene_txt/on_off/text.get_visible_characters() == $scene_txt/on_off/text.get_total_character_count():
					cursor_blnk += 1
					
					if cursor_blnk > 5:
						if $scene_txt/on_off/next.is_visible_in_tree():
							$scene_txt/on_off/next.hide()
						else:
							$scene_txt/on_off/next.show()
						cursor_blnk = 0
					if !next:
						next = true
				
				if next:
					if Input.is_action_just_pressed("jump") or Input.is_action_just_pressed("fire"):
						cursor_blnk = 0
						if $scene_txt/on_off/next.is_visible_in_tree():
							$scene_txt/on_off/next.hide()
						kill_music()
						play_music('main')
						cutsc_mode += 1
						shop_state = 9
						$graphic/spawn_tiles/shop/fakeplyr.hide()
						$player.show()
						$scene_txt/on_off/name.set_text("")
						$scene_txt/on_off/text.set_text("")
						next = false
			
			9:
				if menu_flsh == 1:
					$graphic/spawn_tiles/shop/menu.show()
				elif menu_flsh == 0:
					$graphic/spawn_tiles/shop/menu.hide()
			
			10: #Purchase item.
				
				for s in get_tree().get_nodes_in_group('spit'):
					
					if s.global_position.x < $player.global_position.x and $graphic/spawn_tiles/shop/fakeplyr.frame == 3:
						$graphic/spawn_tiles/shop/fakeplyr.frame = 4
					
					if s.global_position.x < $graphic/spawn_tiles/shop/auto.global_position.x:
						s.velocity = Vector2(100, -160)
						$graphic/spawn_tiles/shop/auto/anim.play('bounce')
						$graphic/spawn_tiles/shop/fakeplyr.frame = 2
						sound('dink')
					
					if s.plyr_det != []:
						#Add the appropriate items.
						if shop_pos == 0:
							global.player_life[0] = 280
							global.weapon1[1] = 280
							global.weapon2[1] = 280
							global.weapon3[1] = 280
							global.weapon4[1] = 280
						elif shop_pos == 1:
							global.etanks += 1
						elif shop_pos == 2:
							global.wtanks += 1
						sound('1up')
						shop_state = 11
						$graphic/spawn_tiles/shop/eddie/anim.play("spit-b")
						s.queue_free()
			11:
				ret_delay -= 1
				
				if ret_delay == 0:
					$graphic/spawn_tiles/shop/fakeplyr.frame = 0
					if shop_pos >= 0 and shop_pos <=2:
						$scene_txt/on_off/name.set_text(shop_text.get(shop_pos + 8)[0])
						$scene_txt/on_off/text.set_text(shop_text.get(shop_pos + 8)[1])
					else: #These items are currently unavailable.
						$scene_txt/on_off/name.set_text(shop_text.get(15)[0])
						$scene_txt/on_off/text.set_text(shop_text.get(15)[1])
					ret_delay = 12
					shop_state = 5
						
		
		if shop_state > 3:
			if shop_active:
				if $scene_txt/on_off/text.get_visible_characters() < $scene_txt/on_off/text.get_total_character_count():
					$scene_txt/on_off/text.set_visible_characters($scene_txt/on_off/text.get_visible_characters() + 1)


func eddie_spit(anim_name):
	if anim_name == 'spit-a':
		
		$graphic/spawn_tiles/shop/auto/anim.play('idle')
		
		$scene_txt/on_off/text.set_visible_characters(0)
		$scene_txt/on_off/name.set_text('')
		$scene_txt/on_off/text.set_text('')
		
		var spit_dist = int(round(rand_range(0, 11)))
		var spit_vel = Vector2()
		
		if spit_dist == 0:
			$graphic/spawn_tiles/shop/fakeplyr.frame = 3
			spit_vel = Vector2(-150, -310)
		else:
			spit_vel = Vector2(-100, -225)
		
		sound('throw')
		var spit = load('res://scenes/objects/eddie-spit.tscn').instance()
		spit.get_child(0).frame = shop_pos
		spit.velocity = spit_vel
		spit.global_position.x = $graphic/spawn_tiles/shop/eddie.global_position.x
		spit.global_position.y = $graphic/spawn_tiles/shop/eddie.global_position.y - 8
		$graphic.add_child(spit)
	
	if anim_name == 'spit-b':
		$graphic/spawn_tiles/shop/eddie/anim.play('idle')
