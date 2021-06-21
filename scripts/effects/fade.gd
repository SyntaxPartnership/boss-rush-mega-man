extends Node2D

signal fadein
signal fadeout

var begin = true
var end = false
# warning-ignore:unused_class_variable
var fade_out = false
var state = 0
# warning-ignore:unused_class_variable
var complete = false

# warning-ignore:unused_argument
func _process(delta):
	
	if begin:
		begin = false
		$fade_fade.interpolate_property($fade_mask, 'modulate', Color(1.0, 1.0, 1.0, 1.0), Color(1.0, 1.0, 1.0, 0.0), 0.125, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		$fade_fade.start()
	
	#Modify for state value.
	if end:
		end = false
		$fade_fade.interpolate_property($fade_mask, 'modulate', Color(1.0, 1.0, 1.0, 0.0), Color(1.0, 1.0, 1.0, 1.0), 0.125, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		$fade_fade.start()

# warning-ignore:unused_argument
# warning-ignore:unused_argument
func _on_fade_fade_tween_completed(object, key):
	if state == 0 or state == 3 or state == 7 or state == 9 or state == 11:
		emit_signal("fadein")
	if state == 1 or state == 2 or state == 4 or state == 6 or state == 8 or state == 10 or state == 12:
		emit_signal("fadeout")

