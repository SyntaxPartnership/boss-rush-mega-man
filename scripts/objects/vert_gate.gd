extends Node2D

onready var world = get_parent().get_parent()
onready var player = world.get_child(2)
#Update is more child nodes are added to player.
onready var camera = player.get_child(9)
onready var player_anim = player.get_child(4)

var open = false
var left = false
var right = false

var kill

func _ready():
	world.connect('close_gate', self, 'on_close_gate')
	
func _physics_process(_delta):
	
	#Stop the player from walking back through the gate as necessary.
	if $solid_left/box.is_disabled() and world.cam_allow[3] == 0:
		$solid_left/box.set_disabled(false)
	elif !$solid_left/box.is_disabled() and world.cam_allow[3] == 1:
		$solid_left/box.set_disabled(true)
	
	if $solid_right/box.is_disabled() and world.cam_allow[2] == 0:
		$solid_right/box.set_disabled(false)
	elif !$solid_right/box.is_disabled() and world.cam_allow[2] == 1:
		$solid_right/box.set_disabled(true)

func _on_act_left_body_entered(_body):
	if !$act_left/box.is_disabled() and !world.swapping:
		world.kill_enemies()
		$open.play()
		#Stop player animation
		player_anim.stop()
		player.can_move = false
		open = true
		right = true
		player.gate = true
		world.kill_effects()
		world.kill_weapons()
		#Open the gate.
		$anim.play('opening')

func _on_act_right_body_entered(_body):
	if !$act_right/box.is_disabled() and !world.swapping:
		world.kill_enemies()
		$open.play()
		#Stop player animation
		player_anim.stop()
		player.can_move = false
		open = true
		left = true
		player.gate = true
		world.kill_effects()
		world.kill_weapons()
		#Open the gate.
		$anim.play('opening')

func _on_act_left_body_exited(_body):
	right = false

func _on_act_right_body_exited(_body):
	left = false

func _on_anim_animation_finished(_opening):
	if open and left:
		player_anim.play()
		camera.limit_left = world.center.x - (world.res.x / 2)
		camera.limit_right = world.center.x + (world.res.x / 2)
		world.scroll = true
		world.scroll_len = -world.res.x
		world.cam_move = 3
		left = false
		#Disable the area2d boxes
		$act_left/box.set_deferred('disabled', true)
		$act_right/box.set_deferred('disabled', true)
	
	if open and right:
		player_anim.play()
		camera.limit_left = world.center.x - (world.res.x / 2)
		camera.limit_right = world.center.x + (world.res.x / 2)
		world.scroll = true
		world.scroll_len = world.res.x
		world.cam_move = 4
		right = false
		#Disable the area2d boxes
		$act_left/box.set_deferred('disabled', true)
		$act_right/box.set_deferred('disabled', true)
	
	if !open:
		player_anim.play()
		world.scroll = false
		world.cam_move = 0
		world.emit_signal("scrolling")
		player.gate = false
		$act_left/box.set_disabled(false)
		$act_right/box.set_disabled(false)

func on_close_gate():
	if open:
		open = false
		$open.play()
		player_anim.stop()
		$anim.play_backwards("opening")


