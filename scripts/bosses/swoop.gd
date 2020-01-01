extends KinematicBody2D

onready var world = get_parent().get_parent()
onready var camera = world.get_child(2).get_child(9)
onready var player = world.get_child(2)

var intro = true
var intro_delay = 30
var fill_bar = false

var up = false

var center = 0

var state = 0
var swoop = 0
var dives = 0
var bat = 0
var make_bat = false

var velocity = Vector2()

func _ready():
	$anim_wings.play("flap")
	
	if global_position.y > camera.limit_top + 96:
		up = true

func _physics_process(delta):
	
	#Boss intro dance
	if intro and !fill_bar:
		if global_position.y < camera.limit_top + 96 and !up:
			velocity.y = 200
		elif global_position.y > camera.limit_top + 96 and up:
			velocity.y = -200
		else:
			velocity.y = 0
			fill_bar = true
	
	if fill_bar:
		if intro_delay > 0:
			intro_delay -= 1
		
		if intro_delay == 1:
			$anim_body.play("intro")
			$box.disabled = false
	
	#Simulate the wings flapping.
	if $wings.frame < 3:
		$wings.offset.y = -$wings.frame
		$body.offset.y = -$wings.frame
	
	if !intro and !fill_bar:
		if state == 0:
			if is_on_wall():
				
				#Generate a random number:
				randomize()
				swoop = floor(rand_range(0, 10))
				
				var bat_num = get_tree().get_nodes_in_group("bats")
				
				if bat_num.size() < 4:
					bat = floor(rand_range(16, 128))
				
				if swoop <= 3:
					state = 1
					$anim_body.play("down")
					$anim_wings.play("idle")
					$wings.hide()
					velocity.y = 400
				
				if $body.flip_h:
					$body.flip_h = false
					$wings.flip_h = false
				else:
					$body.flip_h = true
					$wings.flip_h = true
				$bat_spawn.position.x = -$bat_spawn.position.x

			if $body.flip_h:
				velocity.x = 90
			else:
				velocity.x = -90
			
			#When the bat timer reaches a certain point, spawn a bat.
			if bat > 0:
				bat -= 1
			
			if bat == 1:
				state = 2
				velocity.x = 0
				$anim_body.play("kiss")
		
		if state == 1:
			
			if $body.flip_h:
				velocity.x = 120
			else:
				velocity.x = -120
			
			if velocity.y > -350:
				velocity.y -= 900 * delta
			
			if velocity.y < 0 and velocity.y >= -10:
				$anim_body.play("up")
			
			if global_position.y < camera.limit_top + 96:
				if dives < 1:
					velocity.y = 400
					$anim_body.play("down")
					dives += 1
				else:
					velocity.y = 0
					global_position.y = camera.limit_top + 96
					$anim_body.play("idle")
					$anim_wings.play("flap")
					$wings.show()
					state = 0
					dives = 0
		
		if state == 2:
			if $body.frame == 2 and !make_bat:
				var bat = load("res://scenes/bosses/bat.tscn").instance()
				bat.global_position = $bat_spawn.global_position
				world.get_child(1).add_child(bat)
				if $body.flip_h:
					bat.start = 0
				else:
					bat.start = 1
				make_bat = true

	velocity = move_and_slide(velocity, Vector2(0, -1))

func _on_body_anim_finished(anim_name):
	if anim_name == "intro":
		world.fill_b_meter = true
	
	if anim_name == "kiss":
		make_bat = false
		if $body.flip_h:
			velocity.x = 90
		else:
			velocity.x = -90
		$anim_body.play("idle")
		state = 0

func play_anim(anim):
	$anim_body.play(anim)