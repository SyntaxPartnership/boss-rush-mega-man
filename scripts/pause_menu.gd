extends Node2D

onready var world = get_parent().get_parent()
onready var player = get_parent().get_parent().get_child(2)

var start = false
var kill_wpn = 0
var ignore_input = true

var heal_delay = 0
var heal_type = 0
var heal_amt = 0

var dirs = [Vector2(), Vector2(), Vector2(), Vector2()]

var blink = 8

var prev_mpos = Vector2()
var menu_pos = Vector2()
var set_weap = {
	Vector2(0, 0) : 0,
	Vector2(1, 0) : 5,
	Vector2(0, 1) : 1,
	Vector2(1, 2) : 3,
	Vector2(0, 2) : 2,
	Vector2(1, 1) : 4
}

var color_set
var get_meters
var get_plyr

var sel_color = [Color(), Color(), global.yellow0, global.white]
var desel_color = [global.grey3, global.grey2, global.grey1, global.grey0]

# Called when the node enters the scene tree for the first time.
func _ready():
	color_set = get_tree().get_nodes_in_group('icons')
	get_meters = get_tree().get_nodes_in_group('meters')
	
	hide_icons()
	wpn_menu()
	
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
	
	dir_allow()

func _input(_event):
	if ignore_input:
		return
		
	if Input.is_action_just_pressed("up") and menu_pos.y > 0:
		menu_pos.y -= 1
		select()
	if Input.is_action_just_pressed("down") and menu_pos.y < 2:
		menu_pos.y += 1
		select()
	if Input.is_action_just_pressed("left") and menu_pos.x > 0:
		menu_pos.x -= 1
		select()
		print(menu_pos)
	if Input.is_action_just_pressed("right") and menu_pos.x < 2:
		menu_pos.x += 1
		select()
	
	print(menu_pos)
	
	if Input.is_action_just_pressed("jump"):
		
		#Heal with E-Tank
		if menu_pos == Vector2(2, 0) and global.etanks > 0 and global.player_life[int(player.swap)] < 280:
			ignore_input = true
			global.etanks -= 1
			heal_amt = ((global.player_life[int(player.swap)] - 280) * -1) / 10
			heal_type = 1
		elif menu_pos == Vector2(2, 0) and global.etanks > 0 and global.player_life[int(player.swap)] == 280:
			world.sound("buzz")
		
		#Heal with W-Tank
		if menu_pos == Vector2(2, 1) and global.wtanks > 0:
			ignore_input = true
			var levels = [
				global.weapon1[int(player.swap) + 1],
				global.weapon2[int(player.swap) + 1],
				global.weapon3[int(player.swap) + 1],
				global.weapon4[int(player.swap) + 1]
			]
			if levels.min() < 280:
				global.wtanks -= 1
				heal_amt = ((levels.min() - 280) * -1) / 10
				heal_type = 2
			else:
				world.sound("buzz")

func _process(delta):
	
	#Make items flash.
	if menu_pos.x == 2 and blink > 0:
		blink -= 1
		
		if blink == 0:
			if menu_pos.y == 0:
				if $items_menu/e_tanks/icon.is_visible_in_tree():
					$items_menu/e_tanks/icon.hide()
				else:
					$items_menu/e_tanks/icon.show()
				$items_menu/w_tanks/icon.show()
				$items_menu/extra/icon.show()
			if menu_pos.y == 1:
				if $items_menu/w_tanks/icon.is_visible_in_tree():
					$items_menu/w_tanks/icon.hide()
				else:
					$items_menu/w_tanks/icon.show()
				$items_menu/e_tanks/icon.show()
				$items_menu/extra/icon.show()
			if menu_pos.y == 2:
				if $items_menu/extra/icon.is_visible_in_tree():
					$items_menu/extra/icon.hide()
				else:
					$items_menu/extra/icon.show()
				$items_menu/e_tanks/icon.show()
				$items_menu/w_tanks/icon.show()
		
			blink = 8
	
	if menu_pos.x < 2:
		if !$items_menu/e_tanks/icon.is_visible_in_tree():
			$items_menu/e_tanks/icon.show()
		if !$items_menu/w_tanks/icon.is_visible_in_tree():
			$items_menu/w_tanks/icon.show()
		if !$items_menu/extra/icon.is_visible_in_tree():
			$items_menu/extra/icon.show()
		
	
	#Begin the healing loop
	if heal_type != 0:
		heal_delay += 1
		
		if heal_delay > 1:
			heal_delay = 0
		
		#Refill health only.
		if heal_type == 1 and heal_delay == 1 and global.player_life[int(player.swap)] < 280:
			world.sound("meter")
			global.player_life[int(player.swap)] += 10
		
		#Refill all for the active player. Set caps for energy over a certain amount.
		if heal_type == 2 and heal_delay == 1 and heal_amt > 0:
			world.sound("meter")
			
			if global.weapon1[int(player.swap) + 1] < 280:
				global.weapon1[int(player.swap) + 1] += 10
			
			if global.weapon2[int(player.swap) + 1] < 280:
				global.weapon2[int(player.swap) + 1] += 10
			
			if global.weapon3[int(player.swap) + 1] < 280:
				global.weapon3[int(player.swap) + 1] += 10
			
			if global.weapon4[int(player.swap) + 1] < 280:
				global.weapon4[int(player.swap) + 1] += 10
			
			heal_amt -= 1
		
		if heal_type == 1 and global.player_life[int(player.swap)] == 280:
			ignore_input = false
			heal_delay = 0
			heal_type = 0
		
		if heal_type == 2 and heal_amt == 0:
			ignore_input = false
			heal_delay = 0
			heal_type = 0
	
	#Update Meters and Counters
	if int($items_menu/bolts/text.get_text()) != global.bolts:
		if global.bolts < 10:
			$items_menu/bolts/text.set_text(":000"+str(global.bolts))
		elif global.bolts < 100:
			$items_menu/bolts/text.set_text(":00"+str(global.bolts))
		elif global.bolts < 1000:
			$items_menu/bolts/text.set_text(":0"+str(global.bolts))
		else:
			$items_menu/bolts/text.set_text(":"+str(global.bolts))
	
	if int($items_menu/e_tanks/text.get_text()) != global.etanks:
		$items_menu/e_tanks/text.set_text(":0"+str(global.etanks))
	
	if int($items_menu/w_tanks/text.get_text()) != global.wtanks:
		$items_menu/w_tanks/text.set_text(":0"+str(global.wtanks))
	
	if int($items_menu/extra/text.get_text()) != global.tokens:
		$items_menu/extra/text.set_text(":0"+str(global.tokens))
	
	if $weap_menu/default/meter.get_value() != global.player_life[int(player.swap)]:
		$weap_menu/default/meter.value = global.player_life[int(player.swap)]
	
	if $weap_menu/s_kick/meter.get_value() != global.weapon1[int(player.swap) + 1]:
		$weap_menu/s_kick/meter.value = global.weapon1[int(player.swap) + 1]
	if $weap_menu/r_boost/meter.get_value() != global.weapon2[int(player.swap) + 1]:
		$weap_menu/r_boost/meter.value = global.weapon2[int(player.swap) + 1]
	if $weap_menu/s_puck/meter.get_value() != global.weapon3[int(player.swap) + 1]:
		$weap_menu/s_puck/meter.value = global.weapon3[int(player.swap) + 1]
	if $weap_menu/a_shield/meter.get_value() != global.weapon4[int(player.swap) + 1]:
		$weap_menu/a_shield/meter.value = global.weapon4[int(player.swap) + 1]

func _physics_process(delta):
	
	if prev_mpos != menu_pos:
		dir_allow()
	
	if start and global_position.y > 0:
		global_position.y -= 8
	
	if !start and global_position.y < 112:
		ignore_input = true
		global_position.y += 8
	
	if start and global_position.y == 0 and heal_amt == 0:
		ignore_input = false
	
	if !start and global_position.y == 112 and get_tree().paused:
		world.show_shit()
	
func hide_icons():
	if !global.weapon1[0]:
		$weap_menu/s_kick.hide()
	if !global.weapon2[0]:
		$weap_menu/r_boost.hide()
	if !global.weapon3[0]:
		$weap_menu/s_puck.hide()
	if !global.weapon4[0]:
		$weap_menu/a_shield.hide()
	if !global.perma_items.get("super_adaptor"):
		$weap_menu/s_adaptor.hide()

func wpn_menu():
	var get_nodes = get_tree().get_nodes_in_group('icons')
	
	world.palette_swap()
	sel_color[0] = world.palette[1]
	sel_color[1] = world.palette[2]

	for i in range(get_nodes.size()):
		if i == global.player_weap[int(player.swap)]:
			get_nodes[i].material.set_shader_param('r_col1', sel_color[0])
			get_nodes[i].material.set_shader_param('r_col2', sel_color[1])
			get_nodes[i].material.set_shader_param('r_col3', sel_color[2])
			
			get_nodes[i].get_child(2).material.set_shader_param('r_col1', sel_color[2])
			get_nodes[i].get_child(2).material.set_shader_param('r_col2', sel_color[3])

			get_nodes[i].get_child(1).set('custom_colors/font_color', sel_color[3])
		else:
			get_nodes[i].material.set_shader_param('r_col1', desel_color[0])
			get_nodes[i].material.set_shader_param('r_col2', desel_color[1])
			get_nodes[i].material.set_shader_param('r_col3', desel_color[2])
			
			get_nodes[i].get_child(2).material.set_shader_param('r_col1', desel_color[2])
			get_nodes[i].get_child(2).material.set_shader_param('r_col2', desel_color[3])

			get_nodes[i].get_child(1).set('custom_colors/font_color', desel_color[2])

func select():
	world.sound("cursor")
	blink = 8
	global.player_weap[int(player.swap)] = set_weap.get(menu_pos)
	wpn_menu()

func init_cursor():
	var start_pos = {
		0: Vector2(0, 0),
		1: Vector2(0, 1),
		2: Vector2(0, 2),
		3: Vector2(1, 2),
		4: Vector2(1, 1),
		5: Vector2(1, 0)
	}
	
	menu_pos = start_pos.get(global.player_weap[int(player.swap)])

func dir_allow():
	match menu_pos:
		Vector2(0, 0):
			#Up
			dirs[0] = Vector2(0, 0)
			#Down
			if !global.weapon1[0] and !global.weapon2[0]:
				dirs[1] = Vector2(0, 0)
			elif !global.weapon1[0] and global.weapon2[0]:
				dirs[1] = Vector2(0, 2)
			else:
				dirs[1] = Vector2(0, 1)
			#Left
			dirs[2] = Vector2(0, 0)
			#Right
			if !global.perma_items.get("super_adaptor"):
				dirs[3] = Vector2(2, 0)
			else:
				dirs[3] = Vector2(1, 0)
		
		Vector2(1, 0):
			#Up
			dirs[0] = Vector2(1, 0)
			#Down
			if !global.weapon4[0] and !global.weapon3[0]:
				dirs[1] = Vector2(1, 0)
			elif !global.weapon4[0] and global.weapon3[0]:
				dirs[1] = Vector2(1, 2)
			else:
				dirs[1] = Vector2(1, 1)
			#Left
			dirs[2] = Vector2(0, 0)
			#Right
			dirs[3] = Vector2(2, 0)
		
		Vector2(2, 0):
			#Up
			dirs[0] = Vector2(2, 0)
			#Down
			dirs[3] = Vector2(2, 1)
			#Left
			if !global.perma_items.get("super_adaptor"):
				dirs[2] = Vector2(2, 0)
			else:
				dirs[2] = Vector2(2, 0)
			#Right
			dirs[3] = Vector2(2, 0)
	
	prev_mpos = menu_pos
	print(dirs)
