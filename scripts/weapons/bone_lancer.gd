extends KinematicBody2D

onready var world = get_parent().get_parent()
onready var player = world.get_child(2)
onready var p_sprite = player.get_child(3)
onready var pos = player.get_child(3).get_child(1)

var length = 0
var retract = false
var wall = false
var dir = false
var kill_chain = 1

var damage = 40

func _ready():
	$anim.play("idle")
	world.sound("b_lancer")
	
	if p_sprite.flip_h or player.ladder_dir == -1:
		$main/drill.flip_h = true
		$main/drill.position.x = -5
		$box.position.x = -5
		$wall_det.position.x = -5
		
		for c in $sub.get_children():
			c.flip_h = true
			c.position.x = -c.position.x
		
		dir = true
	
	player.b_lancer = true

# warning-ignore:unused_argument
func _process(delta):
	
	if !wall:
		if !retract:
			if length < 8:
				if !dir:
					$main/drill.position.x += 8
					$box.position.x += 8
					$wall_det.position.x += 8
				else:
					$main/drill.position.x -= 8
					$box.position.x -= 8
					$wall_det.position.x -= 8
				
				length += 1
				
				for c in $sub.get_children():
					if c.name == "chain0"+str(length):
						c.show()
			
			if length == 8:
				retract = true
		else:
			if length > 0:
				if !dir:
					$main/drill.position.x -= 8
					$box.position.x -= 8
					$wall_det.position.x -= 8
				else:
					$main/drill.position.x += 8
					$box.position.x -= 8
					$wall_det.position.x += 8
				
				for c in $sub.get_children():
					if c.name == "chain0"+str(length):
						c.hide()
				
				length -= 1
				
		if length == 0:
			player.b_lancer = false
			queue_free()
		
		position = pos.global_position
	
	else:
		
		if length > 0:
				
			for c in $sub.get_children():
				if c.name == "chain0"+str(kill_chain):
					c.hide()
			
			kill_chain += 1
			
			if !player.is_on_wall():
				if !player.wall:
					if !p_sprite.flip_h:
						player.position.x += 8
					else:
						player.position.x -= 8
				length -= 1
	
		if length == 0 or player.wall:
			player.b_lancer = false
			player.b_lance_pull = false
			queue_free()

# warning-ignore:unused_argument
func _on_wall_det_body_entered(body):
	$anim.stop()
	player.b_lance_pull = true
	wall = true
