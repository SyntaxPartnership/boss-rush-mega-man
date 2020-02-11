extends Node2D

var gm_ovr = "CONTINUE\n\n"
var menu_txt = "STAGE SELECT\n\nSAVE\n\nOPTIONS\n\nEXIT"

var over_time = 300

var show_menu = true

var lock = true
var menu_pos = 0
var max_pos = 0
var c_pos = Vector2()

var max_en = 280
var en_lvls = {
	0 : global.player_life,
	1 : global.weapon1,
	2 : global.weapon2,
	3 : global.weapon3,
	4 : global.weapon4,
	}

# Called when the node enters the scene tree for the first time.
func _ready():
	#Get cursor default position.
	c_pos = $cursor.position
	
	#Display the game over text if the player failed to complete the level.
	if global.game_over:
		$game_over.show()
		$menu_txt.set_deferred('modulate', Color(1.0, 1.0, 1.0, 0.0))
		$menu_txt.set_text(gm_ovr + menu_txt)
		show_menu = false
		max_pos = 4
	else:
		$menu_txt.set_text(menu_txt)
		max_pos = 3
		
	#Reset lives
	global.lives = 2
	
	#Reset player energy levels
	for i in range(en_lvls.size()):
		if i == 0:
			en_lvls[i][0] = max_en
			if global.player_id[1] != 99: #Just in case the player decides to continue.
				en_lvls[i][1] = max_en
		else:
			en_lvls[i][1] = max_en
			en_lvls[i][2] = max_en
	
	#Reset collected items.
	global.temp_items.clear()

func _input(event):
	
	if !lock:
		if Input.is_action_just_pressed("down") and menu_pos < max_pos:
			$cursor2.play()
			menu_pos += 1
		if Input.is_action_just_pressed("up") and menu_pos > 0:
			$cursor2.play()
			menu_pos -= 1
		
		if Input.is_action_just_pressed("jump") or Input.is_action_just_pressed("start"):
			$select.play()
			if max_pos != 4:
				if menu_pos == 0:
					$fade.state = 1
				if menu_pos == 1:
					$fade.state = 2
				if menu_pos == 2:
					$fade.state = 4
				if menu_pos == 3:
					$fade.state = 6
			else:
				if menu_pos == 0:
					$fade.state = 8
				if menu_pos == 1:
					$fade.state = 1
				if menu_pos == 2:
					$fade.state = 2
				if menu_pos == 3:
					$fade.state = 4
				if menu_pos == 4:
					$fade.state = 6
			$fade.end = true
			lock = true

func _process(delta):
	
	#Set cursor position.
	$cursor.position.y = c_pos.y + (menu_pos * 16)
	
	if global.game_over and over_time > 0:
		over_time -= 1
	
	if global.game_over and over_time == 0:
		global.game_over = false
		$txt_fade.interpolate_property($game_over, 'modulate', Color(1.0, 1.0, 1.0, 1.0), Color(1.0, 1.0, 1.0, 0.0), 0.125, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		$txt_fade.start()

func _on_txt_fade_completed(object, key):
	
	if object.name == "game_over":
		if !global.game_over and !show_menu:
			show_menu = true
			$txt_fade.interpolate_property($menu_txt, 'modulate', Color(1.0, 1.0, 1.0, 0.0), Color(1.0, 1.0, 1.0, 1.0), 0.125, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			$txt_fade.start()
	
	if object.name == "menu_txt":
		lock = false
		$cursor.show()

func _on_fadein():
	if !global.game_over:
		$cursor.show()
		lock = false
		
func _on_fadeout():
	if $fade.state == 1:
		get_tree().change_scene("res://scenes/stage_select.tscn")
	
	#NOTE! Change the scenes as options become available.
	if $fade.state == 2:
		get_tree().change_scene("res://scenes/stage_select.tscn")
	
	if $fade.state == 4:
		get_tree().change_scene("res://scenes/stage_select.tscn")
	
	if $fade.state == 6:
		get_tree().quit()
	
	if $fade.state == 8:
		get_tree().change_scene("res://scenes/world.tscn")
