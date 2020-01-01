extends KinematicBody2D

onready var world = get_parent().get_parent()
onready var player = world.get_child(2)
onready var flip = player.get_child(3)

var hurt = false
var hurt_timer = 16
var hurt_boom = false

var x_dir
var velocity = Vector2()
var stop = false
var leaving = false

func _ready():
	
	#Determine which player is active and set the texture accordingly.
	if global.player == 0:
		$sprite.set('texture', load('res://assets/sprites/player/mega-norm.png'))
	if global.player == 1:
		$sprite.set('texture', load('res://assets/sprites/player/proto-norm.png'))
	if global.player == 2:
		$sprite.set('texture', load('res://assets/sprites/player/bass-norm.png'))
	
	#Determine if the player's sprite is flipped. If so, also flip this one.
	if flip.flip_h:
		$sprite.flip_h = true
	
	#Determine which animation is to be played.
	if hurt:
		if !hurt_boom:
			var boom = load('res://scenes/effects/l_explode.tscn').instance()
			world.get_child(3).add_child(boom)
		$anim.play("hurt")
		velocity.y = 0
	else:
		$anim.play("jump")
		velocity.y = player.JUMP_SPEED * .75
	
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
	#Set facial colors
	$sprite.material.set_shader_param('f_col1', global.black)
	$sprite.material.set_shader_param('f_col2', global.yellow0)
	$sprite.material.set_shader_param('f_col3', global.white)

func _process(delta):
	
#	#Set X velocity.
	if !is_on_floor() and !stop or hurt and !stop:
		if $sprite.flip_h:
			x_dir = 1
		else:
			x_dir = -1
	elif is_on_floor() or stop:
		x_dir = 0

	velocity.x = x_dir * player.RUN_SPEED

	#Set Y velocity.
	if !stop:
		velocity.y += player.GRAVITY * delta
	else:
		velocity.y = 0
	
	if hurt and hurt_timer > 0:
		hurt_timer -= 1
	
	if hurt and hurt_timer == 0 and is_on_floor() and !stop:
		$anim.play('down')
		stop = true
	
	#Move the sprite.
	velocity = move_and_slide(velocity, Vector2(0, -1))
	
	if leaving:
		position.y -= 8
	
	if !hurt and velocity.y > 0 and !stop:
		$anim.play('appear')
		stop = true

func _on_anim_animation_finished(anim_name):
	if anim_name == 'appear':
		$anim.play('beam')
		$box.set_disabled(true)
		leaving = true
	if anim_name == 'down':
		$anim.play('appear')

func _on_screen_exited():
	queue_free()
