extends KinematicBody2D

onready var world = get_parent().get_parent().get_parent()
onready var camera = world.get_child(2).get_child(9)
onready var player = world.get_child(2)

var boom_time = 300
var kick_time = 40
var dist = 0
var fly = false
var kick = false
var up = false
var y_offset = 0

func _ready():
	$anim.play("idle")

func _physics_process(delta):
	
	#Boom_time and kick_time are always subtracted.
	if boom_time > 0:
		boom_time -= 1
		
	if kick and kick_time > 0:
		kick_time -= 1
	
	#Get distance to player.
	dist = player.global_position.distance_to(global_position)
	
	#If the player is close enough, trigger kick action.
	if dist <= 30 and !kick:
		$anim.play("idle2")
		kick = true
	
	if kick_time == 0 and !fly:
		if dist <= 30:
			$anim.play("kick")
		kick_time = 40
	
	if boom_time == 0 and !fly:
		$anim.play("float")
		boom_time = 300
		fly = true
	
	if boom_time == 0 and fly:
		#Spawn explosion sprite.
		var boom = load("res://scenes/effects/l_explode.tscn").instance()
		boom.global_position = global_position
		world.get_child(3).add_child(boom)
		queue_free()
	
	if fly:
		if !up:
			if y_offset < 4:
				y_offset += 0.2
			else:
				up = true
		else:
			if y_offset > -4:
				y_offset -= 0.2
			else:
				up = false
		
		if position.y > camera.limit_top + 120:
			position.y -= 0.5
		
		$sprite.offset.y = y_offset

func _on_anim_finished(anim_name):
	if anim_name == "kick":
		$anim.play("idle2")
