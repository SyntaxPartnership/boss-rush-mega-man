extends KinematicBody2D

onready var world = get_parent().get_parent().get_parent()
onready var tango = world.get_child(1).get_child(1).get_child(3).get_child(2).get_child(0)
onready var player = world.get_child(2)

onready var offset_x = $sprite.offset.x

const GRAVITY = 900

var velocity = Vector2()

var state = 0

var wiggle = 0
var wiggle_time = 120

# Called when the node enters the scene tree for the first time.
func _ready():
	$anim.play("fall")
	velocity.y = 0

func _physics_process(delta):
	
	if state == 1:
		wiggle -= 1
		wiggle_time -= 1
		
		if wiggle == 0:
			tango.play('idle')
			if $sprite.offset.x == 0:
				$sprite.offset.x = -1
				wiggle = 2
			elif $sprite.offset.x == -1:
				$sprite.offset.x = 1
				wiggle = 2
			elif $sprite.offset.x == 1:
				$sprite.offset.x = 0
				wiggle = 40
		
		if wiggle_time == 0:
			audio.play_sound("bounce")
			$anim.play("jump")
			velocity.y = -310
			state = 2
		
	
	velocity.y += GRAVITY * delta
	
	if velocity.y > 500:
		velocity.y = 500
	
	velocity = move_and_slide(velocity, Vector2(0, -1))
	
	if is_on_floor():
		match state:
			0:
				audio.play_sound("faceplant")
				tango.play("startle")
				player.anim_state(player.IDLE)
				$anim.play("faceplant")
				wiggle = 60
				state = 1
			2:
				$anim.play("intro")
				state = 3

	if global.scene >= 5:
		if global.sub_scene != 43:
			if world.scene_txt.get(global.sub_scene)[0] == "AUTO:" and $anim.get_current_animation() != "talk":
				$anim.play("talk")
			
			if world.scene_txt.get(global.sub_scene)[0] != "AUTO:" and $anim.get_current_animation() != "idle":
				$anim.play("idle")
		else:
			if $anim.get_current_animation() != "panic":
				$anim.play("panic")

func _on_anim_finished(anim_name):
	if anim_name == "intro":
		audio.play_music("auto-intro")
		world.spawn_eddie = 1
