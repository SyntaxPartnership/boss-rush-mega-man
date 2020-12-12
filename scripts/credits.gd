extends Node2D

const CENTER = Vector2(128, 120)
const STAR = preload("res://scenes/effects/star.tscn")

var star_spawn = 3

var begin = false

func _ready():
	return

func _input(event):
	
	if Input.is_action_just_pressed("start"):
		if !begin:
			$music.play()
			$scroll.interpolate_property($cam, "position", Vector2(128, 120), Vector2(128, 1680), 172.72)
			$scroll.start()
			begin = true

func _physics_process(delta):
	
#	print($music.is_playing(),', ',$cam.position,', ',begin)
	
	if begin: 
		$text/cam.position.y += 0.25
		
		star_spawn -= 1
		
		if star_spawn == 0:
			var new = STAR.instance()
			new.position.x = int(round(rand_range(96, 160)))
			new.position.y = int(round(rand_range(88, 152)))
			if new.position == CENTER:
				new.queue_free()
			new.angle = (CENTER - new.position).normalized()
			$starfield.add_child(new)
			star_spawn = 3
