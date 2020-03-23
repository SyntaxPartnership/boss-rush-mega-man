extends Node2D

onready var world = get_parent().get_parent()
onready var player = world.get_child(2)
onready var camera = player.get_child(9)

const SPEED = 5

var dir = Vector2(0, -1)

var turn_delay = 40

func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	turn_delay -= 1