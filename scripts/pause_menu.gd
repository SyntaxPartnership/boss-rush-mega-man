extends Node2D

onready var icons = get_tree().get_nodes_in_group('item_icon')
onready var world = get_parent().get_parent()
onready var player = get_parent().get_parent().get_child(2)

var wpn_lvl = []

# warning-ignore:unused_class_variable
var kill_wpn

var ignore_input = false
var heal_delay = 0
var heal_type = 0
var heal_amt = 0

var start = false

var new_plyr
var new_wpn
var new_menu = 0

var press = false
var menu = 0
var m_pos = 0

var blink = 8

var down_a = 1
var down_b = 0

var color_set
var get_meters
var get_plyr

var sel_color = [Color(), Color(), global.yellow0, global.white]
var desel_color = [global.grey3, global.grey2, global.grey1, global.grey0]

# Called when the node enters the scene tree for the first time.
func _ready():
	
	if global.player_id[1] == 99:
		$plyr_2.hide()
	
	color_set = get_tree().get_nodes_in_group('wpn_icons')
	get_meters = get_tree().get_nodes_in_group('meters')
	get_plyr = get_tree().get_nodes_in_group('plyr_icon')
	
	set_max()
	set_names()
	hide_icons()
	menu_color()
	
	for c in color_set:
		c.material.set_shader_param('black', global.black)
		c.material.set_shader_param('t_col1', global.t_color2)
		c.material.set_shader_param('t_col2', global.t_color3)
		c.material.set_shader_param('t_col3', global.yellow0)
		c.material.set_shader_param('t_col4', global.white)
	
	for g in get_meters:
		g.material.set_shader_param('black', global.black)
		g.material.set_shader_param('t_col1', global.t_color2)
		g.material.set_shader_param('t_col2', global.t_color3)
		g.material.set_shader_param('t_col3', global.yellow0)
		g.material.set_shader_param('t_col4', global.white)
	
	for p in get_plyr:
		p.material.set_shader_param('black', global.black)
		p.material.set_shader_param('t_col1', global.t_color2)
		p.material.set_shader_param('t_col2', global.t_color3)
		p.material.set_shader_param('t_col3', global.yellow0)
		p.material.set_shader_param('t_col4', global.white)
		
	#Update number of lives.
	$lives_amt.set_text('0'+str(global.lives))

# warning-ignore:unused_argument
func _input(event):
	if !get_tree().paused or !start:
		return
	
	if ignore_input:
		return
	#Weapons menu.
	#Set the weapon values.
	if menu == 0:
		#Set this section here to prevent issues transitioning between weapon selection and item selection.
		if Input.is_action_just_pressed('up'):
			$cursor.play()
			#Left Side
			if global.player_weap[int(player.swap)] > 0 and global.player_weap[int(player.swap)] <= 5:
				global.player_weap[int(player.swap)] -= 1
			#Right Side
			if global.player_weap[int(player.swap)] > 6 and global.player_weap[int(player.swap)] <= 11:
				global.player_weap[int(player.swap)] -= 1
		
		if Input.is_action_just_pressed('down'):
			$cursor.stop()
			$cursor.play()
			#Left Side
			if global.player_weap[int(player.swap)] >= 0 and global.player_weap[int(player.swap)] < down_a:
				global.player_weap[int(player.swap)] += 1
				press = true
			#Right Side
			if global.player_weap[int(player.swap)] >= 6 and global.player_weap[int(player.swap)] < down_b:
				global.player_weap[int(player.swap)] += 1
				press = true
		
		if global.player_weap[int(player.swap)] == down_a or global.player_weap[int(player.swap)] == down_b:
			if Input.is_action_just_pressed('down') and !press:
				menu += 1
		
		if Input.is_action_just_pressed('up'):
			#Skip unacquired weapons.
			#Left Side
			if global.player_weap[int(player.swap)] == 5 and !global.weapon3[0]:
				global.player_weap[int(player.swap)] -= 1
			if global.player_weap[int(player.swap)] == 4 and !global.weapon2[0]:
				global.player_weap[int(player.swap)] -= 1
			if global.player_weap[int(player.swap)] == 3 and !global.weapon1[0]:
				global.player_weap[int(player.swap)] -= 1
			if global.player_weap[int(player.swap)] == 2 and !global.rp_jet[0] or global.player_weap[int(player.swap)] == 2 and global.player != 0:
				global.player_weap[int(player.swap)] -= 1
			
			#Right Side (Weapon ID 6 is skipped because the player should not be able to access this side when down_b = 0)
			if global.player == 0 and global.player_weap[int(player.swap)] == 11 and !global.beat[0]:
				global.player_weap[int(player.swap)] -= 1
			if global.player == 1 and global.player_weap[int(player.swap)] == 11 and !global.tango[0]:
				global.player_weap[int(player.swap)] -= 1
			if global.player == 2 and global.player_weap[int(player.swap)] == 11 and !global.reggae[0]:
				global.player_weap[int(player.swap)] -= 1
			if global.player_weap[int(player.swap)] == 10 and !global.weapon8[0]:
				global.player_weap[int(player.swap)] -= 1
			if global.player_weap[int(player.swap)] == 9 and !global.weapon7[0]:
				global.player_weap[int(player.swap)] -= 1
			if global.player_weap[int(player.swap)] == 8 and !global.weapon6[0]:
				global.player_weap[int(player.swap)] -= 1
			if global.player_weap[int(player.swap)] == 7 and !global.weapon5[0]:
				global.player_weap[int(player.swap)] -= 1
		
		if Input.is_action_just_pressed('down'):
			#Skip unacquired weapons.
			#Left Side
			if global.player_weap[int(player.swap)] == 2 and !global.rp_jet[0] or global.player_weap[int(player.swap)] == 2 and global.player != 0:
				global.player_weap[int(player.swap)] += 1
			if global.player_weap[int(player.swap)] == 3 and !global.weapon1[0]:
				global.player_weap[int(player.swap)] += 1
			if global.player_weap[int(player.swap)] == 4 and !global.weapon2[0]:
				global.player_weap[int(player.swap)] += 1
			if global.player_weap[int(player.swap)] == 5 and !global.weapon3[0]:
				global.player_weap[int(player.swap)] += 1
			
			#Right Side
			if global.player_weap[int(player.swap)] == 6 and !global.weapon4[0]:
				global.player_weap[int(player.swap)] += 1
			if global.player_weap[int(player.swap)] == 7 and !global.weapon5[0]:
				global.player_weap[int(player.swap)] += 1
			if global.player_weap[int(player.swap)] == 8 and !global.weapon6[0]:
				global.player_weap[int(player.swap)] += 1
			if global.player_weap[int(player.swap)] == 9 and !global.weapon7[0]:
				global.player_weap[int(player.swap)] += 1
			if global.player_weap[int(player.swap)] == 10 and !global.weapon8[0]:
				global.player_weap[int(player.swap)] += 1
		
		if Input.is_action_just_pressed('left'):
			$cursor.stop()
			$cursor.play()
			#Move selection to left side.
			if global.player_weap[int(player.swap)] > 5:
				global.player_weap[int(player.swap)] -= 6
			
		if Input.is_action_just_pressed('left'):
			#Skip unacquired weapons.
			if global.player_weap[int(player.swap)] > down_a and global.player_weap[int(player.swap)] < 6:
				global.player_weap[int(player.swap)] = down_a
			if global.player_weap[int(player.swap)] == 2 and !global.rp_jet[0] or global.player_weap[int(player.swap)] == 2 and global.player != 0:
				global.player_weap[int(player.swap)] -= 1
		
		if Input.is_action_just_pressed('right'):
			$cursor.stop()
			$cursor.play()
			#Move selection to the right side.
			if down_b != 0 and global.player_weap[int(player.swap)] < 6:
				global.player_weap[int(player.swap)] += 6
		
		if Input.is_action_just_pressed('right'):
			#Move selection to the right side.
			if global.player_weap[int(player.swap)] > down_b and global.player_weap[int(player.swap)] > 5:
				global.player_weap[int(player.swap)] = down_b
	
	if menu != 0:
		#Items menu.
		#Move through items.
		if Input.is_action_just_pressed('up'):
			print(global.player_weap[int(player.swap)])
			$cursor.stop()
			$cursor.play()
			#There's no need to set the value to down_a or down_b as the player cannot proceed passed these values.
			menu -= 1
			if !$e_tanks/icon.visible:
				$e_tanks/icon.show()
			if !$m_tanks/icon.visible:
				$m_tanks/icon.show()
			if !$et_call/icon.visible:
				$et_call/icon.show()
			if !$half_dmg/icon.visible:
				$half_dmg/icon.show()
			if !$spk_prtct/icon.visible:
				$spk_prtct/icon.show()
			wpn_menu()
		
		if Input.is_action_just_pressed('left'):
			$cursor.stop()
			$cursor.play()
			if m_pos > 0:
				m_pos -= 1
		
		if Input.is_action_just_pressed('right'):
			$cursor.stop()
			$cursor.play()
			if m_pos < 4:
				m_pos += 1
		
		if Input.is_action_just_pressed('jump') and m_pos == 0:
			if global.etanks > 0 and global.player_life[int(player.swap)] < 280:
				ignore_input = true
				global.etanks -= 1
				heal_type = 1
			else:
				world.get_child(9).get_child(7).play()
		
		if Input.is_action_just_pressed('jump') and m_pos == 1:
			if global.mtanks > 0:
				var levels = []
				if global.player == 0:
					levels = [
						global.player_life[int(player.swap)],
						global.rp_coil[int(player.swap) + 1],
						global.rp_jet[int(player.swap) + 1],
						global.weapon1[int(player.swap) + 1],
						global.weapon2[int(player.swap) + 1],
						global.weapon3[int(player.swap) + 1],
						global.weapon4[int(player.swap) + 1],
						global.weapon5[int(player.swap) + 1],
						global.weapon6[int(player.swap) + 1],
						global.weapon7[int(player.swap) + 1],
						global.weapon8[int(player.swap) + 1],
						global.beat[int(player.swap) + 1],
						]
				if global.player == 1:
					levels = [
						global.player_life[int(player.swap)],
						global.rp_coil[int(player.swap) + 1],
						global.rp_jet[int(player.swap) + 1],
						global.weapon1[int(player.swap) + 1],
						global.weapon2[int(player.swap) + 1],
						global.weapon3[int(player.swap) + 1],
						global.weapon4[int(player.swap) + 1],
						global.weapon5[int(player.swap) + 1],
						global.weapon6[int(player.swap) + 1],
						global.weapon7[int(player.swap) + 1],
						global.weapon8[int(player.swap) + 1],
						global.tango[int(player.swap) + 1],
						]
				if global.player == 2:
					levels = [
						global.player_life[int(player.swap)],
						global.rp_coil[int(player.swap) + 1],
						global.rp_jet[int(player.swap) + 1],
						global.weapon1[int(player.swap) + 1],
						global.weapon2[int(player.swap) + 1],
						global.weapon3[int(player.swap) + 1],
						global.weapon4[int(player.swap) + 1],
						global.weapon5[int(player.swap) + 1],
						global.weapon6[int(player.swap) + 1],
						global.weapon7[int(player.swap) + 1],
						global.weapon8[int(player.swap) + 1],
						global.reggae[int(player.swap) + 1],
						]
				
				if levels.min() < 280:
					heal_amt = ((levels.min() - 280) * -1) / 10
					heal_type = 2
				else:
					var oneups = get_tree().get_nodes_in_group('enemies')
					for e in oneups:
						if e.get_child(4).is_on_screen():
							e.hp = 0
							e.dead = true
							e.get_child(2).hide()
							var extra = load('res://scenes/objects/1up.tscn').instance()
							extra.type = 8
							extra.position = e.position
							world.get_child(1).add_child(extra)
				
				global.mtanks -= 1

# warning-ignore:unused_argument
func _process(delta):
	
	if Input.is_action_just_released("down"):
		press = false
	
	#Begin the healing loop
	if heal_type != 0:
		heal_delay += 1
		
		if heal_delay > 1:
			heal_delay = 0
		
		#Refill health only.
		if heal_type == 1 and heal_delay == 1 and global.player_life[int(player.swap)] < 280:
			world.get_child(9).get_child(6).play()
			global.player_life[int(player.swap)] += 10
		
		#Refill all for the active player. Set caps for energy over a certain amount.
		if heal_type == 2 and heal_delay == 1 and heal_amt > 0:
			world.get_child(9).get_child(6).play()
			
			if global.player_life[int(player.swap)] < 280:
				global.player_life[int(player.swap)] += 10
			
			if global.rp_coil[int(player.swap) + 1] < 280:
				global.rp_coil[int(player.swap) + 1] += 10
			
			if global.rp_jet[int(player.swap) + 1] < 280:
				global.rp_jet[int(player.swap) + 1] += 10
			
			if global.weapon1[int(player.swap) + 1] < 280:
				global.weapon1[int(player.swap) + 1] += 10
			
			if global.weapon2[int(player.swap) + 1] < 280:
				global.weapon2[int(player.swap) + 1] += 10
			
			if global.weapon3[int(player.swap) + 1] < 280:
				global.weapon3[int(player.swap) + 1] += 10
			
			if global.weapon4[int(player.swap) + 1] < 280:
				global.weapon4[int(player.swap) + 1] += 10
			
			if global.weapon5[int(player.swap) + 1] < 280:
				global.weapon5[int(player.swap) + 1] += 10
			
			if global.weapon6[int(player.swap) + 1] < 280:
				global.weapon6[int(player.swap) + 1] += 10
			
			if global.weapon7[int(player.swap) + 1] < 280:
				global.weapon7[int(player.swap) + 1] += 10
			
			if global.weapon8[int(player.swap) + 1] < 280:
				global.weapon8[int(player.swap) + 1] += 10
			
			if global.beat[int(player.swap) + 1] < 280:
				global.beat[int(player.swap) + 1] += 10
			
			if global.tango[int(player.swap) + 1] < 280:
				global.tango[int(player.swap) + 1] += 10
			
			if global.reggae[int(player.swap) + 1] < 280:
				global.reggae[int(player.swap) + 1] += 10
			
			heal_amt -= 1
		
		if heal_type == 1 and global.player_life[int(player.swap)] == 280:
			ignore_input = false
			heal_delay = 0
			heal_type = 0
		
		if heal_type == 2 and heal_amt == 0:
			ignore_input = false
			heal_delay = 0
			heal_type = 0
	
	#Set the appropriate number of bolts., etanks, and mtanks
	if int($bolts_amt.get_text()) != global.bolts:
		if global.bolts < 10:
			$bolts_amt.set_text('00'+str(global.bolts))
		elif global.bolts >= 10 and global.bolts < 100:
			$bolts_amt.set_text('0'+str(global.bolts))
		else:
			$bolts_amt.set_text(str(global.bolts))
	
	if int($e_tanks/amt.get_text()) != global.etanks:
		$e_tanks/amt.set_text('0'+str(global.etanks))
	
	if int($m_tanks/amt.get_text()) != global.mtanks:
		$m_tanks/amt.set_text('0'+str(global.mtanks))
	
	#Update meter levels.
	#Life Meters.
	if $weap_01/meter.value != global.player_life[int(player.swap)]:
		$weap_01/meter.value = global.player_life[int(player.swap)]
		$plyr_1/meter.value = global.player_life[0]
		$plyr_2/meter.value = global.player_life[1]
	
	#Weapon Meters
	if $weap_02/meter.value != global.rp_coil[int(player.swap) + 1]:
		$weap_02/meter.value = global.rp_coil[int(player.swap) + 1]
	if $weap_03/meter.value != global.rp_jet[int(player.swap) + 1]:
		$weap_03/meter.value = global.rp_jet[int(player.swap) + 1]
	if $weap_04/meter.value != global.weapon1[int(player.swap) + 1]:
		$weap_04/meter.value = global.weapon1[int(player.swap) + 1]
	if $weap_05/meter.value != global.weapon2[int(player.swap) + 1]:
		$weap_05/meter.value = global.weapon2[int(player.swap) + 1]
	if $weap_06/meter.value != global.weapon3[int(player.swap) + 1]:
		$weap_06/meter.value = global.weapon3[int(player.swap) + 1]
	if $weap_07/meter.value != global.weapon4[int(player.swap) + 1]:
		$weap_07/meter.value = global.weapon4[int(player.swap) + 1]
	if $weap_08/meter.value != global.weapon5[int(player.swap) + 1]:
		$weap_08/meter.value = global.weapon5[int(player.swap) + 1]
	if $weap_09/meter.value != global.weapon6[int(player.swap) + 1]:
		$weap_09/meter.value = global.weapon6[int(player.swap) + 1]
	if $weap_10/meter.value != global.weapon7[int(player.swap) + 1]:
		$weap_10/meter.value = global.weapon7[int(player.swap) + 1]
	if $weap_11/meter.value != global.weapon8[int(player.swap) + 1]:
		$weap_11/meter.value = global.weapon8[int(player.swap) + 1]
	
	#Extra Adaptors
	if global.player == 0:
		if $weap_12/meter.value != global.beat[int(player.swap) + 1]:
			$weap_12/meter.value = global.beat[int(player.swap) + 1]
	if global.player == 1:
		if $weap_12/meter.value != global.tango[int(player.swap) + 1]:
			$weap_12/meter.value = global.tango[int(player.swap) + 1]
	if global.player == 2:
		if $weap_12/meter.value != global.reggae[int(player.swap) + 1]:
			$weap_12/meter.value = global.reggae[int(player.swap) + 1]
	
	if new_wpn != global.player_weap[int(player.swap)]:
		new_wpn = global.player_weap[int(player.swap)]
		wpn_menu()
	
	if new_menu != menu:
		new_wpn = menu
		wpn_menu()

	item_menu()

func menu_color():
	if new_plyr != global.player:
		#Set the appropriate colors for the menu.
		$background.tile_set = load('res://assets/tilesets/menu/option-stage_'+str(global.player)+'.tres')
		
		for i in icons:
			i.texture = load('res://assets/sprites/pause/icons_'+str(global.player)+'.png')
		
		#Set active characer's color.
		get_plyr[int(!player.swap)].material.set_shader_param('r_col1', desel_color[0])
		get_plyr[int(!player.swap)].material.set_shader_param('r_col2', desel_color[1])
		get_plyr[int(!player.swap)].material.set_shader_param('r_col3', desel_color[1])
		get_plyr[int(!player.swap)].material.set_shader_param('r_col4', desel_color[2])
		
		#Set active character's meter color
		get_meters[int(player.swap)+1].material.set_shader_param('r_col1', sel_color[2])
		get_meters[int(player.swap)+1].material.set_shader_param('r_col2', sel_color[3])
		
		get_meters[int(!player.swap)+1].material.set_shader_param('r_col1', desel_color[0])
		get_meters[int(!player.swap)+1].material.set_shader_param('r_col2', desel_color[1])
		
		if player.swap:
			$plyr_1/text.set('custom_colors/font_color', desel_color[2])
		else:
			$plyr_2/text.set('custom_colors/font_color', desel_color[2])
		
		wpn_lvl = [
				global.player_life[int(player.swap)],
				global.rp_coil[int(player.swap) + 1],
				global.rp_jet[int(player.swap) + 1],
				global.weapon1[int(player.swap) + 1],
				global.weapon2[int(player.swap) + 1],
				global.weapon3[int(player.swap) + 1],
				global.weapon4[int(player.swap) + 1],
				global.weapon5[int(player.swap) + 1],
				global.weapon6[int(player.swap) + 1],
				global.weapon7[int(player.swap) + 1], 
				global.weapon8[int(player.swap) + 1],
				global.beat[int(player.swap) + 1],
				global.tango[int(player.swap) + 1],
				global.reggae[int(player.swap) + 1]
				]
		
		#This section is also used to update the player's meter levels.
		for i in range(color_set.size()):
			for n in range(wpn_lvl.size()):
				if n < 11:
					if i == n:
						color_set[i].get_child(2).set('value', wpn_lvl[n])
				if n >= 11:
					color_set[11].get_child(2).set('value', wpn_lvl[11 + global.player])
				get_meters[1].set('value', global.player_life[0])
				get_meters[2].set('value', global.player_life[1])
		
		#Update how many items are in possession as well.
					
		new_plyr = global.player

func set_max():
	#Check weapons to see what the max menu value for each side is.
	#Left side.
	if global.rp_jet[0] and global.player != 2:
		down_a = 2
	if global.weapon1[0]:
		down_a = 3
	if global.weapon2[0]:
		down_a = 4
	if global.weapon3[0]:
		down_a = 5
	
	#Right side
	if global.weapon4[0]:
		down_b = 6
	if global.weapon5[0]:
		down_b = 7
	if global.weapon6[0]:
		down_b = 8
	if global.weapon7[0]:
		down_b = 9
	if global.weapon8[0]:
		down_b = 10
	if global.beat[0] and global.player == 0 or global.tango[0] and global.player == 1 or global.reggae[0] and global.player == 2:
		down_b = 11

func hide_icons():
	#Check global values and make unacquired weapons and items invisible.
	if !global.rp_jet[0] and global.player == 0 or global.player != 0:
		$weap_03.hide()
	#This is only required for Rush Jet.
	if global.rp_jet[0] and global.player == 0:
		$weap_03.show()
		
	if !global.weapon1[0]:
		$weap_04.hide()
	if !global.weapon2[0]:
		$weap_05.hide()
	if !global.weapon3[0]:
		$weap_06.hide()
	if !global.weapon4[0]:
		$weap_07.hide()
	if !global.weapon5[0]:
		$weap_08.hide()
	if !global.weapon6[0]:
		$weap_09.hide()
	if !global.weapon7[0]:
		$weap_10.hide()
	if !global.weapon8[0]:
		$weap_11.hide()
	if global.player == 0 and !global.beat[0]:
		$weap_12.hide()
	if global.player == 1 and !global.tango[0]:
		$weap_12.hide()
	if global.player == 2 and !global.reggae[0]:
		$weap_12.hide()
	
	if !global.perma_items['ebalancer']:
		$item_01.hide()
	
	#Hide additional icons until new items are made.
	$item_02.hide()
	$item_03.hide()
	$item_04.hide()
	$item_05.hide()
	$item_06.hide()
	$item_07.hide()
	$item_08.hide()
	$item_09.hide()
	$item_10.hide()

func set_names():
	#Set unique text and icons for the menu.
	if global.player == 0:
		$weap_01/icon.set_frame(0)
		$weap_01/text.set_text('M. BUSTER')
		$weap_02/icon.set_frame(2)
		$weap_02/text.set_text('RUSH COIL')
		$weap_03/icon.set_frame(3)
		$weap_03/text.set_text('RUSH JET')
		$weap_12/icon.set_frame(15)
		$weap_12/text.set_text('B. ATTACK')
	if global.player == 1:
		$weap_01/icon.set_frame(0)
		$weap_01/text.set_text('P. BUSTER')
		$weap_02/icon.set_frame(4)
		$weap_02/text.set_text('CARRY')
		$weap_12/icon.set_frame(16)
		$weap_12/text.set_text('T. BALL')
	if global.player == 2:
		$weap_01/icon.set_frame(1)
		$weap_01/text.set_text('B. BUSTER')
		$weap_02/icon.set_frame(6)
		$weap_02/text.set_text('T. BOOST')
		$weap_12/icon.set_frame(17)
		$weap_12/text.set_text('R. TURRET')
	
	#Set names and icons for the players.
	if global.player_id[0] == 0:
		$plyr_1/icon.set_frame(0)
		$plyr_1/text.set_text('MEGA MAN')
	if global.player_id[0] == 1:
		$plyr_1/icon.set_frame(1)
		$plyr_1/text.set_text('PROTO MAN')
	if global.player_id[0] == 2:
		$plyr_1/icon.set_frame(2)
		$plyr_1/text.set_text('BASS')
	
	if global.player_id[1] == 0:
		$plyr_2/icon.set_frame(0)
		$plyr_2/text.set_text('MEGA MAN')
	if global.player_id[1] == 1:
		$plyr_2/icon.set_frame(1)
		$plyr_2/text.set_text('PROTO MAN')
	if global.player_id[1] == 2:
		$plyr_2/icon.set_frame(2)
		$plyr_2/text.set_text('BASS')

func item_menu():
	#Reset the item menu position when in the weapons menu.
	if m_pos != 0 and menu == 0:
		m_pos = menu
	
	#Make the selected icons blink.
	if menu != 0 and blink > 0:
		blink -= 1
	
	if menu != 0 and blink == 0:
		if m_pos == 0:
			if $e_tanks/icon.visible:
				$e_tanks/icon.hide()
			else:
				$e_tanks/icon.show()
		if m_pos == 1:
			if $m_tanks/icon.visible:
				$m_tanks/icon.hide()
			else:
				$m_tanks/icon.show()
		if m_pos == 2:
			if $et_call/icon.visible:
				$et_call/icon.hide()
			else:
				$et_call/icon.show()
		if m_pos == 3:
			if $half_dmg/icon.visible:
				$half_dmg/icon.hide()
			else:
				$half_dmg/icon.show()
		if m_pos == 4:
			if $spk_prtct/icon.visible:
				$spk_prtct/icon.hide()
			else:
				$spk_prtct/icon.show()
		
		blink = 8
	
	#Reset other icons to visible when not selected.
	if menu != 0:
		if m_pos == 0:
			if !$m_tanks/icon.visible:
				$m_tanks/icon.show()
			if !$et_call/icon.visible:
				$et_call/icon.show()
			if !$half_dmg/icon.visible:
				$half_dmg/icon.show()
			if !$spk_prtct/icon.visible:
				$spk_prtct/icon.show()
		if m_pos == 1:
			if !$e_tanks/icon.visible:
				$e_tanks/icon.show()
			if !$et_call/icon.visible:
				$et_call/icon.show()
			if !$half_dmg/icon.visible:
				$half_dmg/icon.show()
			if !$spk_prtct/icon.visible:
				$spk_prtct/icon.show()
		if m_pos == 2:
			if !$e_tanks/icon.visible:
				$e_tanks/icon.show()
			if !$m_tanks/icon.visible:
				$m_tanks/icon.show()
			if !$half_dmg/icon.visible:
				$half_dmg/icon.show()
			if !$spk_prtct/icon.visible:
				$spk_prtct/icon.show()
		if m_pos == 3:
			if !$e_tanks/icon.visible:
				$e_tanks/icon.show()
			if !$m_tanks/icon.visible:
				$m_tanks/icon.show()
			if !$et_call/icon.visible:
				$et_call/icon.show()
			if !$spk_prtct/icon.visible:
				$spk_prtct/icon.show()
		if m_pos == 4:
			if !$e_tanks/icon.visible:
				$e_tanks/icon.show()
			if !$m_tanks/icon.visible:
				$m_tanks/icon.show()
			if !$et_call/icon.visible:
				$et_call/icon.show()
			if !$half_dmg/icon.visible:
				$half_dmg/icon.show()

func wpn_menu():
	
	var get_nodes = get_tree().get_nodes_in_group('wpn_icons')
	
	world.palette_swap()
	sel_color[0] = world.palette[1]
	sel_color[1] = world.palette[2]

	if global.player_weap[int(player.swap)] == 0:
		$weap_01/meter.material.set_shader_param('r_col1', sel_color[2])
		$weap_01/meter.material.set_shader_param('r_col2', sel_color[3])
	else:
		$weap_01/meter.material.set_shader_param('r_col1', desel_color[0])
		$weap_01/meter.material.set_shader_param('r_col2', desel_color[1])
	
	for i in range(get_nodes.size()):
		if i == global.player_weap[int(player.swap)] and menu == 0:
			get_nodes[i].material.set_shader_param('r_col1', sel_color[0])
			get_nodes[i].material.set_shader_param('r_col2', sel_color[1])
			get_nodes[i].material.set_shader_param('r_col3', sel_color[2])
			
			get_nodes[i].get_child(1).set('custom_colors/font_color', sel_color[3])
			
			get_plyr[int(player.swap)].material.set_shader_param('r_col1', sel_color[0])
			get_plyr[int(player.swap)].material.set_shader_param('r_col2', sel_color[1])
			get_plyr[int(player.swap)].material.set_shader_param('r_col3', sel_color[2])
			get_plyr[int(player.swap)].material.set_shader_param('r_col4', sel_color[3])
			
			get_plyr[2].material.set_shader_param('r_col1', sel_color[0])
			get_plyr[2].material.set_shader_param('r_col2', sel_color[1])
			get_plyr[2].material.set_shader_param('r_col3', sel_color[2])
			get_plyr[2].material.set_shader_param('r_col4', sel_color[3])
		else:
			get_nodes[i].material.set_shader_param('r_col1', desel_color[0])
			get_nodes[i].material.set_shader_param('r_col2', desel_color[1])
			get_nodes[i].material.set_shader_param('r_col3', desel_color[2])
			
			get_nodes[i].get_child(1).set('custom_colors/font_color', desel_color[2])
