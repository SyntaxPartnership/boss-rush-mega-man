extends Node2D

onready var world = get_parent().get_parent()
onready var map = get_parent().get_parent().get_child(0).get_child(1)

var tile_pos
var overlap

func _ready():
	$anim.play('idle')

# warning-ignore:unused_argument
func _physics_process(delta):
	
	tile_pos = map.world_to_map(position)
	overlap = map.get_cellv(tile_pos)
	
	position.y -= 1
	
	#Kill the bubble if it is no longer overlapping water.
	if overlap != 6 and overlap != 7 and overlap != 12 and overlap != 13:
		world.bbl_count = 0
		queue_free()
	
	#Kill the bubble if it is no longer on screen.
	if not $on_screen.is_on_screen():
		world.bbl_count = 0
		queue_free()