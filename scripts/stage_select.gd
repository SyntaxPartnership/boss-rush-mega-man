extends Node2D

var cur_start = Vector2()
var cur_pos = Vector2(0, 0)

var start = false

var flash = 0
var f_delay = 0

var move_state = 0
var move_delay = 0

var half_move = 0
var tile_pos = []
var prev_tpos = []
var sprite_mve = false
var x_spd = 0

var velocity = Vector2()
var spin_toss = Vector2(0, 0)
const GRAVITY = 900

var stage_id = {
	Vector2(0, 0) : 0,
	Vector2(1, 0) : 1,
	Vector2(0, 1) : 2,
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
				$stage_sel/halves/boss_sprite/move/wings.flip_h = true
				$stage_sel/halves/boss_sprite/move/boss.flip_h = true
			
			#Choose the appropriate sprite.
			$stage_sel/halves/boss_sprite/move/anim.play(str(cur_pos.x)+"-"+str(cur_pos.y)+"-idle")
			
			$stage_sel/halves/boss_sprite.show()
			if cur_pos == Vector2(0, 0):
				$stage_sel/halves/boss_sprite/move/wings.show()
			$door.play()
			$stage_sel/halves/door/anim.play_backwards("open_close")
			move_state = 2
	
	if move_state == 2:
		if move_delay > 0:
			move_delay -= 1
		
		if move_delay == 1:
			$music.stop()
			$start.play()
			
			$stage_sel/halves/boss_sprite/move/anim.play(str(cur_pos.x)+"-"+str(cur_pos.y)+"-jump")
			if cur_pos == Vector2(0, 0):
				$stage_sel/halves/boss_sprite/move/wings.hide()
				
			match cur_pos:
				Vector2(0, 0):
					x_spd = 1.7
					velocity.y = -200
					$stage_sel/name.set_text(" SWOOP  WOMAN")
				Vector2(1, 0):
					x_spd = -1.7
					velocity.y = -200
					$stage_sel/name.set_text("   ROTO MAN")
				Vector2(0, 1):
					x_spd = 1.7
					velocity.y = -405
					$stage_sel/name.set_text("SCUTTLE  WOMAN")
				Vector2(1, 1):
					x_spd = -1.7
					velocity.y = -405
					$stage_sel/name.set_text(" DEFEND WOMAN")
			
			sprite_mve = true
			move_state = 3
			move_delay = 64
			half_move = 1
	
	if sprite_mve:
		
		$stage_sel/halves/boss_sprite/move.global_position.x += x_spd
			
		velocity.y += GRAVITY * delta
		
		if velocity.y > 0:
			$stage_sel/halves/boss_sprite/move/anim.play(str(cur_pos.x)+"-"+str(cur_pos.y)+"-fall")
		
		velocity = $stage_sel/halves/boss_sprite/move.move_and_slide(velocity, Vector2(0, -1))
		
		if velocity.y > 0 and $stage_sel/halves/boss_sprite/move/boss.global_position.y >= 112:
			$stage_sel/halves/boss_sprite/move/boss.global_position = Vector2(128, 112)
			if cur_pos.x == 0:
				$stage_sel/halves/boss_sprite/move/boss.flip_h = false
				$stage_sel/halves/boss_sprite/move/wings.flip_h = false
			$stage_sel/halves/boss_sprite/move/anim.play(str(cur_pos.x)+"-"+str(cur_pos.y)+"-idle")
			if cur_pos == Vector2(0, 0):
				$stage_sel/halves/boss_sprite/move/wings.show()
				$stage_sel/halves/boss_sprite/move/anim_w.play("flap")
			sprite_mve = false
	
	if $stage_sel/halves/boss_sprite/move/anim_w.is_playing():
		$stage_sel/halves/boss_sprite/move/boss.offset.y = -$stage_sel/halves/boss_sprite/move/wings.get_frame()
		$stage_sel/halves/boss_sprite/move/wings.offset.y = -$stage_sel/halves/boss_sprite/move/wings.get_frame()
	
	if half_move == 1:
		if $stage_sel/halves/top.global_position.y > -52:
			$stage_sel/halves/top.global_position.y -= 2
			$stage_sel/halves/mug_01.global_position.y -= 2
			$stage_sel/halves/mug_02.global_position.y -= 2
			
			$stage_sel/halves/bottom.global_position.y += 2
			$stage_sel/halves/mug_03.global_position.y += 2
			$stage_sel/halves/mug_04.global_position.y += 2
		
		if $stage_sel/halves/top.global_position.y == -52:
			$stage_sel/halves/top.set_frame(2)
			$stage_sel/halves/bottom.set_frame(3)
			half_move = 2
	
	if half_move == 2:
		tile_pos = [$stage_sel/name_bar/map.world_to_map($stage_sel/halves/top.global_position), $stage_sel/name_bar/map.world_to_map($stage_sel/halves/bottom.global_position)]
		
		if prev_tpos != tile_pos:
			for t in range(0, 32):
				$stage_sel/name_bar/map.set_cellv(Vector2(t, tile_pos[0].y + 7), -1)
				$stage_sel/name_bar/map.set_cellv(Vector2(t, tile_pos[1].y - 7), -1)
		
		if $stage_sel/halves/top.global_position.y < 20:
			$stage_sel/halves/top.global_position.y += 2
			$stage_sel/halves/bottom.global_position.y -= 2
		
		if $stage_sel/halves/top.global_position.y == 20:
			move_delay -= 1
		
		if move_delay == 0:
			$stage_sel/halves/boss_sprite/move/anim.play(str(cur_pos.x)+"-"+str(cur_pos.y)+"-intro")
			half_move = 3
	
	if $stage_sel/halves/boss_sprite/move/anim.get_current_animation() == "0-1-intro" and $stage_sel/halves/boss_sprite/move/boss.get_frame() == 24:
		if !$stage_sel/halves/boss_sprite/move/spin.is_visible_in_tree():
			$stage_sel/halves/boss_sprite/move/anim_s.play("spin")
			$stage_sel/halves/boss_sprite/move/spin.show()
	
	if $stage_sel/halves/boss_sprite/move/boss.get_frame() == 25:
		$stage_sel/halves/boss_sprite/move/spin.offset.y = -1
	else:
		$stage_sel/halves/boss_sprite/move/spin.offset.y = 0
	
	if $stage_sel/halves/boss_sprite/move/boss.get_frame() == 27:
		if spin_toss == Vector2(0, 0):
			spin_toss = Vector2(4, -6)
	
	if spin_toss != Vector2(0, 0):
		$stage_sel/halves/boss_sprite/move/spin.global_position += spin_toss
		spin_toss.y += 0.45
	
	if move_state == 4:
		if $stage_sel/name.get_visible_characters() < $stage_sel/name.get_total_character_count():
			$stage_sel/name.set_visible_characters($stage_sel/name.get_visible_characters() + 1)

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
		global.level_id = stage_id.get(cur_pos)
		get_tree().change_scene("res://scenes/world.tscn")

func set_cursor():
	$cursor.play()
	$stage_sel/halves/cursor/anim.stop(true)
	$stage_sel/halves/cursor/anim.play("idle")
	$stage_sel/halves/cursor.position = cur_start + (cur_pos * Vector2(128, 128))
	$stage_sel/halves/door.position = $stage_sel/halves/cursor.position
	$stage_sel/halves/boss_sprite/move/boss.position = $stage_sel/halves/cursor.position
	$stage_sel/halves/boss_sprite/move/wings.position = $stage_sel/halves/cursor.position
	$stage_sel/halves/boss_sprite/move/spin.position.x = $stage_sel/halves/cursor.position.x - 13
	$stage_sel/halves/boss_sprite/move/spin.position.y = $stage_sel/halves/cursor.position.y - 21

func _on_door_finished(anim_name):
	if move_state == 1 or move_state == 2:
		move_delay = 32

func _on_intro_finished(anim_name):
	if anim_name == "0-0-intro" or anim_name == "1-0-intro" or anim_name == "0-1-intro" or anim_name == "1-1-intro":
		move_state = 4

func _on_start_finished():
	$fade.state = 1
	$fade.end = true
