extends Node

var debug_stats = 0
var debug_menu = 0

#Player Variables
var player = 0
var player_id = [0, 99]
var player_life = [280, 0]
var player_weap = [0, 0]
var lives = 2
var bolts = 0
var etanks = 0
var wtanks = 0
var tokens = 0
var game_over = false

#Global Level Flags
var icey = false
var low_grav = false

#Option Flags
var sound = 4
var music = 4
var res = 3
var f_screen = false
var quick_swap = false
var use_analog = false
var dash_btn = false
var dbl_tap_dash = false
var a_charge = false
var a_fire = false
var r_fire = false
var chrg_sfx = 2

var gamepads = []
var gp_update = []
var gp_connect = false
var gp_name = ""

var actions = ["up", "down", "left", "right", "jump", "fire", "dash", "toggle", "prev", "next", "select", "start"]

var key_ctrls = ["W", "S", "A", "D", "Period", "Comma", "Slash", "L", "Semicolon", "Apostrophe", "Shift", "Enter"]
var joy_ctrls = ["DPAD Up", "DPAD Down", "DPAD Left", "DPAD Right", "Face Button Bottom", "Face Button Left", "Face Button Right", "Face Button Top", "L", "R", "Select", "Start"]
var l_stick = [["Left Stick Y", -1.0], ["Left Stick Y", 1.0], ["Left Stick X", -1.0], ["Left Stick X", 1.0]]

var gp_list = ["XInput Gamepad", "Wireless Controller", "Sony DualShock 4", "HORIPAD S"]

#Level/Continue Point IDs
var level_id = 0
var cont_id = 0
var boss = false
var boss_num = 1

var temp_items = {}
#Update list with permanent items.
var perma_items = {
	'super_adaptor'		: false,
	'choke_hand'		: false,
	'magnet_hand'		: false,
	'seeker_hand'		: false,
	'ebalancer'			: false
	}

#Stage Cleared Flags
var boss1_clear = false
var boss2_clear = false
var boss3_clear = false
var boss4_clear = false
var wily1_clear = false
var wily2_clear = false

#Strider's location and health
var location = 0
var str_health = 280
var rescued = false
var bass = true

#Master Weapon flags and energy. First number determines if the weapon has been acquired or not. rp_coil will always be set to true at the start of the game.
var dummy = [true, 280, 280]
var weapon1 = [false, 280, 280]
var weapon2 = [false, 280, 280]
var weapon3 = [false, 280, 280]
var weapon4 = [false, 280, 280]

var end_pos = Vector2()
var end_frame = 0

#Color values. Based on the realnes.aseprite palette included in the file heirarchy.

#Colors to be replaced using the shader.
var t_color1 = Color('#0f0f0f')
var t_color2 = Color('#414141')
var t_color3 = Color('#737373')
var t_color4 = Color('#00ff1b')

#Transparent color
var trans = Color('#00000000')

#Some colors are darker than others. The higher the number, the darker that particular shade is.
var grey3 = Color('#2c2c2c')
var grey2 = Color('#606060')
var grey1 = Color('#788084')
var grey0 = Color('#bcc0c4')

var turq3 = Color('#004058')
var turq2 = Color('#008894')
var turq1 = Color('#00e8e4')
var turq0 = Color('#00f8fc')

var jungle3 = Color('#005800')
var jungle2 = Color('#00a848')
var jungle1 = Color('#58f89c')
var jungle0 = Color('#b0f0d8')

var green3 = Color('#006800')
var green2 = Color('#00a800')
var green1 = Color('#58d858')
var green0 = Color('#b8f878')

var lime3 = Color('#007800')
var lime2 = Color('#00b800')
var lime1 = Color('#bcf818')
var lime0 = Color('#dcf878')

var yellow3 = Color('#503000')
var yellow2 = Color('#ac8000')
var yellow1 = Color('#fcb800')
var yellow0 = Color('#fcd884')

var brown3 = Color('#8c1800')
var brown2 = Color('#e46018')
var brown1 = Color('#fca048')
var brown0 = Color('#fce0b4')

var red3 = Color('#ac1000')
var red2 = Color('#fc3800')
var red1 = Color('#fc7858')
var red0 = Color('#f4d0b4')

var pink3 = Color('#ac0028')
var pink2 = Color('#e40060')
var pink1 = Color('#fc589c')
var pink0 = Color('#f4c0e0')

var magenta3 = Color('#94008c')
var magenta2 = Color('#dc00d4')
var magenta1 = Color('#fc78fc')
var magenta0 = Color('#fcb8fc')

var purple3 = Color('#4028c4')
var purple2 = Color('#6848fc')
var purple1 = Color('#9c78fc')
var purple0 = Color('#dcb8fc')

var rblue3 = Color('#0000c4')
var rblue2 = Color('#0088fc')
var rblue1 = Color('#6888fc')
var rblue0 = Color('#bcb8fc')

var blue3 = Color('#0000fc')
var blue2 = Color('#0078fc')
var blue1 = Color('#38c0fc')
var blue0 = Color('#a4e8fc')

var black = Color('#000000')
var white = Color('#fcf8fc')

# don't forget to use stretch mode 'viewport' and aspect 'ignore'
onready var viewport = get_viewport()

func _ready():
# warning-ignore:return_value_discarded
	Input.connect("joy_connection_changed", self, "_on_joy_connection_changed")
	
	gamepads = Input.get_connected_joypads()
	
	if gamepads != []:
		print(Input.get_joy_name(gamepads[0]))
	
	if gamepads != gp_update:
		gp_connect = true
		gp_name = Input.get_joy_name(gamepads[0])
		gp_update = gamepads

func resize():
# warning-ignore:return_value_discarded
	get_tree().connect("screen_resized", self, "_screen_resized")

func _input(_event):
	#Quick way to close the game.
	if Input.is_key_pressed(KEY_ESCAPE):
		get_tree().quit()

func _screen_resized():
	var window_size
	
	if !f_screen:
		OS.set_window_size(Vector2(256 * res, 240 * res))
		window_size = OS.get_window_size()
		OS.window_fullscreen = false
	else:
		OS.set_window_size(Vector2(256, 240))
		window_size = OS.get_window_size()
		OS.window_fullscreen = true

	# see how big the window is compared to the viewport size
	# floor it so we only get round numbers (0, 1, 2, 3 ...)
	var scale_x = floor(window_size.x / viewport.size.x)
	var scale_y = floor(window_size.y / viewport.size.y)

	# use the smaller scale with 1x minimum scale
	var scale = max(1, min(scale_x, scale_y))

	# find the coordinate we will use to center the viewport inside the window
	var diff = window_size - (viewport.size * scale)
	var diffhalf = (diff * 0.5).floor()

	# attach the viewport to the rect we calculated
	viewport.set_attach_to_screen_rect(Rect2(diffhalf, viewport.size * scale))
	
	#Set window position
	var screen_size = OS.get_screen_size(0)
	var _win_size = OS.get_window_size()
	
	OS.set_window_position(screen_size*0.5 - window_size*0.5)

func set_ctrls():
	#Erase all buttons in preparations for the new controls.
	for i in range(actions.size()):
		if InputMap.has_action(actions[i]):
			InputMap.action_erase_events(actions[i])
			
			#Get keyboard button value to set
			var scancode = OS.find_scancode_from_string(key_ctrls[i])
			var k_event = InputEventKey.new()
			k_event.scancode = scancode
			
			#Get gamepad value to set.
			var j_event = InputEventJoypadButton.new()
			j_event.set_button_index(Input.get_joy_button_index_from_string(joy_ctrls[i]))
			
			#Add the buttons.
			InputMap.action_add_event(actions[i], k_event)
			InputMap.action_add_event(actions[i], j_event)
	
	#Add left stick events if the flag is toggled.
	if use_analog:
		for a in range(l_stick.size()):
			var axis = l_stick[a][0]
			var dir = l_stick[a][1]
			
			var stick = InputEventJoypadMotion.new()
			
			stick.set_axis(Input.get_joy_axis_index_from_string(axis))
			stick.set_axis_value(dir)
			
			InputMap.action_add_event(actions[a], stick)

func _on_joy_connection_changed(device_id, connected):
	if connected:
		gp_connect = true
		gp_name = Input.get_joy_name(device_id)
	else:
		gp_connect = false
