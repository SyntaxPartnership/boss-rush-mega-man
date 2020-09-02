extends Node2D

onready var world = get_parent().get_parent().get_parent()
onready var player = world.get_child(2)
onready var camera = player.get_child(9)

var damage = 60

var id = 9

var property = 100

var overlap = []

var reflect = false

func _ready():
	$anim_a.play("idle")
	$anim_b.play("idle")

func _physics_process(delta):
	
	overlap = $hit_box.get_overlapping_bodies()
	
	if overlap != []:
		for body in overlap:
			if body.name == 'player':
				if player.hurt_timer == 0 and player.blink_timer == 0 and !player.hurt_swap and !player.r_boost:
					if player.r_boost:
						player.r_boost = false
					global.player_life[int(player.swap)] -= damage
					player.damage()
			if body.is_in_group('boss'):
				if body.name == 'scuttle' and body.state != 12 and body.state != 19:
					world.calc_damage(body, self)
