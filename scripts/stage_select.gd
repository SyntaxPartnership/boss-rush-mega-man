extends Node2D

var menu = 0
var c_menu = 0
var select = Vector2(1, 1)
var sel_flash = 0
var big_flash = 0
var bf_time = 60

var pressed = false

var begin_fade = true

var reverse = false
var bar_spd = 200
var tile_pos_a
var tile_pos_b

var final = 24
var rock_leave = false
var blues_leave = false
var bass_leave = false

var lvl_ids = {
	"(0, 0)" : 0,
	"(1, 0)" : 1,
	"(2, 0)" : 2
	}

var char_ids = [0, 0]

func _ready():
	#Make defeated bosses invisible.
	if global.boss1_clear:
		$mugs/mug_01.hide()
	if global.boss2_clear:
		$mugs/mug_02.hide()
	if global.boss3_clear:
		$mugs/mug_03.hide()
	if global.boss4_clear:
		$mugs/mug_04.hide()
	if global.boss5_clear:
		$mugs/mug_06.hide()
	if global.boss6_clear:
		$mugs/mug_07.hide()
	if global.boss7_clear:
		$mugs/mug_08.hide()
	if global.boss8_clear:
		$mugs/mug_09.hide()
	
	#Set player icon positions depending on if bass has been unlocked.	
	if !global.bass:
		$char_menu/chars/rock.position.x = 88
		$char_menu/chars/blues.position.x = 128
		$char_menu/chars/ok.position.x = 168
		$char_menu/chars/bass.hide()
	else:
		$char_menu/chars/bass.show()
	
	#Set default cursor position.
	$misc/select.position.x = 48 + (80 * select.x)
	$misc/select.position.y = 56 + (64 * select.y)

# warning-ignore:unused_argument
func _input(event):
	
	if menu == 1:
		#Set cursor position
		if Input.is_action_just_pressed("left") and select.x > 0:
			select.x -= 1
			sel_flash = 0
			$misc/select.show()
			$cursor.play()
		if Input.is_action_just_pressed("right") and select.x < 2:
			select.x += 1
			sel_flash = 0
			$misc/select.show()
			$cursor.play()
		if Input.is_action_just_pressed("up") and select.y > 0:
			select.y -= 1
			sel_flash = 0
			$misc/select.show()
			$cursor.play()
		if Input.is_action_just_pressed("down") and select.y < 2:
			select.y += 1
			sel_flash = 0
			$misc/select.show()
			$cursor.play()
		
		if Input.is_action_just_pressed("jump") or Input.is_action_just_pressed("start") and !pressed:
			$misc/select.hide()
			$misc/flash.show()
			$bling.play()
			pressed = true
			menu = 2

	if menu == 7:
		if Input.is_action_just_pressed("left") and c_menu > 0:
			c_menu -= 1
			$char_menu/chars/cursor2.show()
			sel_flash = 0
			$cursor.play()
		if Input.is_action_just_pressed("right") and c_menu < 1 and !global.bass or Input.is_action_just_pressed("right") and c_menu < 3 and global.bass:
			c_menu += 1
			$char_menu/chars/cursor2.show()
			sel_flash = 0
			$cursor.play()
		
		#Skip selected players.
		if Input.is_action_just_pressed("left") and c_menu == 0 and char_ids[0] == 0:
			c_menu += 1
		
		if Input.is_action_just_pressed("left") and c_menu == 1 and char_ids[0] == 1:
			c_menu -= 1
		
		if Input.is_action_just_pressed("right") and c_menu == 1 and char_ids[0] == 1:
			c_menu += 1
		
		if Input.is_action_just_pressed("left") and c_menu == 2 and char_ids[0] == 2:
			c_menu -= 1
		
		if Input.is_action_just_pressed("right") and c_menu == 2 and char_ids[0] == 2:
			c_menu += 1
		
		#Finalize character selection
		if Input.is_action_just_pressed("jump") or Input.is_action_just_pressed("start") and !pressed:
			$char_sel.play()
			$char_menu/chars/cursor1.show()
			$char_menu/chars/cursor2.show()
			char_ids[1] = c_menu
			global.level_id = lvl_ids.get(str(select))
			global.player_id[0] = char_ids[0]
			if char_ids[1] != 3:
				global.player_id[1] = char_ids[1]
			else:
				global.player_id[1] = 99
				global.player_life[1] = 0
			pressed = true
			menu = 8
		
		#Return to the previous menu.
		if Input.is_action_just_pressed("fire"):
			$dink.play()
			menu = 6
			c_menu = char_ids[0]
			sel_flash = 0
			$char_menu/chars/cursor2.hide()
	
	if menu == 6:
		if Input.is_action_just_pressed("left") and c_menu > 0:
			c_menu -= 1
			$char_menu/chars/cursor1.show()
			sel_flash = 0
			$cursor.play()
		if Input.is_action_just_pressed("right") and c_menu < 1 and !global.bass or Input.is_action_just_pressed("right") and c_menu < 2 and global.bass:
			c_menu += 1
			$char_menu/chars/cursor1.show()
			sel_flash = 0
			$cursor.play()
		
		if Input.is_action_just_pressed("jump") or Input.is_action_just_pressed("start") and !pressed:
			$char_sel.play()
			$char_menu/chars/cursor1.show()
			$char_menu/chars/cursor2.show()
			char_ids[0] = c_menu
			if c_menu == 0:
				c_menu = 1
			else:
				c_menu = 0
			pressed = true
			menu = 7
		
		#Return to the previous menu.
		if Input.is_action_just_pressed("fire"):
			menu = 99
			$fade.state = 1
			$dink.play()
			$fade.end = true
	
	if !Input.is_action_pressed("jump") and !Input.is_action_pressed("start"):
		pressed = false
		
# warning-ignore:unused_argument
func _process(delta):
	
	if menu == 1:
		#Make the mugshot selected flash.
		sel_flash += 1
	
		if sel_flash > 17:
			sel_flash = 0
		
		if sel_flash == 0:
			$misc/select.show()
		
		if sel_flash == 8:
			$misc/select.hide()
		
		#Select the appropriate mugshot.
		$misc/select.position.x = 48 + (80 * select.x)
		$misc/select.position.y = 56 + (64 * select.y)
	
	#Make the screen flash upon selecting a stage.
	if menu == 2:
		big_flash += 1
		bf_time -= 1
		
		if big_flash > 5:
			big_flash = 0
		
		if big_flash == 0:
			$misc/flash.show()
		
		if big_flash == 3:
			$misc/flash.hide()
		
		if bf_time == 0:
			menu = 3
			$misc/flash.hide()
	
	#Fade the screen.
	if menu == 3:
		if begin_fade:
			begin_fade = false
			$fake_fade/action.interpolate_property($fake_fade, 'color', Color(0.0, 0.0, 0.0, 0.0), Color(0.0, 0.0, 0.0, 1.0), 0.125, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			$fake_fade/action.start()
					
	if menu == 6:
		#Make cursor flash
		sel_flash += 1
	
		if sel_flash > 17:
			sel_flash = 0
		
		if sel_flash == 0:
			$char_menu/chars/cursor1.show()
		
		if sel_flash == 8:
			$char_menu/chars/cursor1.hide()
		
		if c_menu == 0 and $char_menu/chars/cursor1.position != $char_menu/chars/rock.position:
			$char_menu/chars/cursor1.position = $char_menu/chars/rock.position
		if c_menu == 1 and $char_menu/chars/cursor1.position != $char_menu/chars/blues.position:
			$char_menu/chars/cursor1.position = $char_menu/chars/blues.position
		if c_menu == 2 and $char_menu/chars/cursor1.position != $char_menu/chars/bass.position:
			$char_menu/chars/cursor1.position = $char_menu/chars/bass.position
	
	if menu == 7:
		sel_flash += 1
	
		if sel_flash > 17:
			sel_flash = 0
		
		if sel_flash == 0:
			$char_menu/chars/cursor2.show()
		
		if sel_flash == 8:
			$char_menu/chars/cursor2.hide()
		
		if c_menu == 0 and $char_menu/chars/cursor2.position != $char_menu/chars/rock.position:
			$char_menu/chars/cursor2.position = $char_menu/chars/rock.position
		if c_menu == 1 and $char_menu/chars/cursor2.position != $char_menu/chars/blues.position:
			$char_menu/chars/cursor2.position = $char_menu/chars/blues.position
		if c_menu == 2 and $char_menu/chars/cursor2.position != $char_menu/chars/bass.position:
			$char_menu/chars/cursor2.position = $char_menu/chars/bass.position
		if c_menu == 3 and $char_menu/chars/cursor2.position != $char_menu/chars/ok.position:
			$char_menu/chars/cursor2.position = $char_menu/chars/ok.position
	
	if menu == 6 or menu == 7:
		$char_menu/chars/info.frame = c_menu
		
		if c_menu == 3:
			$char_menu/chars/info.hide()
		elif c_menu != 3 and !$char_menu/chars/info.is_visible():
			$char_menu/chars/info.show()
			
	
	if menu == 8:
		if final > -1:
			final -= 1
		
		if final == 0:
			$char_menu/chars.hide()
			$char_menu/leave.show()
			if char_ids == [0, 1] or char_ids == [1, 0]:
				$other_anim.play("leave0")
				$char_menu/leave/bass_leave.hide()
			if char_ids == [0, 2] or char_ids == [2, 0]:
				$other_anim.play("leave1")
				$char_menu/leave/blues_leave.hide()
			if char_ids == [1, 2] or char_ids == [2, 1]:
				$other_anim.play("leave2")
				$char_menu/leave/rock_leave.hide()
			if char_ids == [0, 3]:
				$other_anim.play("leave3")
				$char_menu/leave/blues_leave.hide()
				$char_menu/leave/bass_leave.hide()
			if char_ids == [1, 3]:
				$other_anim.play("leave4")
				$char_menu/leave/rock_leave.hide()
				$char_menu/leave/bass_leave.hide()
			if char_ids == [2, 3]:
				$other_anim.play("leave5")
				$char_menu/leave/rock_leave.hide()
				$char_menu/leave/blues_leave.hide()
			$char_menu/chars/info.hide()
			$char_menu/chars/top_text2.hide()
			$teleport.play()
	
	if menu == 9:
		$fade.state = 2
		$fade.end = true
		menu = 10
	
	if menu == 9 or 10:
		if rock_leave:
			$char_menu/leave/rock_leave.position.y -= 8
		if blues_leave:
			$char_menu/leave/blues_leave.position.y -= 8
		if bass_leave:
			$char_menu/leave/bass_leave.position.y -= 8
		

func _physics_process(delta):
	if menu == 4:
		
		tile_pos_a = $tiles.world_to_map($char_menu/char_sel_top.position)
		tile_pos_b = $tiles.world_to_map($char_menu/char_sel_bot.position)
		
		if !reverse:
			if $char_menu/char_sel_top.position.y < 116:
				$char_menu/char_sel_top.position.y += bar_spd * delta
				$char_menu/char_sel_bot.position.y += -bar_spd * delta
			
			if floor($char_menu/char_sel_top.position.y) == 116:
				reverse = true
		else:
			if $char_menu/char_sel_top.position.y > 84:
				$char_menu/char_sel_top.position.y += -bar_spd * delta
				$char_menu/char_sel_bot.position.y += bar_spd * delta
			
			for i in range(10, 15):
				if tile_pos_a.y == i:
					for i in range(0, 32):
						$tiles.set_cellv(Vector2(i, tile_pos_a.y), 48)
						$tiles.set_cellv(Vector2(i, tile_pos_b.y), 48)
			
			if $char_menu/char_sel_top.position.y <= 84:
				menu = 5
				$char_anim.play("appear")
				$char_menu/chars.show()
				
func _on_fadein():
	menu = 1

func _on_fadeout():
	if $fade.state == 1:
# warning-ignore:return_value_discarded
		get_tree().reload_current_scene()
	
	if $fade.state == 2:
		get_tree().change_scene("res://scenes/world.tscn")

func _on_tween_all_completed():
	#Hide original menu assets so the next can come on screen.
	$mugs.hide()
	$misc.hide()
	$tiles.clear()
	$fake_fade.hide()
	menu = 4

func _on_anim_finished(anim_name):
	
	if anim_name == "appear" and menu == 5:
		menu = 6
		$char_menu/chars/cursor1.show()
		sel_flash = 0

func _on_other_anim_finished(anim_name):
	if anim_name == "leave0" or "leave1" or "leave3":
		rock_leave = true
	if anim_name == "leave0" or "leave3" or "leave4":
		blues_leave = true
	if anim_name == "leave1" or "leave2" or "leave5":
		bass_leave = true
	menu = 9
