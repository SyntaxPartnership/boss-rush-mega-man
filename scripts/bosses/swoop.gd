extends KinematicBody2D

onready var world = get_parent().get_parent()
onready var camera = world.get_child(2).get_child(9)
onready var player = world.get_child(2)

var intro = true
var intro_delay = 30
var fill_bar = false

var up = false

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
	
	#Simulate the wings flapping.
	$wings.offset.y = -$wings.frame
	$body.offset.y = -$wings.frame

	velocity = move_and_slide(velocity, Vector2(0, -1))

func _on_body_anim_finished(anim_name):
	if anim_name == "intro":
		world.fill_b_meter = true
