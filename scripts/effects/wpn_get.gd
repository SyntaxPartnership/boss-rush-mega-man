extends Node2D

#Add GameEndeavor to special thanks.
onready var world = get_parent().get_parent()

var radius # Distance on the x and y axis to orbit around the controller
var rotation_duration := 1.0 # How many seconds it takes for one platform to complete one rotation

var dist = 192

var effect = 0

var pews = [] # References to the platforms that will orbit controller
var orbit_angle_offset = 0 # Angle that first platform will orbit around controller

var absorb = 0

func _ready():
	$anim.play('anim')
	audio.play_sound("wpn_get")
	#update list.
	for child in self.get_children():
		if child.is_in_group("pew"):
			pews.append(child)

func _physics_process(delta):
	if absorb < 6:
		dist -= 6
		effect += 1
		
		if dist == 0:
			if absorb < 5:
				audio.play_sound("wpn_get")
			absorb += 1
			dist = 192
		
		if effect == 4:
			for e in pews:
				var boom = load('res://scenes/effects/s_explode.tscn').instance()
				world.get_child(3).add_child(boom)
				boom.global_position = e.global_position
			effect = 0
	
	radius = Vector2.ONE * dist
	orbit_angle_offset -= 2 * PI * delta / float(rotation_duration)
	orbit_angle_offset = wrapf(orbit_angle_offset, -PI, PI)
	update_pews()
	
	if absorb == 6:
		world.end_state = 4
		queue_free()

func update_pews():
	if !is_visible():
		show()
	
	if pews.size() != 0:
		var spacing = 2 * PI / float(pews.size())
		for i in pews.size():
			var new_position = Vector2()
			new_position.x = cos(spacing * i + orbit_angle_offset) * radius.x
			new_position.y = sin(spacing * i + orbit_angle_offset) * radius.y
			pews[i].position = new_position
