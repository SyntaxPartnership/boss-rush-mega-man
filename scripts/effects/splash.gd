extends Node2D

func _ready():
	$anim.play('splash')

func _on_anim_animation_finished(anim_name):
	if anim_name == 'splash':
		queue_free()