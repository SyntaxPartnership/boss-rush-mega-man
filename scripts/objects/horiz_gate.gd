extends Node2D

onready var world = get_parent().get_parent()
onready var player = world.get_child(2)
onready var camera = player.get_child(9)
onready var player_anim = player.get_child(4)

var open = false
var top = false
var bottom = false

var kill

func _ready():
	world.connect('close_gate', self, 'on_close_gate')

func _physics_process(_delta):
	
	#Stop the player from walking back through the gate as necessary.
	if $solid_top/box.is_disabled() and world.cam_allow[1] == 0:
		$solid_top/box.set_disabled(false)
	elif !$solid_top/box.is_disabled() and world.cam_allow[1] == 1:
		$solid_top/box.set_disabled(true)
	
	if $solid_bottom/box.is_disabled() and world.cam_allow[0] == 0:
		$solid_bottom/box.set_disabled(false)
	elif !$solid_bottom/box.is_disabled() and world.cam_allow[0] == 1:
		$solid_bottom/box.set_disabled(true)

func _on_act_top_body_entered(_body):
	if !$act_top/box.is_disabled() and !world.swapping:
		world.kill_enemies()
		audio.play_sound("shutter")
		#Stop player animation
		player_anim.stop()
		player.can_move = false
		open = true
		bottom = true
		player.gate = true
		world.kill_effects()
		world.kill_weapons()
		#Open the gate.
		$anim.play('opening')

func _on_act_bottom_body_entered(_body):
	if !$act_bottom/box.is_disabled() and !world.swapping:
		world.kill_enemies()
		audio.play_sound("shutter")
		#Stop player animation
		player_anim.stop()
		player.can_move = false
		open = true
		top = true
		player.gate = true
		world.kill_effects()
		world.kill_weapons()
		#Open the gate.
		$anim.play('opening')
		

func _on_act_top_body_exited(_body):
	bottom = false

func _on_act_bottom_body_exited(_body):
	top = false

func _on_anim_animation_finished(_opening):
	if open and top:
		player_anim.play()
		world.scroll = true
		world.scroll_len = -world.res.y
		world.cam_move = 1
		top = false
		#Disable the area2d boxes
		$act_top/box.set_deferred('disabled', true)
		$act_bottom/box.set_deferred('disabled', true)
	
	if open and bottom:
		player_anim.play()
		world.scroll = true
		world.scroll_len = world.res.y
		world.cam_move = 2
		bottom = false
		#Disable the area2d boxes
		$act_top/box.set_deferred('disabled', true)
		$act_bottom/box.set_deferred('disabled', true)
	
	if !open:
		player_anim.play()
		world.scroll = false
		world.cam_move = 0
		world.emit_signal("scrolling")
		player.gate = false
		$act_top/box.set_disabled(false)
		$act_bottom/box.set_disabled(false)

func on_close_gate():
	if open:
		open = false
		player_anim.stop()
		audio.play_sound("shutter")
		$anim.play_backwards("opening")
