extends Node2D

const ROCK_NORM = preload('res://assets/sprites/player/mega-norm.png')
const ROCK_THROW = preload('res://assets/sprites/player/mega-throw.png')
const BLUES_NORM = preload('res://assets/sprites/player/proto-norm-shld.png')
const BLUES_THROW = preload('res://assets/sprites/player/proto-throw-shld.png')
const FORTE_NORM = preload('res://assets/sprites/player/bass-norm.png')
const FORTE_THROW = preload('res://assets/sprites/player/bass-throw.png')

const RUN_SPEED = 90
const JUMP_SPEED = -310
const GRAVITY = 900

var x_dir = 0
var state = 0
var act_timer = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	match global.player:
		0:
			$demo_plyr/sprite.texture = ROCK_NORM
		1:
			$demo_plyr/sprite.texture = BLUES_NORM
		2:
			$demo_plyr/sprite.texture = FORTE_NORM

func _process(delta):
	match state:
		1:
			audio.play_sound("appear")
			$anim.play("teleport")
			$sprite.show()
			state += 1

func _on_anim_done(anim_name):
	pass
