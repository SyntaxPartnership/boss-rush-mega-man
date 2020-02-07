extends Node2D

func _ready():
	$anim.play("boom")

func _on_anim_finished(anim_name):
	queue_free()
