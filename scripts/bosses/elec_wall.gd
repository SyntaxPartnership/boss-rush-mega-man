extends Node2D

onready var world = get_parent().get_parent().get_parent()
onready var player = world.get_child(2)
onready var camera = player.get_child(9)

func _ready():
	$anim_a.play("idle")
	$anim_b.play("idle")
