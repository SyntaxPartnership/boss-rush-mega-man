extends KinematicBody2D

signal dead

#Most of these variables will be shared amongst all enemies.

#Get the player node.
onready var world = get_parent().get_parent()
onready var player = world.get_child(2)

#Starting X and Y coordinates. To allow the enemy to respawn when off screen.
var start_pos = Vector2()

#The distance between the player and enemy.
var dist

#Enemy HP.
const DEFAULT_HP = 10
var hp

#Damage enemy does to the player.
var touch = false
var damage = 40

#Other
var dead = false
var flash = false
var f_delay = 0

const RESET_MAX = 120

var state = 0
var immune = true
var shoot = false
var shot_delay = 120
var reset = 0

func _ready():
	start_pos = Vector2(global_position.x, global_position.y)
	
	hp = DEFAULT_HP
	
	dist = global_position.distance_to(player.global_position)
	
	if global_position.x > player.global_position.x:
		$sprite.flip_h = true
	else:
		$sprite.flip_h = false
	
	$anim.play("idle1")

# warning-ignore:unused_argument
func _physics_process(delta):	
	#Calculate the X distance between the player and Met.
	dist = floor(abs(player.global_position.x) - abs(global_position.x))
	
	#Let the reset timer expire and charge direction to face the player.
	if state == 0 and reset > 0:
		reset -= 1
	
	if reset == 60:
		if global_position.x > player.global_position.x:
			$sprite.flip_h = true
		else:
			$sprite.flip_h = false
			
	#If the player is within range, trigger animation.
	if dist >= -64 and dist <= 64 and state == 0 and reset == 0:
		state = 1
		$anim.play("open")
		immune = false
		
	#If the met has shot, start timer.
	if shoot and shot_delay > 0:
		shot_delay -= 1
	
	#When timer expires, start animation.
	if shoot and shot_delay == 0:
		state = 2
		shoot = false
		shot_delay = RESET_MAX
		$anim.play("close")
	
	if flash and f_delay > 0:
		f_delay -= 1
	
	if f_delay == 0 and flash:
		$sprite.show()
		flash = false
	
	if touch and player.hurt_timer == 0 and player.blink_timer == 0 and !player.hurt_swap:
		global.player_life[int(player.swap)] -= damage
		player.damage()
	
	if hp <= 0 and !dead:
		#Calculate item drops here.
		$sprite.hide()
		dead = true
		flash = false
		f_delay = 0
		reset = 0
		emit_signal("dead")
		#Spawn explosion sprite.
		var boom = load("res://scenes/effects/s_explode.tscn").instance()
		boom.global_position = global_position
		world.get_child(3).add_child(boom)

func _on_anim_finished(anim_name):
	#Shoot when open.
	if anim_name == "open":
		$anim.play("idle2")
		shoot = true
	
	#Reset the Met
	if anim_name == "close":
		$anim.play("idle1")
		immune = true
		state = 0
		reset = RESET_MAX

func _on_hit_box_body_entered(body):
	if body.is_in_group("weapons") or body.is_in_group("adaptor_dmg"):
		if !dead:
			if immune and !body.reflect:
				body.reflect = true
			else:
				if body.name != "bone_lancer":
					if hp < body.damage:
						if body.name != "buster_f":
							body._on_screen_exited()
					else:
						body._on_screen_exited()
				hp -= body.damage
				$audio/hit.stop()
				$audio/hit.play()
				$sprite.hide()
				flash = true
				f_delay = 2
	
	if body.name == "player" and !dead:
		touch = true

func _on_hit_box_body_exited(body):
	if body.name == "player":
		touch = false

func _on_screen_exited():
	if dead:
		dead = false
		$sprite.show()
		hp = DEFAULT_HP
