extends Node2D

#Grab the world and player nodes to gain access to their scripts.
onready var world = get_parent().get_parent()
onready var player = world.get_child(2)

var weap
var p_swap

func _ready():
	#Get the colors to be replaced.
	$weap.material.set_shader_param('t_col1', global.t_color1)
	$weap.material.set_shader_param('t_col2', global.t_color2)
	$weap.material.set_shader_param('t_col3', global.t_color3)

# warning-ignore:unused_argument
func _process(delta):
	
	if int($lives.get_text()) != global.lives:
		$lives.set_text(str(global.lives))
	
	p_swap = int(player.swap) + 1
	weap = 'weapon'+str(global.player_weap[int(player.swap)])
	
	#Make weapon and boss bars visible/invisible.
	if global.player_weap[int(player.swap)] != 0 and !$weap.is_visible():
		$weap.show()
	
	if global.player_weap[int(player.swap)] == 0 and $weap.is_visible() or global.player_weap[int(player.swap)] == 5 and $weap.is_visible() or global.player_weap[int(player.swap)] == null and $weap.is_visible():
		$weap.hide()
	
	if world.boss and !$boss.is_visible():
		$boss.show()
	
	if !world.boss and $boss.is_visible():
		$boss.hide()
	
	#Set meter values.
	#Life Meter
	if $life.value != global.player_life[int(player.swap)]:
		$life.value = global.player_life[int(player.swap)]
	
	#Weapon Meters
	match global.player_weap[int(player.swap)]:
		1:
			if $weap.value != global.weapon1[int(player.swap) + 1]:
				$weap.value = global.weapon1[int(player.swap) + 1]
		2:
			if $weap.value != global.weapon2[int(player.swap) + 1]:
				$weap.value = global.weapon2[int(player.swap) + 1]
		3:
			if $weap.value != global.weapon3[int(player.swap) + 1]:
				$weap.value = global.weapon3[int(player.swap) + 1]
		4:
			if $weap.value != global.weapon4[int(player.swap) + 1]:
				$weap.value = global.weapon4[int(player.swap) + 1]

	
	#Boss Meter
	if $boss.value > world.boss_hp:
		$boss.value = world.boss_hp
