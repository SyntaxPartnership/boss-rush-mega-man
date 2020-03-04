extends Node2D

onready var world = get_parent().get_parent().get_parent()
onready var player = world.get_child(2)

func _ready():
	$anim.play("idle")

func _physics_process(delta):
	
	pass
