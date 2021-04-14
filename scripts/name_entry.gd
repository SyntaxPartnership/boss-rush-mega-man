extends Node2D

var allow_ctrl = false
var check = false
var no_no = false
var cursor_start = Vector2()
var menu_pos = Vector2(0, 0)
var new_pos = Vector2(0, 0)

var name_arr = []
var plyr_name = ""
var text_cooldwn = 0

var letters = {
	"(0, 0)" : "A",
	"(1, 0)" : "B",
	"(2, 0)" : "C",
	"(3, 0)" : "D",
	"(4, 0)" : "E",
	"(5, 0)" : "F",
	"(6, 0)" : "G",
	"(7, 0)" : "H",
	"(8, 0)" : "I",
	"(9, 0)" : "J",
	"(10, 0)" : "K",
	"(11, 0)" : "L",
	"(12, 0)" : "M",
	"(0, 1)" : "N",
	"(1, 1)" : "O",
	"(2, 1)" : "P",
	"(3, 1)" : "Q",
	"(4, 1)" : "R",
	"(5, 1)" : "S",
	"(6, 1)" : "T",
	"(7, 1)" : "U",
	"(8, 1)" : "V",
	"(9, 1)" : "W",
	"(10, 1)" : "X",
	"(11, 1)" : "Y",
	"(12, 1)" : "Z",
	"(0, 2)" : "0",
	"(1, 2)" : "1",
	"(2, 2)" : "2",
	"(3, 2)" : "3",
	"(4, 2)" : "4",
	"(5, 2)" : "5",
	"(6, 2)" : "6",
	"(7, 2)" : "7",
	"(8, 2)" : "8",
	"(9, 2)" : "9",
	"(10, 2)" : "!",
	"(11, 2)" : "?",
	"(12, 2)" : ".",
	"(0, 3)" : "@",
	"(1, 3)" : "#",
	"(2, 3)" : "$",
	"(3, 3)" : "%",
	"(4, 3)" : "&",
	"(5, 3)" : "-",
	"(6, 3)" : "_",
	"(7, 3)" : "(",
	"(8, 3)" : ")",
	"(9, 3)" : " "
}

var nono_words = [
	"ASS",
	"SHIT",
	"PISS",
	"BITCH",
]

func _ready():
	cursor_start = $cursor.position
	audio.play_music("menu")

func _input(event):
	
	if allow_ctrl and check:
		if Input.is_action_just_pressed("jump") or Input.is_action_just_pressed("start"):
			audio.play_sound("1up")
			$bottom.set_text("OKAY!!!")
			text_cooldwn = 120
			allow_ctrl = false
		if Input.is_action_just_pressed("fire"):
			audio.play_sound("dink")
			check = false
	
	if allow_ctrl and !check:
		if name_arr.size() < 20:
			if Input.is_action_just_pressed("up"):
				menu_pos.y -= 1
				if no_no:
					no_no = false
			if Input.is_action_just_pressed("down"):
				menu_pos.y += 1
				if no_no:
					no_no = false
				if menu_pos.y == 3 and menu_pos.x > 9:
					menu_pos.x = 12
			if Input.is_action_just_pressed("left"):
				menu_pos.x -= 1
				if no_no:
					no_no = false
				if menu_pos.y == 3 and menu_pos.x > 9:
					menu_pos.x = 9
			if Input.is_action_just_pressed("right"):
				menu_pos.x += 1
				if no_no:
					no_no = false
				if menu_pos.y == 3 and menu_pos.x > 9 and menu_pos.x < 13:
					menu_pos.x = 12
		
			if menu_pos.x < 0:
				menu_pos.x = 12
			elif menu_pos.x > 12:
				menu_pos.x = 0
			
			if menu_pos.y < 0:
				menu_pos.y = 3
			elif menu_pos.y > 3:
				menu_pos.y = 0
			
		if Input.is_action_just_pressed("jump") or Input.is_action_just_pressed("start"):
			if menu_pos != Vector2(12, 3):
				if !Input.is_action_just_pressed("start"):
					audio.play_sound("select")
					if name_arr.size() < 20:
						name_arr.append(letters[str(menu_pos)])
						display_name("add")
			else:
				for n in nono_words.size():
					if name_arr.size() == 0:
						no_no = true
						audio.play_sound("error")
						$bottom.set_text("ERROR!!!")
						text_cooldwn = 120
					if nono_words[n] in plyr_name:
						no_no = true
						audio.play_sound("error")
						$bottom.set_text("NOT ALLOWED!!!")
						text_cooldwn = 120
				if !no_no:
					audio.play_sound("select")
					$bottom.set_text("DONE? YES(JUMP) / NO(FIRE)")
					check = true
						
		if Input.is_action_just_pressed("fire"):
			if name_arr.size() > 0:
				audio.play_sound("dink")
				name_arr.remove(name_arr.size()-1)
				display_name("sub")
		
		if Input.is_action_just_pressed("start"):
			if menu_pos != Vector2(12, 3):
				menu_pos = Vector2(12, 3)

func _process(delta):
	
	if name_arr.size() == 20 and menu_pos != Vector2(12, 3):
		menu_pos = Vector2(12, 3)
	
	if new_pos != menu_pos:
		audio.play_sound("cursor")
		var sub
		if menu_pos.x == 12 and menu_pos.y == 3:
			$cursor.frame = 1
			sub = 8
		else:
			$cursor.frame = 0
			sub = 0
		$cursor.position = cursor_start + (menu_pos * Vector2(16, 16))
		$cursor.position.x = $cursor.position.x - sub
		new_pos = menu_pos
	
	if text_cooldwn > 0:
		text_cooldwn -= 1
	else:
		if $bottom.get_text() != "" and !check:
			$bottom.set_text("")
	
	if audio.last_sound != null and audio.last_sound.name == "1up" and !audio.last_sound.is_playing():
		audio.stop_sound("1up")
		$fade.state = 1
		$fade.set("end", true)

func display_name(add_sub):
	plyr_name = ""
	match add_sub:
		"add":
			for c in name_arr.size():
				plyr_name += name_arr[c]
		"sub":
			for c in name_arr.size():
				plyr_name += name_arr[c]
	
	$name.set_text(plyr_name)

func _on_fadein():
	$cursor.show()
	allow_ctrl = true

func _on_fadeout():
	get_tree().change_scene("res://scenes/char_select.tscn")
