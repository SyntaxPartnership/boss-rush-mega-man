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
var bat = 0

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
				swoop = floor(rand_range(0, 5))
				
				if $body.flip_h:
					$body.flip_h = false
					$wings.flip_h = false
				else:
					$body.flip_h = true
					$wings.flip_h = true
				$bat_spawn.position.x = -$bat_spawn.position.x
				print($bat_spawn.position.x)
			if $body.flip_h:
				velocity.x = 90
			else:
				velocity.x = -90

	velocity = move_and_slide(velocity, Vector2(0, -1))

func _on_body_anim_finished(anim_name):
	if anim_name == "intro":
		world.fill_b_meter = true

func play_anim(anim):
	$anim_body.play(anim)