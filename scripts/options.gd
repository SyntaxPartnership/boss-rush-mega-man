extends Control

const CONFIG_FILE = 'user://options.cfg'

const REPLACE = {
	"Escape"		: "ESC",
	"Print"			: "PRINT",
	"Pause"			: "PAUSE",
	"Delete"		: "DEL",
	"Home"			: "HOME",
	"PageUp"		: "PG UP",
	"PageDown"		: "PG DN",
	"End"			: "END",
	"QuoteLeft"		: "`",
	"Minus"			: "-",
	"Equal"			: "=",
	"BackSpace"		: "BCKSP",
	"NumLock"		: "NLOCK",
	"Kp Divide"		: "NP /",
	"Kp Multiply"	: "NP *",
	"Kp Subtract"	: "NP -",
	"Kp 7"			: "NP 7",
	"Kp 8"			: "NP 8",
	"Kp 9"			: "NP 9",
	"Kp 4"			: "NP 4",
	"Kp 5"			: "NP 5",
	"Kp 6"			: "NP 6",
	"Kp 1"			: "NP 1",
	"Kp 2"			: "NP 2",
	"Kp 3"			: "NP 3",
	"Kp Add"		: "NP +",
	"Kp Period"		: "NP .",
	"Kp Enter"		: "NPENT",
	"Tab"			: "TAB",
	"BraceLeft"		: "[",
	"BraceRight"	: "]",
	"BackSlash"		: "BSLASH",
	"CapsLock"		: "CAPS",
	"Enter"			: "ENTER",
	"Shift"			: "SHIFT",
	"Comma"			: ",",
	"Period"		: ".",
	"Slash"			: "/",
	"Control"		: "CTRL",
	"Alt"			: "ALT",
	"Space"			: "SPACE",
	"Up"			: "UP",
	"Down"			: "DOWN",
	"Left"			: "LEFT",
	"Right"			: "RIGHT",
	"Semicolon"		: ";",
	"Apostrophe"	: "'",
	}

const XINPUT_RPLCE = {
	"DPAD Up"				: "UP",
	"DPAD Down"				: "DOWN",
	"DPAD Left"				: "LEFT",
	"DPAD Right"			: "RIGHT",
	"Face Button Top"		: "Y",
	"Face Button Bottom"	: "A",
	"Face Button Left"		: "X",
	"Face Button Right"		: "B",
	"Select"				: "SELECT",
	"Start"					: "START"
	}

const SWITCH_RPLCE = {
	"DPAD Up"				: "UP",
	"DPAD Down"				: "DOWN",
	"DPAD Left"				: "LEFT",
	"DPAD Right"			: "RIGHT",
	"Face Button Top"		: "X",
	"Face Button Bottom"	: "B",
	"Face Button Left"		: "Y",
	"Face Button Right"		: "A",
	"Select"				: "SELECT",
	"Start"					: "START"
	}

const SONY_RPLCE = {
	"DPAD Up"				: "UP",
	"DPAD Down"				: "DOWN",
	"DPAD Left"				: "LEFT",
	"DPAD Right"			: "RIGHT",
	"Face Button Top"		: "TRIANG",
	"Face Button Bottom"	: "CROSS",
	"Face Button Left"		: "SQUARE",
	"Face Button Right"		: "CIRCLE",
	"Select"				: "SELECT",
	"Start"					: "START"
	}

var which_pad = []

var menu = 0
var menu_pos = 0
var menu_size = [6, 2, 2, 12, 12, 8, 0]
var pressed = false
var ca_start = 0
var cb_start = 0
var ctrl_lock = true
var set_mode = 0
var btn_flash = 0
var save_res = 0
var buttons = []

# Called when the node enters the scene tree for the first time.
func _ready():
	
	for g in global.gp_list:
		if g == global.gp_name:
			print(g)
			match g:
				"XInput Gamepad":
					which_pad = XINPUT_RPLCE
				"Wireless Controller":
					which_pad = SWITCH_RPLCE
				"Sony DualShock 4":
					which_pad = SONY_RPLCE
				"PS4 Controller":
					which_pad = SONY_RPLCE
				"HORIPAD S":
					which_pad = SWITCH_RPLCE
		else:
			which_pad = XINPUT_RPLCE
	print(which_pad)
	
	ca_start = $cursor.position.y
	cb_start = $cursor2.position.x
	cursor_pos()
	
	save_res = global.res
	
	$audio/sfx.set_value(global.sound)
	$audio/music.set_value(global.music)
	
	if !global.gp_connect:
		$main/ctrl_det.show()
	
	#Set text boxes to the appropriate entries.
	if global.f_screen:
		$video/fs_flag.set_text("ON")
	else:
		$video/fs_flag.set_text("OFF")
	
	if global.dbl_tap_dash:
		$misc/dt_flag.set_text("ON")
	else:
		$misc/dt_flag.set_text("OFF")
	
	if global.dash_btn:
		$misc/db_flag.set_text("ON")
	else:
		$misc/db_flag.set_text("OFF")
	
	if global.a_charge:
		$misc/ac_flag.set_text("ON")
	else:
		$misc/ac_flag.set_text("OFF")
	
	if global.a_fire:
		$misc/af_flag.set_text("ON")
	else:
		$misc/af_flag.set_text("OFF")
	
	if global.r_fire:
		$misc/rf_flag.set_text("ON")
	else:
		$misc/rf_flag.set_text("OFF")
	
	if global.use_analog:
		$misc/la_flag.set_text("ON")
	else:
		$misc/la_flag.set_text("OFF")
	
	if global.quick_swap:
		$misc/ra_flag.set_text("ON")
	else:
		$misc/ra_flag.set_text("OFF")
	
	match global.chrg_sfx:
		0:
			$misc/c_sound.set_text("NES")
		1:
			$misc/c_sound.set_text("GB")
		2:
			$misc/c_sound.set_text("MM9/10")

func _input(event):
	
	if !ctrl_lock:
		if Input.is_action_just_pressed("down") and menu_pos < menu_size[menu] and set_mode == 0:
			menu_pos += 1
			if menu == 0 and menu_pos == 3 and !global.gp_connect:
				menu_pos += 1
		elif Input.is_action_just_pressed("up") and menu_pos > 0 and set_mode == 0:
			menu_pos -= 1
			if menu == 0 and menu_pos == 3 and !global.gp_connect:
				menu_pos -= 1
		
		cursor_pos()
		
		if event is InputEventKey and set_mode == 2 and menu == 3 and menu_pos != menu_size[menu]:
			global.key_ctrls[menu_pos] = OS.get_scancode_string(event.scancode)
			if REPLACE.has(global.key_ctrls[menu_pos]):
				buttons[menu_pos].set_text('['+REPLACE.get(global.key_ctrls[menu_pos])+']')
			else:
				buttons[menu_pos].set_text('['+global.key_ctrls[menu_pos]+']')
			pressed = true
			buttons[menu_pos].show()
			btn_flash = 0
			set_mode = 3
			save_config()
		
		if event is InputEventJoypadButton and set_mode == 2 and menu == 4 and menu_pos != menu_size[menu]:
			global.joy_ctrls[menu_pos] = Input.get_joy_button_string(event.button_index)
			if which_pad.has(global.joy_ctrls[menu_pos]):
				buttons[menu_pos].set_text('('+which_pad.get(global.joy_ctrls[menu_pos])+')')
			else:
				buttons[menu_pos].set_text('('+global.joy_ctrls[menu_pos]+')')
			pressed = true
			buttons[menu_pos].show()
			btn_flash = 0
			set_mode = 3
			save_config()
		
		if Input.is_action_just_pressed("jump"):
			if menu == 5 and !pressed:
				if menu_pos == menu_size[menu]:
					ctrl_lock = true
					menu = 0
					tween_start("misc", "out")
			if menu == 4 and !pressed:
				if set_mode == 0 and menu_pos != menu_size[menu]:
					set_mode = 1
				elif menu_pos == menu_size[menu]:
					ctrl_lock = true
					menu = 0
					tween_start("controls", "out")
				pressed = true
			if menu == 3 and !pressed:
				if set_mode == 0 and menu_pos != menu_size[menu]:
					set_mode = 1
				elif menu_pos == menu_size[menu]:
					ctrl_lock = true
					menu = 0
					tween_start("controls", "out")
				pressed = true
			if menu == 2 and !pressed:
				if menu_pos == menu_size[menu]:
					ctrl_lock = true
					menu = 0
					tween_start("video", "out")
				pressed = true
			if menu == 1 and !pressed:
				if menu_pos == menu_size[menu]:
					ctrl_lock = true
					menu = 0
					tween_start("audio", "out")
				pressed = true
			if menu == 0 and !pressed:
				ctrl_lock = true
				match menu_pos:
					0:
						menu = 1
					1:
						menu = 2
					2:
						menu = 3
					3:
						menu = 4
					4:
						menu = 5
					5:
						menu = 6
					6:
						$fade.state = 1
						$fade.set("end", true)
				if menu_pos < menu_size[0]:
					tween_start("main", "out")
				pressed = true
		
	if pressed and !Input.is_action_pressed("jump") and !Input.is_action_pressed("fire"):
		if set_mode == 1:
			set_mode = 2
		pressed = false
	
	match menu:
		0:
			if Input.is_action_just_pressed("fire"):
				ctrl_lock = true
				$fade.state = 1
				$fade.set("end", true)
				pressed = true
		1:
			if menu_pos == 0:
				if Input.is_action_just_pressed("left") and global.sound > 0:
					global.sound -= 1
					$audio/sfx.set_value(global.sound)
					save_config()
				if Input.is_action_just_pressed("right") and global.sound < 4:
					global.sound += 1
					$audio/sfx.set_value(global.sound)
					save_config()
			if menu_pos == 1:
				if Input.is_action_just_pressed("left") and global.music > 0:
					global.music -= 1
					$audio/music.set_value(global.music)
					save_config()
				if Input.is_action_just_pressed("right") and global.music < 4:
					global.music += 1
					$audio/music.set_value(global.music)
					save_config()
			
			if Input.is_action_just_pressed("fire"):
				ctrl_lock = true
				menu = 0
				tween_start("audio", "out")
				pressed = true
		2:
			if menu_pos == 0:
				if Input.is_action_just_pressed("left") and global.res > 1:
					global.res -= 1
					save_res = global.res
					global._screen_resized()
					cursor_pos()
				elif Input.is_action_just_pressed("right") and global.res < 4:
					global.res += 1
					save_res = global.res
					global._screen_resized()
					cursor_pos()
				save_config()
			elif menu_pos == 1:
				if Input.is_action_just_pressed("left") or Input.is_action_just_pressed("right"):
					if global.f_screen:
						$video/fs_flag.set_text("OFF")
						global.f_screen = false
						global.res = save_res
						global._screen_resized()
					else:
						$video/fs_flag.set_text("ON")
						global.f_screen = true
						global.res = 1
						global._screen_resized()
					save_config()
			
			if Input.is_action_just_pressed("fire"):
				ctrl_lock = true
				menu = 0
				tween_start("video", "out")
				pressed = true
		3:
			if Input.is_action_just_pressed("fire"):
				ctrl_lock = true
				menu = 0
				tween_start("controls", "out")
				pressed = true
		4:
			if Input.is_action_just_pressed("fire"):
				ctrl_lock = true
				menu = 0
				tween_start("controls", "out")
				pressed = true
		5:
			if Input.is_action_just_pressed("left") or Input.is_action_just_pressed("right"):
				match menu_pos:
					0:
						if global.dbl_tap_dash:
							$misc/dt_flag.set_text("OFF")
							global.dbl_tap_dash = false
						else:
							$misc/dt_flag.set_text("ON")
							global.dbl_tap_dash = true
					1:
						if global.dash_btn:
							$misc/db_flag.set_text("OFF")
							global.dash_btn = false
						else:
							$misc/db_flag.set_text("ON")
							global.dash_btn = true
					2:
						if global.a_charge:
							$misc/ac_flag.set_text("OFF")
							global.a_charge = false
						else:
							$misc/ac_flag.set_text("ON")
							global.a_charge = true
							global.r_fire = true
							if global.a_fire:
								$misc/af_flag.set_text("OFF")
								global.a_fire = false
					3:
						if global.a_fire:
							$misc/af_flag.set_text("OFF")
							global.a_fire = false
						else:
							$misc/af_flag.set_text("ON")
							global.a_fire = true
							if global.a_charge:
								$misc/ac_flag.set_text("OFF")
								global.a_charge = false
							if global.r_fire:
								$misc/rf_flag.set_text("OFF")
								global.r_fire = false
					4:
						if global.r_fire:
							$misc/rf_flag.set_text("OFF")
							global.r_fire = false
						else:
							$misc/rf_flag.set_text("ON")
							global.r_fire = true
							if global.a_fire:
								$misc/af_flag.set_text("OFF")
								global.a_fire = false
					5:
						if global.use_analog:
							$misc/la_flag.set_text("OFF")
							global.use_analog = false
						else:
							$misc/la_flag.set_text("ON")
							global.use_analog = true
					6:
						if global.quick_swap:
							$misc/ra_flag.set_text("OFF")
							global.quick_swap = false
						else:
							$misc/ra_flag.set_text("ON")
							global.quick_swap = true
				save_config()
			
			if menu_pos == 7:
				if Input.is_action_just_pressed("left") and global.chrg_sfx > 0:
					global.chrg_sfx -= 1
					save_config()
				elif Input.is_action_just_pressed("right") and global.chrg_sfx < 2:
					global.chrg_sfx += 1
					save_config()
				match global.chrg_sfx:
					0:
						$misc/c_sound.set_text("NES")
					1:
						$misc/c_sound.set_text("GB")
					2:
						$misc/c_sound.set_text("MM9/10")
			
			if Input.is_action_just_pressed("fire"):
				ctrl_lock = true
				menu = 0
				tween_start("misc", "out")
				pressed = true
		6:
			if Input.is_action_just_pressed("fire"):
				ctrl_lock = true
				menu = 0
				tween_start("extras", "out")
				pressed = true

func _physics_process(_delta):
	
	if set_mode == 3:
		set_mode = 0
	
	if set_mode > 0 and set_mode < 3 and btn_flash < 8 and menu_pos != menu_size[menu]:
		btn_flash += 1
		
		if btn_flash > 7:
			btn_flash = 0
		
		if btn_flash == 0:
			buttons[menu_pos].show()
		
		if btn_flash == 4:
			buttons[menu_pos].hide()

func _on_fade_fadein():
	ctrl_lock = false
	$cursor.show()

func _on_fade_fadeout():
	if $fade.state == 1:
# warning-ignore:return_value_discarded
		get_tree().change_scene("res://scenes/title.tscn")

func _on_txt_fade_completed(object, _key):
	
	if object.name == "main":
		menu_pos = 0
		cursor_pos()
		match menu:
			0:
				cursor_pos()
				$cursor.show()
				ctrl_lock = false
			1:
				tween_start("audio", "in")
			2:
				tween_start("video", "in")
			3:
				buttons = get_tree().get_nodes_in_group("button")
				
				for b in range(global.actions.size()):
					if global.actions[b] == buttons[b].name:
						if REPLACE.has(global.key_ctrls[b]):
							buttons[b].set_text('['+REPLACE.get(global.key_ctrls[b])+']')
						else:
							buttons[b].set_text('['+global.key_ctrls[b]+']')
				
				tween_start("controls", "in")
			4:
				buttons = get_tree().get_nodes_in_group("button")
				
				for b in range(global.actions.size()):
					if global.actions[b] == buttons[b].name:
						if which_pad.has(global.joy_ctrls[b]):
							buttons[b].set_text('('+which_pad.get(global.joy_ctrls[b])+')')
						else:
							buttons[b].set_text('('+global.joy_ctrls[b]+')')
							
				tween_start("controls", "in")
			5:
				tween_start("misc", "in")
			6:
				tween_start("extras", "in")
	else:
		if menu != 0:
			menu_pos = 0
			cursor_pos()
			$cursor.show()
			if menu == 2:
				$cursor2.show()
			ctrl_lock = false
		else:
			tween_start("main", "in")

func cursor_pos():
	$cursor.position.y = ca_start + (16 * menu_pos)
	$cursor2.position.x = cb_start + (32 * (global.res - 1))

func tween_start(name, in_out):
	var menus = get_tree().get_nodes_in_group("menus")
	$cursor.hide()
	$cursor2.hide()
	
	for m in menus:
		if name == m.name:
			if in_out == "in":
				$txt_fade.interpolate_property(m, 'modulate', Color(1.0, 1.0, 1.0, 0.0), Color(1.0, 1.0, 1.0, 1.0), 0.125, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
				$txt_fade.start()
			else:
				$txt_fade.interpolate_property(m, 'modulate', Color(1.0, 1.0, 1.0, 1.0), Color(1.0, 1.0, 1.0, 0.0), 0.125, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
				$txt_fade.start()

func save_config():
	global.set_ctrls()
	
	var config = ConfigFile.new()
	var err = config.load(CONFIG_FILE)
	
	if !err:
		for action_name in global.actions:
			var action_list = InputMap.get_action_list(action_name)
			# There could be multiple actions in the list, but we save the first one by default
			var scancode = OS.get_scancode_string(action_list[0].scancode)
			var pad_button = Input.get_joy_button_string(action_list[1].button_index)
			config.set_value("k_input", action_name, scancode) #Keyboard keys
			config.set_value("g_input", action_name, pad_button) #Gamepad buttons
		#Save default options.
		config.set_value("options", "res", global.res)
		config.set_value("options", "f_screen", global.f_screen)
		config.set_value("options", "quick_swap", global.quick_swap)
		config.set_value("options", "use_analog", global.use_analog)
		config.set_value("options", "dash_btn", global.dash_btn)
		config.set_value("options", "dbl_tap_dash", global.dbl_tap_dash)
		config.set_value("options", "a_charge", global.a_charge)
		config.set_value("options", "a_fire", global.a_fire)
		config.set_value("options", "r_fire", global.r_fire)
		config.set_value("options", "chrg_sfx", global.chrg_sfx)
		#Save config
		config.save(CONFIG_FILE)
