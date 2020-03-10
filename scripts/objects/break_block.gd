extends Sprite

onready var world = get_parent().get_parent()

func _on_wpn_check_body_entered(body):
	if body.name == "roto_boost":
		world.sound('hit')
		var boom = load("res://scenes/effects/s_explode.tscn").instance()
		boom.global_position = global_position
		world.get_child(3).add_child(boom)
		queue_free()
