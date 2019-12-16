extends Node2D

onready var world = get_parent().get_parent()
onready var player = world.get_child(2)

var appear = false

func _ready():
	$anim.play('beam')
	
	#Set palettes
	$sprite.material.set_shader_param('t_col1', global.t_color1)
	$sprite.material.set_shader_param('t_col2', global.t_color2)
	$sprite.material.set_shader_param('t_col3', global.t_color3)
	$sprite.material.set_shader_param('t_col4', global.t_color4)
	
	$sprite.material.set_shader_param('r_col1', world.palette[0])
	$sprite.material.set_shader_param('r_col2', world.palette[1])
	$sprite.material.set_shader_param('r_col3', world.palette[2])
	#Set transparent pixels.
	$sprite.material.set_shader_param('trans', global.trans)

func _process(delta):
	
	#Move the sprite into position.
	if position.y < player.position.y:
		position.y += 8
	
	if position.y >= player.position.y and !appear:
		$anim.play('appear')

func _on_anim_finished(anim_name):
	if anim_name == 'appear':
		world.swapping = false
		get_tree().paused = false
		player.anim_state(player.IDLE)
		player.can_move = true
		player.show()
		queue_free()
