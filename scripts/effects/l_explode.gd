extends Node2D

onready var world = get_parent().get_parent()

func _ready():
	world.sound("big_explode")
	$anim.play("anim")

func _on_anim_finished(anim_name):
	queue_free()
