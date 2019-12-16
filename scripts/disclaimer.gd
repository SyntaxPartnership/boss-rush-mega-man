extends Node2D

var allow_ctrl = false

var text_a = "       ----WARNING!----\n\n\n\n\nThis is a test demo of a fan\ngame currently in production.\n\n\nAnything found within is\nsubject to change and may not\nbe included in the final\nrelease.\n\n\nMega Man™ and all related\ncharacters are © Capcom\nCo., LTD.\n\n\nThis game was developed as\na free, non profit project."

const INPUT_ACTIONS = ['up', 'down', 'left', 'right', 'jump', 'fire', 'dash', 'prev', 'next', 'select', 'start']
const CONFIG_FILE = 'user://options.cfg'

var txt_line = 0

func _ready():
	global._screen_resized()
	
	$text.set_text(text_a)
	load_config()
	pass

#Using the example of loading/saving from the Input Mapping tutorial.
func load_config():
	var config = ConfigFile.new()
	var err = config.load(CONFIG_FILE)
	if err: #Assuming that options.cfg doesn't exist.
		for action_name in INPUT_ACTIONS:
			var action_list = InputMap.get_action_list(action_name)
			# There could be multiple actions in the list, but we save the first one by default
			var scancode = OS.get_scancode_string(action_list[0].scancode)
			var pad_button = Input.get_joy_button_string(action_list[1].button_index)
			config.set_value("k_input", action_name, scancode) #Keyboard keys
			if action_name != INPUT_ACTIONS[0] and action_name != INPUT_ACTIONS[1] and action_name != INPUT_ACTIONS[2] and action_name != INPUT_ACTIONS[3]:
				config.set_value("g_input", action_name, pad_button) #Gamepad buttons
		#Save default options.
		config.set_value("options", "res", global.res)
		config.set_value("options", "f_screen", global.f_screen)
		config.set_value("options", "quick_swap", global.quick_swap)
		#Save config
		config.save(CONFIG_FILE)
	else: #Successful load. Set values.
		global.erase_dirs()
		#Load keyboard values
		for action_name in config.get_section_keys("k_input"):
			# Get the key scancode corresponding to the saved human-readable string
			var scancode = OS.find_scancode_from_string(config.get_value("k_input", action_name))
			# Create a new event object based on the saved scancode
			var event = InputEventKey.new()
			event.scancode = scancode
			# Replace old action (key) events by the new one
			for old_event in InputMap.get_action_list(action_name):
				if old_event is InputEventKey:
					InputMap.action_erase_event(action_name, old_event)
			InputMap.action_add_event(action_name, event)
		#Load gamepad buttons
		for button_name in config.get_section_keys("g_input"):
			var button = config.get_value("g_input", button_name)
			var event = InputEventJoypadButton.new()
			event.set_button_index(Input.get_joy_button_index_from_string(button))
			for old_event in InputMap.get_action_list(button_name):
				if old_event is InputEventJoypadButton:
					InputMap.action_erase_event(button_name, old_event)
			InputMap.action_add_event(button_name, event)
		
		global.res			= config.get_value("options", "res")
		global.f_screen		= config.get_value("options", "f_screen")
		global.quick_swap	= config.get_value("options", "quick_swap")
		
		global.resize()
		global.set_dirs()

# warning-ignore:unused_argument
func _process(delta):
		#Include this to allow skipping of filler screens and legal mumbo jumbo.
	if allow_ctrl:
		if Input.is_action_just_pressed("jump") or Input.is_action_just_pressed("start"):
			allow_ctrl = false
			$timer.stop()
			$fade.state = 1
			$fade.set("end", true)

func _on_timer_timeout():
	$fade.state = 1
	$fade.set("end", true)

#Include this function to allow the player to have control.
func _on_fade_fadein():
	allow_ctrl = true
	$timer.start(10)

#Fade out and move to the next scene.
func _on_fade_fadeout():
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://scenes/title.tscn")

func _on_txt_timeout():
	$txt_fade.interpolate_property($text, 'modulate', Color(1.0, 1.0, 1.0, 1.0), Color(1.0, 1.0, 1.0, 0.0), 0.125, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$txt_fade.start()
