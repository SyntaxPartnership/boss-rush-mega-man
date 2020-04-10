extends KinematicBody2D


var thrst_pos = {
	0 : Vector2(-1, 22),
	1 : Vector2(1, 22),
	2 : Vector2(0, 22),
	3 : Vector2(1, 22),
	4 : Vector2(19, 2),
	5 : Vector2(-19, 2),
}


# Called when the node enters the scene tree for the first time.
func _ready():
	$anim.play("fade_in")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_anim_finished(anim_name):
	match anim_name:
		"fade_in":
			pass
