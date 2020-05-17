extends Node2D

var open = false
var closed = false

func _on_anim_finished(anim_name):
	match anim_name:
		"opening":
			if !open:
				open = true
			else:
				closed = true
