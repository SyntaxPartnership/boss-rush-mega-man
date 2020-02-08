extends Node2D

var cur_start = Vector2()
var cur_pos = Vector2(0, 0)

var start = false

var flash = 0
var f_delay = 0

var move_state = 0
var move_delay = 0

const GRAVITY = 900

var stage_id = {
	Vector2(0, 0) : 0,
	Vector2(0, 1) : 1,
	Vector2(1, 0) : 2,
	Vector2(1, 1) : 3,
}

func _ready():
	$music.play()
	
	$stage_sel/halves/cursor/anim.play("idle")
	cur_start = $stage_sel/halves/cursor.position

func _input(_event):
	
	if start:
		if Input.is_action_just_pressed("right") and cur_pos.x != 1:
			cur_pos.x = 1
			set_cursor()
		
		if Input.is_action_just_pressed("left") and cur_pos.x != 0:
			cur_pos.x = 0
			set_cursor()
		
		if Input.is_action_just_pressed("up") and cur_pos.y != 0:
			cur_pos.y = 0
			set_cursor()
		
		if Input.is_action_just_pressed("down") and cur_pos.y != 1:
			cur_pos.y = 1
			set_cursor()
		
		if Input.is_action_just_pressed("jump"):
			start = false
			$bling.play()
			$stage_sel/halves/cursor.hide()
			$stage_sel/halves/flash.show()
			flash = 48

func _physics_process(delta):
	starfield()
	
	if flash > 0 and !start:
		if f_delay == 0:
			$stage_sel/halves/flash.show()
		
		if f_delay == 2:
			$stage_sel/halves/flash.hide()
		
		flash -= 1
		f_delay += 1
		
		if f_delay > 3:
			f_delay = 0
		
		if flash == 1:
			$door.play()
			$stage_sel/halves/door/anim.play("open_close")
			move_state = 1
	
	if move_state == 1:
		if move_delay > 0:
			move_delay -= 1
		
		if move_delay == 1:
			#Blank out mugshot
			for m in get_tree().get_nodes_in_group("mug"):
				if m.global_position == $stage_sel/halves/cursor.global_position:
					m.set_frame(0)
			
			#Face the boss towards the middle of the screen
			if cur_pos.x == 0:
				$stage_sel/halves/boss_sprite/wings.flip_h = true
				$stage_sel/halves/boss_sprite/boss.flip_h = true
			
			#Choose the appropriate sprite.
			$stage_sel/halves/boss_sprite/anim.play(str(cur_pos.x)+"-"+str(cur_pos.y)+"-idle")
			
			$stage_sel/halves/boss_sprite.show()
			if cur_pos == Vector2(0, 0):
				$stage_sel/halves/boss_sprite/wings.show()
			$door.play()
			$stage_sel/halves/door/anim.play_backwards("open_close")
			move_state = 2
	
	if move_state == 2:
		if move_delay > 0:
			move_delay -= 1
		
		if move_delay == 1:
			$music.stop()
			$start.play()
			
			$stage_sel/halves/boss_sprite/anim.play(str(cur_pos.x)+"-"+str(cur_pos.y)+"-jump")
			if cur_pos == Vector2(0, 0):
				$stage_sel/halves/boss_sprite/wings.hide()
			

func starfield():
	#Star Layer 1.
	for a in $starfield/layer1.get_children():
		a.global_position += Vector2(-4, 4)
		
		if a.global_position.x < 0:
			a.global_position.x = 260
		if a.global_position.y > 240:
			a.global_position.y = -4
	
	#Star Layer 2.
	for b in $starfield/layer2.get_children():
		b.global_position += Vector2(-3, 3)
		
		if b.global_position.x < 0:
			b.global_position.x = 259
		if b.global_position.y > 240:
			b.global_position.y = -3
	
	#Star Layer 3.
	for c in $starfield/layer3.get_children():
		c.global_position += Vector2(-2, 2)
	
		if c.global_position.x < 0:
			c.global_position.x = 258
		if c.global_position.y > 240:
			c.global_position.y = -2

func _on_fadein():
	start = true

func _on_fadeout():
	if $fade.state == 1:
		get_tree().change_scene("res://scenes/world.tscn")

func set_cursor():
	$cursor.play()
	$stage_sel/halves/cursor/anim.stop(true)
	$stage_sel/halves/cursor/anim.play("idle")
	$stage_sel/halves/cursor.position = cur_start + (cur_pos * Vector2(128, 128))
	$stage_sel/halves/door.position = $stage_sel/halves/cursor.position
	$stage_sel/halves/boss_sprite/boss.position  = $stage_sel/halves/cursor.position
	$stage_sel/halves/boss_sprite/wings.position  = $stage_sel/halves/cursor.position

func _on_door_finished(anim_name):
	if move_state == 1 or move_state == 2:
		move_delay = 32
