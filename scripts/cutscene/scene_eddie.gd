extends KinematicBody2D

onready var world = get_parent().get_parent().get_parent()
onready var player = world.get_child(2)

const GRAVITY = 900

var velocity = Vector2()

var next = 90

func _ready():
	velocity.y = 0
	$anim.play("fall")

func _physics_process(delta):
	velocity.y += GRAVITY * delta
	
	if velocity.y > 500:
		velocity.y = 500
	
	velocity = move_and_slide(velocity, Vector2(0, -1))
	
	if !is_on_floor() and global_position.x > player.global_position.x:
		if player.get_child(3).flip_h:
			player.get_child(3).flip_h = false
	
	for idx in range(get_slide_count()):
		var collision = get_slide_collision(idx)
		
		if is_on_floor() and collision.collider.name == "scene_auto":
			world.sound("boing")
			collision.collider.get_child(1).play("bonk")
			velocity.y = -400
			velocity.x = 100
		
		if is_on_floor() and collision.collider.name != "scene_auto":
			next -= 1
			
			if next == 0:
				player.get_child(3).flip_h = true
				world.scene = 5
				world.sub_scene = 4
			
			if velocity.x != 0:
				print(global_position.x)
				player.anim_state(player.IDLE)
				velocity.x = 0
				$anim.play("land")
			

func _on_anim_finished(anim_name):
	if anim_name == "land":
		$sprite.flip_h = true
		$anim.play("idle")
