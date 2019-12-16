extends Label

signal start

var flash = false
var timer = 180
var blink = 0

# warning-ignore:unused_argument
func _process(delta):
	
	if flash and timer > 0:
		blink += 1
		timer -= 1
		
		if blink > 13:
			blink = 0
		
		if blink == 0:
			show()
		elif blink == 6:
			hide()
	elif flash and timer <= 0:
		emit_signal("start")
		queue_free()

func _on_fade_fadein():
	flash = true
	show()