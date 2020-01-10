extends Node2D

var menu = 0
var c_menu = 0
var select = Vector2(0, 0)
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
	"(0, 0)" : [0, 1],
	"(1, 0)" : [1, 1],
	"(0, 1)" : [2, 1],
	"(1, 1)" : [3, 1],
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
		if Input.is_action_just_pressed("right") and select.x < 1:
			select.x += 1
			sel_flash = 0
			$misc/select.show()
			$cursor.play()
		if Input.is_action_just_pressed("up") and select.y > 0:
			select.y -= 1
			sel_flash = 0
			$misc/select.show()
			$cursor.play()
		if Input.is_action_just_pressed("down") and select.y < 1:
			select.y += 1
			sel_flash = 0
			$misc/select.show()
			$cursor.play()
		
		if Input.is_action_just_pressed("jump") or Input.is_action_just_pressed("start") and !pressed:
			$misc/select.hide()
			$misc/flash.show()
			$bling.play()
			pressed = true
			global.level_id = lvl_ids.get(str(select))[0]
			global.boss_num = lvl_ids.get(str(select))[1]
			menu = 2
		
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
		$misc/select.position.x = 48 + (160 * select.x)
		$misc/select.position.y = 56 + (128 * select.y)
	
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
			$fade.state = 2
			$fade.end = true
		

func _on_fadein():
	menu = 1

func _on_fadeout():
	
	if $fade.state == 2:
		get_tree().change_scene("res://scenes/world.tscn")
