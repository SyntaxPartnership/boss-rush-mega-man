extends Control

const INPUT_ACTIONS = ['up', 'down', 'left', 'right', 'jump', 'fire', 'dash', 'prev', 'next', 'select', 'start']
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
	"Face Button Top"		: "Y",
	"Face Button Bottom"	: "A",
	"Face Button Left"		: "X",
	"Face Button Right"		: "B",
	"Select"				: "SELECT",
	"Start"					: "START"
	}

var menus = {
	"option_0" : 'UP\n\nDOWN\n\nLEFT\n\nRIGHT\n\nJUMP\n\nFIRE\n\nDASH\n\nPREV\n\nNEXT\n\nSELECT\n\nSTART',
	"option_1" : 'JUMP\n\nFIRE\n\nDASH\n\nPREV\n\nNEXT\n\nSELECT\n\nSTART',
	"option_2" : 'USE RIGHT ANALOG/ NUMPAD TO SWAP WEAPONS QUICKLY?',
	"option_3" : 'MUSIC\n\nEFFECTS',
	"option_4" : 'SCALE\n\n\n\nFULLSCREEN',
	"option_5" : '',
	"option_6" : ''
	}

var info = {
	"info_0" : "SET\nKEYBOARD\nCONTROLS.",
	"info_1" : "SET GAMEPAD\nCONTROLS.",
	"info_2" : "TOGGLE\nQUICK SWAP.",
	"info_3" : "ADJUST\nMUSIC & SFX\nVOLUME.",
	"info_4" : "ADJUST\nDISPLAY\nSETTINGS.",
	"info_5" : "SET MISC.\nOPTIONS",
	"info_6" : "RETURN TO\nMAIN MENU."
	}


var ctrl_lock = true
var pressed = false
var setting = false
var f_delay = 0
var cur_a_pos = Vector2()
var cur_b_pos = Vector2()

var menu = 0
var menu_a_pos = 0
var menu_b_pos = 0
var menu_b_max = 0

var save_res = 0

func _ready():
	
	cur_a_pos = $cursor.position
	cur_b_pos = $cursor2.position
	
	$info.set_text(info.get("info_"+str(menu_a_pos)))

func _input(event):
	
	if !ctrl_lock:
		var x_dir = int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left"))
		var y_dir = int(Input.is_action_pressed("down")) - int(Input.is_action_pressed("up"))

		if menu == 0 and !pressed:
			if y_dir == -1 and menu_a_pos > 0:
				menu_a_pos -= 1
			if y_dir == 1 and menu_a_pos < 6:
				menu_a_pos += 1
			
			$info.set_text(info.get("info_"+str(menu_a_pos)))

			if Input.is_action_just_pressed("jump"):
				pressed = true
				match menu_a_pos:
					0:
						menu_b_max = 10
						var id = 1
						for actions in INPUT_ACTIONS:
							var act_list = InputMap.get_action_list(actions)
							#Assume that the first entry deals with keyboard commands.
							var scancode = OS.get_scancode_string(act_list[0].scancode)
							if REPLACE.has(scancode):
								scancode = REPLACE.get(scancode)
							match id:
								1:
									$opt_text/opt01.set_text('['+scancode+']')
								2:
									$opt_text/opt02.set_text('['+scancode+']')
								3:
									$opt_text/opt03.set_text('['+scancode+']')
								4:
									$opt_text/opt04.set_text('['+scancode+']')
								5:
									$opt_text/opt05.set_text('['+scancode+']')
								6:
									$opt_text/opt06.set_text('['+scancode+']')
								7:
									$opt_text/opt07.set_text('['+scancode+']')
								8:
									$opt_text/opt08.set_text('['+scancode+']')
								9:
									$opt_text/opt09.set_text('['+scancode+']')
								10:
									$opt_text/opt10.set_text('['+scancode+']')
								11:
									$opt_text/opt11.set_text('['+scancode+']')
							id += 1
						for b in get_tree().get_nodes_in_group("button"):
							b.show()
						set_text()
					1:
						menu_b_max = 6
						var id = 1
						for actions in INPUT_ACTIONS:
							var act_list = InputMap.get_action_list(actions)
							if actions != INPUT_ACTIONS[0] and actions != INPUT_ACTIONS[1] and actions != INPUT_ACTIONS[2] and actions != INPUT_ACTIONS[3]:
								var button = Input.get_joy_button_string(act_list[1].button_index)
								if REPLACE.has(button):
									button = REPLACE.get(button)
#							if REPLACE.has(scancode):
#								scancode = REPLACE.get(scancode)
								match id:
									5:
										$opt_text/opt01.set_text('('+button+')')
									6:
										$opt_text/opt02.set_text('('+button+')')
									7:
										$opt_text/opt03.set_text('('+button+')')
									8:
										$opt_text/opt04.set_text('('+button+')')
									9:
										$opt_text/opt05.set_text('('+button+')')
									10:
										$opt_text/opt06.set_text('('+button+')')
									11:
										$opt_text/opt07.set_text('('+button+')')
							id += 1
						for b in get_tree().get_nodes_in_group("button"):
							if b.name != 'opt08' and b.name != 'opt09' and b.name != 'opt10' and b.name != 'opt11':
								b.show()
						set_text()
					4:
						menu_b_max = 1
						$opt_text/opt01.set_text('X'+str(global.res))
						$opt_text/opt01.show()
						if !global.f_screen:
							$opt_text/opt03.set_text('NO')
						else:
							$opt_text/opt03.set_text('YES')
						$opt_text/opt03.show()
						set_text()
					6:
						$fade.state = 1
						$fade.set("end", true)

		if menu == 2 and !pressed and !setting:
			#Add if statement for certain menus.
			var up_down = [0, 1, 4]
			
			if up_down.has(menu_a_pos):
				if y_dir == -1 and menu_b_pos > 0:
					menu_b_pos -= 1
				if y_dir == 1 and menu_b_pos < menu_b_max:
					menu_b_pos += 1
			
		#Keyboard menu
		if menu_a_pos == 0 and menu == 2:
			if Input.is_action_just_pressed("jump") and !pressed and !setting:
				if event is InputEventKey:
					pressed = true
					setting = true
			
			if event is InputEventKey:
				if !pressed and setting:
					var scancode = OS.get_scancode_string(event.scancode)
					var action = INPUT_ACTIONS[menu_b_pos]
					
					match menu_b_pos:
						0:
							$opt_text/opt01.show()
							if REPLACE.has(scancode):
								$opt_text/opt01.set_text('['+REPLACE.get(scancode)+']')
							else:
								$opt_text/opt01.set_text('['+scancode+']')
						1:
							$opt_text/opt02.show()
							if REPLACE.has(scancode):
								$opt_text/opt02.set_text('['+REPLACE.get(scancode)+']')
							else:
								$opt_text/opt02.set_text('['+scancode+']')
						2:
							$opt_text/opt03.show()
							if REPLACE.has(scancode):
								$opt_text/opt03.set_text('['+REPLACE.get(scancode)+']')
							else:
								$opt_text/opt03.set_text('['+scancode+']')
						3:
							$opt_text/opt04.show()
							if REPLACE.has(scancode):
								$opt_text/opt04.set_text('['+REPLACE.get(scancode)+']')
							else:
								$opt_text/opt04.set_text('['+scancode+']')
						4:
							$opt_text/opt05.show()
							if REPLACE.has(scancode):
								$opt_text/opt05.set_text('['+REPLACE.get(scancode)+']')
							else:
								$opt_text/opt05.set_text('['+scancode+']')
						5:
							$opt_text/opt06.show()
							if REPLACE.has(scancode):
								$opt_text/opt06.set_text('['+REPLACE.get(scancode)+']')
							else:
								$opt_text/opt06.set_text('['+scancode+']')
						6:
							$opt_text/opt07.show()
							if REPLACE.has(scancode):
								$opt_text/opt07.set_text('['+REPLACE.get(scancode)+']')
							else:
								$opt_text/opt07.set_text('['+scancode+']')
						7:
							$opt_text/opt08.show()
							if REPLACE.has(scancode):
								$opt_text/opt08.set_text('['+REPLACE.get(scancode)+']')
							else:
								$opt_text/opt08.set_text('['+scancode+']')
						8:
							$opt_text/opt09.show()
							if REPLACE.has(scancode):
								$opt_text/opt09.set_text('['+REPLACE.get(scancode)+']')
							else:
								$opt_text/opt09.set_text('['+scancode+']')
						9:
							$opt_text/opt10.show()
							if REPLACE.has(scancode):
								$opt_text/opt10.set_text('['+REPLACE.get(scancode)+']')
							else:
								$opt_text/opt10.set_text('['+scancode+']')
						10:
							$opt_text/opt11.show()
							if REPLACE.has(scancode):
								$opt_text/opt11.set_text('['+REPLACE.get(scancode)+']')
							else:
								$opt_text/opt11.set_text('['+scancode+']')
								
					for old_event in InputMap.get_action_list(action):
						InputMap.action_erase_event(action, old_event)
						# Add the new key binding
						InputMap.action_add_event(action, event)
					pressed = true
					setting = false
					f_delay = 0
					save_to_config("k_input", action, scancode)
		
		if menu_a_pos == 1 and menu == 2:
			if Input.is_action_just_pressed("jump") and !pressed and !setting:
				if event is InputEventJoypadButton:
					pressed = true
					setting = true
			
			#Gamepad menu
			if event is InputEventJoypadButton:
				if !pressed and setting:
					var button = Input.get_joy_button_string(event.button_index)
					var action = INPUT_ACTIONS[menu_b_pos + 4]
				
					match menu_b_pos:
						4:
							$opt_text/opt05.show()
							if REPLACE.has(button):
								$opt_text/opt05.set_text('('+REPLACE.get(button)+')')
							else:
								$opt_text/opt05.set_text('('+button+')')
						5:
							$opt_text/opt06.show()
							if REPLACE.has(button):
								$opt_text/opt06.set_text('('+REPLACE.get(button)+')')
							else:
								$opt_text/opt06.set_text('('+button+')')
						6:
							$opt_text/opt07.show()
							if REPLACE.has(button):
								$opt_text/opt07.set_text('('+REPLACE.get(button)+')')
							else:
								$opt_text/opt07.set_text('('+button+')')
						7:
							$opt_text/opt08.show()
							if REPLACE.has(button):
								$opt_text/opt08.set_text('('+REPLACE.get(button)+')')
							else:
								$opt_text/opt08.set_text('('+button+')')
						8:
							$opt_text/opt09.show()
							if REPLACE.has(button):
								$opt_text/opt09.set_text('('+REPLACE.get(button)+')')
							else:
								$opt_text/opt09.set_text('('+button+')')
						9:
							$opt_text/opt10.show()
							if REPLACE.has(button):
								$opt_text/opt10.set_text('('+REPLACE.get(button)+')')
							else:
								$opt_text/opt10.set_text('('+button+')')
						10:
							$opt_text/opt11.show()
							if REPLACE.has(button):
								$opt_text/opt11.set_text('('+REPLACE.get(button)+')')
							else:
								$opt_text/opt11.set_text('('+button+')')
					
					for old_event in InputMap.get_action_list(action):
						InputMap.action_erase_event(action, old_event)
						# Add the new key binding
						InputMap.action_add_event(action, event)
					pressed = true
					setting = false
					f_delay = 0
					save_to_config("g_input", action, button)
			
		#Resolution Menu
		if menu_a_pos == 4:
			if menu_b_pos == 0:
				if !global.f_screen and !pressed:
					if x_dir == -1 and global.res > 1:
						pressed = true
						global.res -= 1
						$opt_text/opt01.set_text('X'+str(global.res))
						global._screen_resized()
					if x_dir == 1 and global.res < 4:
						pressed = true
						global.res += 1
						$opt_text/opt01.set_text('X'+str(global.res))
						global._screen_resized()
			
			if menu_b_pos == 1:
				if x_dir != 0 and !pressed:
					pressed = true
					if global.f_screen:
						global.f_screen = false
						$opt_text/opt03.set_text('NO')
						global.res = save_res
						$opt_text/opt01.set_text('X'+str(global.res))
						global._screen_resized()
					else:
						save_res = global.res
						global.res = 1
						global.f_screen = true
						$opt_text/opt01.set_text('X'+str(global.res))
						$opt_text/opt03.set_text('YES')
						global._screen_resized()
			
		#Return to the previous menu.
		if Input.is_action_just_pressed("fire") and menu == 2:
			menu = 3
			$cursor2.hide()
			$txt_fade.interpolate_property($opt_text, 'modulate', Color(1.0, 1.0, 1.0, 1.0), Color(1.0, 1.0, 1.0, 0.0), 0.125, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			$txt_fade.start()
		
		if y_dir != 0 or x_dir != 0 and !setting:
			pressed = true
	
		if y_dir == 0 and x_dir == 0 and !Input.is_action_pressed("jump"):
			pressed = false
	
	$cursor.position.y = cur_a_pos.y + (menu_a_pos * 16)
	#Add if statement for certain menus
	if menu_a_pos != 4:
		$cursor2.position.y = cur_b_pos.y + (menu_b_pos * 16)
	else:
		$cursor2.position.y = cur_b_pos.y + (menu_b_pos * 32)

# warning-ignore:unused_argument
func _process(delta):
	
	if setting:
		f_delay += 1
	
	if f_delay > 15:
		f_delay = 0
	
	#Make the option flash.
	if menu_a_pos == 0 and setting:
		match menu_b_pos:
			0:
				if f_delay == 0:
					$opt_text/opt01.show()
				if f_delay == 7:
					$opt_text/opt01.hide()
			1:
				if f_delay == 0:
					$opt_text/opt02.show()
				if f_delay == 7:
					$opt_text/opt02.hide()
			2:
				if f_delay == 0:
					$opt_text/opt03.show()
				if f_delay == 7:
					$opt_text/opt03.hide()
			3:
				if f_delay == 0:
					$opt_text/opt04.show()
				if f_delay == 7:
					$opt_text/opt04.hide()
			4:
				if f_delay == 0:
					$opt_text/opt05.show()
				if f_delay == 7:
					$opt_text/opt05.hide()
			5:
				if f_delay == 0:
					$opt_text/opt06.show()
				if f_delay == 7:
					$opt_text/opt06.hide()
			6:
				if f_delay == 0:
					$opt_text/opt07.show()
				if f_delay == 7:
					$opt_text/opt07.hide()
			7:
				if f_delay == 0:
					$opt_text/opt08.show()
				if f_delay == 7:
					$opt_text/opt08.hide()
			8:
				if f_delay == 0:
					$opt_text/opt09.show()
				if f_delay == 7:
					$opt_text/opt09.hide()
			9:
				if f_delay == 0:
					$opt_text/opt10.show()
				if f_delay == 7:
					$opt_text/opt10.hide()
			10:
				if f_delay == 0:
					$opt_text/opt11.show()
				if f_delay == 7:
					$opt_text/opt11.hide()

func _on_fade_fadein():
	ctrl_lock = false
	$cursor.show()

func _on_fade_fadeout():
	if $fade.state == 1:
# warning-ignore:return_value_discarded
		get_tree().change_scene("res://scenes/title.tscn")

# warning-ignore:unused_argument
func _on_txt_fade_completed(object, key):
	if object.name == "opt_text":
		if menu == 1:
			if menu_a_pos == 0 or menu_a_pos == 1 or menu_a_pos == 4:
				menu_b_pos = 0
				$cursor2.position.y = cur_b_pos.y + (menu_b_pos * 16)
				$cursor2.show()
			menu = 2
		if menu == 3:
			menu = 0
			for b in get_tree().get_nodes_in_group("button"):
				b.hide()

func set_text():
	$opt_text.set_text(menus.get("option_"+str(menu_a_pos)))
	$txt_fade.interpolate_property($opt_text, 'modulate', Color(1.0, 1.0, 1.0, 0.0), Color(1.0, 1.0, 1.0, 1.0), 0.125, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$txt_fade.start()
	menu = 1

func save_to_config(section, key, value):
	var config = ConfigFile.new()
	var err = config.load(CONFIG_FILE)
	if err:
		print("Error code when loading config file: ", err)
	else:
		config.set_value(section, key, value)
		config.save(CONFIG_FILE)