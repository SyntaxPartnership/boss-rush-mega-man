extends KinematicBody2D

onready var world = get_parent().get_parent()
onready var camera = world.get_child(2).get_child(9)
onready var player = world.get_child(2)

var velocity = Vector2()
var left_bar = 0
var right_bar = 0

func _ready():
	$anim.play("spin")
	
	left_bar = camera.limit_left + 40
	right_bar = camera.limit_right - 40

func _physics_process(delta):
	pass
