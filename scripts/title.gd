extends Node2D

var menu_pos = 0
var menu = 0
var can_move = false
var fade_in = false
var fade_out = false
var cursor_pos = Vector2()

func _ready():
	cursor_pos = $cursor.position

# warning-ignore:unused_argument
func _input(event):
	if can_move:
		
		if Input.is_action_just_pressed('start') or Input.is_action_just_pressed('jump'):
			if menu == 1:
				if menu_pos == 0 or menu_pos == 1:
					$sounds/select.play()
					menu += 1
					$fade.state = 1
					$fade.set("end", true)
				elif menu_pos == 2:
# warning-ignore:return_value_discarded
					OS.shell_open('https://docs.google.com/forms/d/e/1FAIpQLSelexfghh9gmATILFTiGlgXRaFNjJCXwUAkJoMlBAXvH8JPsQ/viewform')
			if menu == 0:
				$sounds/select.play()
				menu += 1
				fade_in = true
				can_move = false
				$menu_fade.interpolate_property($menu, 'modulate', Color(1.0, 1.0, 1.0, 1.0), Color(1.0, 1.0, 1.0, 0.0), 0.125, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
				$menu_fade.start()
		
		if Input.is_action_just_pressed('fire'):
			if menu == 1:
				$sounds/back.play()
				menu -= 1
				fade_in = true
				can_move = false
				$menu_fade.interpolate_property($menu, 'modulate', Color(1.0, 1.0, 1.0, 1.0), Color(1.0, 1.0, 1.0, 0.0), 0.125, Tween.TRANS_LINEAR, Tween.EASE_OUT_IN)
				$menu_fade.start()
				$cursor.hide()
		
		if menu == 1 and Input.is_action_just_pressed('up'):
			$sounds/cursor.play()
			menu_pos -= 1
		elif menu == 1 and Input.is_action_just_pressed('down'):
			$sounds/cursor.play()
			menu_pos += 1
		
		#Loop cursor position.
		if menu_pos < 0:
			menu_pos = 2
		elif menu_pos > 2:
			menu_pos = 0
		
		#Set sprite to position.
		$cursor.position.y = cursor_pos.y + (16 * menu_pos)

func _on_fade_fadein():
	can_move = true

func _on_fade_fadeout():
	if menu_pos == 0:
		# warning-ignore:return_value_discarded
		global.cutscene = 1
		get_tree().change_scene("res://scenes/cutscene.tscn")
	elif menu_pos == 1:
		# warning-ignore:return_value_discarded
		get_tree().change_scene("res://scenes/options.tscn")

# warning-ignore:unused_argument
# warning-ignore:unused_argument
func _on_menu_fade_tween_completed(object, key):
	#Resume menu movement.
	if !fade_in and !fade_out:
		can_move = true
		if menu == 1:
			$cursor.show()
	
	#Make the menu fade back in.
	if fade_in:
		fade_in = false
		fade_out = true
		$menu_fade.interpolate_property($menu, 'modulate', Color(1.0, 1.0, 1.0, 0.0), Color(1.0, 1.0, 1.0, 1.0), 0.25, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		$menu_fade.start()
	#Change the text as needed.
	if fade_out:
		if menu == 0:
			$menu.set_text('\n\nPRESS START')
		elif menu == 1:
			$menu.set_text('NEW GAME\n\nOPTIONS\n\nFEEDBACK')
		elif menu == 2:
			$menu.set_text('EASY\n\nNORMAL\n\n?????\n\n?????\n\n?????')
		fade_out = false
