extends Node2D

onready var world = get_parent().get_parent()
onready var player = world.get_child(2)

var overlap = []

var damage = 60

func _ready():
	$anim.play("boom")

func _physics_process(_delta):
	overlap = $hit_box.get_overlapping_bodies()
	if overlap != []:
		for body in overlap:
			if body.name == "player":
				world.calc_damage(player, self)
#				if player.hurt_timer == 0 and player.blink_timer == 0 and !player.hurt_swap:
#					global.player_life[int(player.swap)] -= damage
#					player.damage()

func _on_anim_finished(_anim_name):
	queue_free()
