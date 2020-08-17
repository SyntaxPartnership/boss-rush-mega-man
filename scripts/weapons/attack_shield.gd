extends Node2D

onready var world = get_parent().get_parent()
onready var player = world.get_child(2)
onready var camera = player.get_child(9)

var property = null

var id = 6

var reflect = false

var active = false
var dist = 0
var pos = 0
var box_pos = 0
var pos_delay = 2
var desired = 0

var bat_check = []

# Called when the node enters the scene tree for the first time.
func _ready():
	world.sound("shoot_a")
	
	match player.get_child(3).flip_h:
		true:
			pos = 4
		false:
			pos = 0

func _input(event):
	match pos:
		0:
			if player.get_child(3).flip_h and Input.is_action_just_pressed("down") or !player.get_child(3).flip_h and Input.is_action_just_pressed("up"):
				world.sound('connect')
				desired = 2
				pos += 1
		2:
			if Input.is_action_just_pressed("up"):
				world.sound('connect')
				if player.get_child(3).flip_h:
					desired = 0
					pos -= 1
				else:
					desired = 4
					pos += 1
			elif Input.is_action_just_pressed("down"):
				world.sound('connect')
				if player.get_child(3).flip_h:
					desired = 4
					pos += 1
				else:
					desired = 0
					pos -= 1
		4:
			if !player.get_child(3).flip_h and Input.is_action_just_pressed("down") or player.get_child(3).flip_h and Input.is_action_just_pressed("up"):
				world.sound('connect')
				desired = 2
				pos -= 1

func _physics_process(delta):
	
	$sprite.frame = pos
	
	if dist < 5:
		match pos:
			0:
				position.x += 4
			4:
				position.x -= 4
		dist += 1
	else:
		if !active:
			dist = 20
			active = true
		
	if active:
		match pos:
			0:
				if $box_right.disabled:
					$box_left.set_deferred('disabled', true)
					$box_right.set_deferred('disabled', false)
					$box_top.set_deferred('disabled', true)
				
				position.x = player.position.x + dist
				position.y = player.position.y
			1:
				if $box_left.disabled or $box_right.disabled or $box_top.disabled:
					$box_left.set_deferred('disabled', true)
					$box_right.set_deferred('disabled', true)
					$box_top.set_deferred('disabled', true)
				
				position.x = player.position.x + (dist * 0.75)
				position.y = player.position.y - (dist * 0.75)
			2:
				if $box_top.disabled:
					$box_left.set_deferred('disabled', true)
					$box_right.set_deferred('disabled', true)
					$box_top.set_deferred('disabled', false)
					
				position.x = player.position.x
				position.y = player.position.y - dist
			3:
				if $box_left.disabled or $box_right.disabled or $box_top.disabled:
					$box_left.set_deferred('disabled', true)
					$box_right.set_deferred('disabled', true)
					$box_top.set_deferred('disabled', true)
					
				position.x = player.position.x - (dist * 0.75)
				position.y = player.position.y - (dist * 0.75)
			4:
				if $box_left.disabled:
					$box_left.set_deferred('disabled', false)
					$box_right.set_deferred('disabled', true)
					$box_top.set_deferred('disabled', true)
					
				position.x = player.position.x - dist
				position.y = player.position.y
		
		if pos == 1 or pos == 3:
			pos_delay -= 1
			
			if pos_delay == 0:
				pos = desired
				pos_delay = 2

func _on_screen_exited():
	print('Boom!')
	var boom = load("res://scenes/effects/s_explode.tscn").instance()
	boom.global_position = global_position
	world.get_child(3).add_child(boom)
	queue_free()
