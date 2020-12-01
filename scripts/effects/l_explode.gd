extends Node2D

onready var world = get_parent().get_parent()

func _ready():
	if world.name == "world":
		world.sound("big_explode")
	$anim.play("anim")

# warning-ignore:unused_argument
func _on_anim_finished(anim_name):
	queue_free()
