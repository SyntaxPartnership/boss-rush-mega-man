extends KinematicBody2D

onready var world = get_parent().get_parent().get_parent()
onready var tiles = world.get_child(0).get_child(1)
onready var player = world.get_child(2)

var reverse = false
var x_spd
var velocity = Vector2(0, 0)

var time = 120
var chrg_time = 60
var fire_time = 120

var touch = false
var damage = 0

func _ready():
	
	$anim.play("idle")
	
	for top in (16):
		var tile_pos = tiles.world_to_map(position)
		var overlap = tiles.get_cellv(Vector2(tile_pos.x, tile_pos.y - top))
		
		if overlap == -1:
			$box_top.position.y -= 16
			$sprite_top.position.y -= 16
			$detectors/top_left.position.y -= 16
			$detectors/top_right.position.y -= 16
			$idle_hitbox/top.position.y -= 16
		else:
			$box_top.position.y += 16
			$sprite_top.position.y += 16
			$detectors/top_left.position.y += 16
			$detectors/top_right.position.y += 16
			$idle_hitbox/top.position.y += 16
			$fire_hitbox.position.y = ($box_top.position.y + 2) / 2
			
			var l_size = $box_bottom.position.distance_to($box_top.position) / 2
			
			var collision = CollisionShape2D.new()
			$fire_hitbox.add_child(collision)
			var shape = RectangleShape2D.new()
			shape.extents = Vector2(6, l_size)
			collision.shape = shape
			collision.disabled = true
			
			var lasers = ((-($box_top.position.y + 2) / 16) * 2) - 1
			
			for l in lasers:
				var beam = load('res://scenes/enemies/g_laser_vert.tscn').instance()
				$laser.add_child(beam)
				beam.global_position.x = position.x
				beam.global_position.y = position.y - (8 * (l + 1))
				beam.get_child(1).play('idle')
			return

func _physics_process(delta):
	
	var anim_pos = $anim.get_current_animation_position()
	
	if time > -1:
		time -= 1
	
	if time == 0:
		$anim.play("charge")
		$anim.seek(anim_pos)
		
	if time <= 0 and chrg_time > -1:
		chrg_time -= 1
	
	if chrg_time == 0:
		var collision = $fire_hitbox.get_child(0)
		collision.disabled = false
		
		$anim.play("fire")
		$anim.seek(anim_pos)
		$laser.show()
	
	if chrg_time == -1 and fire_time > 0:
		fire_time -= 1
	
	if fire_time == 0:
		var collision = $fire_hitbox.get_child(0)
		collision.disabled = true
		$laser.hide()
		time = 120
		chrg_time = 60
		fire_time = 120
		$anim.play("idle")
		$anim.seek(anim_pos)
		
	
	if !reverse:
		x_spd = -25
	else:
		x_spd = 25
	
	velocity.x = x_spd
	
	velocity = move_and_slide(velocity, Vector2(0, -1))
	
	var top_left = $detectors/top_left.get_overlapping_bodies()
	var top_right = $detectors/top_right.get_overlapping_bodies()
	var bottom_left = $detectors/bottom_left.get_overlapping_bodies()
	var bottom_right = $detectors/bottom_right.get_overlapping_bodies()
	
	if is_on_wall():
		if !reverse:
			reverse = true
		else:
			reverse = false
	
	if top_left == [] and !reverse or bottom_left == [] and !reverse:
		reverse = true
	
	if top_right == [] and reverse or bottom_right == [] and reverse:
		reverse = false
	
	if touch and player.hurt_timer == 0 and player.blink_timer == 0 and !player.hurt_swap:
		global.player_life[int(player.swap)] -= damage
		player.damage()
	
	if $idle_hitbox.get_overlapping_bodies() == [] and $fire_hitbox.get_overlapping_bodies() == []:
		touch = false

func _on_fire_hitbox_entered(body):
	if body.name == 'player':
		touch = true
		damage = 60

func _on_idle_hitbox_entered(body):
	if body.name == 'player':
		touch = true
		damage = 20