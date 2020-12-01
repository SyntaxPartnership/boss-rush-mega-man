extends Sprite

var sprite = 0
var f_delay = 3

func _process(delta):
	
	f_delay -= 1
	
	if f_delay < 0:
		sprite += 1
		f_delay = 3
	
	if sprite == 6:
		queue_free()
	
	if sprite != frame and sprite < 6:
		frame = sprite
