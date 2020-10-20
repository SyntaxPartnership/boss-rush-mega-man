extends KinematicBody2D

onready var world = get_parent().get_parent()
onready var player = world.get_child(2)
onready var camera = player.get_child(9)

var type = 0

var damage = 0

var id = 9
var reflect = false
var ricochet = false

var reverse
var velocity = Vector2()
var angle = 0
var speed = 0
var move = false
var set_master = true
var master_vel = Vector2()
var boss
var floor_bnce = 0
var kill_bnce = 0
var boss_hit = false
var hp = 12

var target = 0
var wall = false
var a_shield = false

var overlap = []

func _ready():
	#Add necessary code for the big bullet.
	match type:
		0:
			$sprite.frame = 6
			$box_b.set_deferred("disabled", false)
			$hit_box/box_b.set_deferred("disabled", false)
		1:
			$sprite.frame = 7
			$hit_box/box_b.set_deferred("disabled", false)
		2:
			$sprite.frame = 6
			$hit_box/box_b.set_deferred("disabled", false)
		3:
			$anim.play("red")
			$box_a.set_deferred("disabled", false)
			$hit_box/box_a.set_deferred("disabled", false)
			
			var get_boss = get_tree().get_nodes_in_group('boss')
			boss = get_boss[0]
	
	if type != 3:
		damage = 20
	else:
		damage = 60
			
	$sprite.show()

func _physics_process(delta):
	
	if hp <= 0 and $anim.get_current_animation() != "blue":
		$anim.play("blue")
	
	if !move and type != 3:
		reverse = velocity.angle() - PI
		reverse = wrapf(reverse, -PI, PI)
		angle = reverse
		reverse = Vector2(cos(reverse), sin(reverse))
		velocity = velocity * speed
		move = true
	
	if type == 3:
		velocity = master_vel * speed

	velocity = move_and_slide(velocity, Vector2(0, -1))
	
	#Big bullet only.
	if type == 3:
		if is_on_wall():
			if global_position.x > camera.limit_left + 128 and master_vel.x > 0 or global_position.x < camera.limit_left + 128 and master_vel.x < 0:
				world.sound('dink')
				master_vel.x = -master_vel.x
				
		if is_on_floor():
			if master_vel.y > 0:
				world.sound('dink')
				floor_bnce += 1
				
				if floor_bnce == 2 and boss.drop_down < 5:
					boss.drop_down += 1
					floor_bnce = 0
					
				master_vel.y = -master_vel.y
	
	overlap = $hit_box.get_overlapping_bodies()
	
	if overlap != []:
		for body in overlap:
			if body.name == "player":
				if player.hurt_timer == 0 and player.blink_timer == 0 and !player.hurt_swap and !player.r_boost:
					global.player_life[int(player.swap)] -= damage
					player.damage()
					if type != 3:
						queue_free()
			
			if type != 3:
				if body.is_in_group("weapons") and body.name == "attack_shield":
					if !ricochet:
						print('test')
						ricochet()
						
			if type == 3:
				if body.is_in_group("weapons"):
					if body.id == 0:
						world.sound('hit')
						hp -= 1
						var boom = load("res://scenes/effects/s_explode.tscn").instance()
						boom.position = body.global_position
						world.get_child(3).add_child(boom)
						body.queue_free()
						
					if body.id == 1 and !body.ret or body.id == 2 and !body.ret:
						world.sound('hit')
						hp -= 3
						var boom = load("res://scenes/effects/s_explode.tscn").instance()
						boom.position = body.global_position
						world.get_child(3).add_child(boom)
						body.ret()
					
					if body.id == 5:
						hp = 0
						master_vel = Vector2(0, -1)
						speed = 400
						body.boing()
					
					if body.id == 6:
						if !a_shield and master_vel.y > 0:
							world.sound('dink')
							hp -= 3
							master_vel.y = -master_vel.y
							add_speed()
							a_shield = true
				
				if body.name == "defend":
					if !set_master and velocity.y < 0:
						kill_bnce += 1
						if hp > 0:
							if kill_bnce < 16:
								world.sound('dink')
								body.desp_delay = 5
								body.get_child(0).offset.y = -2
								var test_vel = (player.global_position - global_position).normalized()
								if test_vel.y < 0:
									master_vel.y = -master_vel.y
								else:
									master_vel = (player.global_position - global_position).normalized()
								add_speed()
								set_master = true
							else:
								speed = 0
								velocity = Vector2.ZERO
								$anim.play("poof")
						else:
							body.normal_dmg()
							var boom = load("res://scenes/effects/l_explode.tscn").instance()
							boom.position = global_position
							world.get_child(3).add_child(boom)
							boss.state = 23
							queue_free()
	else:
		if set_master:
			set_master = false
	
	if a_shield and !overlap.has(get_tree().get_nodes_in_group('weapons')):
		a_shield = false
	
	if type == 0:
		if is_on_wall() and !wall and !ricochet:
			velocity = reverse * (speed * 1.5)
			$box_b.set_deferred("disabled", true)
			world.sound('split')
			for b in range(3):
				var bullet = b + 1
				var up = load("res://scenes/bosses/def_bullet.tscn").instance()
				up.type = 2
				up.velocity = Vector2(cos(angle - ((PI / 8) * bullet)), sin(angle - ((PI / 8) * bullet)))
				up.speed = speed * 1.5
				up.position = global_position
				world.get_child(1).add_child(up)
				var down = load("res://scenes/bosses/def_bullet.tscn").instance()
				down.type = 2
				down.velocity = Vector2(cos(angle + ((PI / 8) * bullet)), sin(angle + ((PI / 8) * bullet)))
				down.speed = speed * 1.5
				down.position = global_position
				world.get_child(1).add_child(down)
			wall = true
	
	if global_position.y < camera.limit_top or global_position.y > camera.limit_bottom or global_position.x < camera.limit_left or global_position.x > camera.limit_right:
		queue_free()

func add_speed():
	if speed < 150:
		speed += 10

func _on_anim_finished(anim_name):
	if anim_name == "poof":
		boss.state = 23
		queue_free()

func ricochet():
	if !ricochet:
		world.sound('dink')
		velocity = -velocity
		remove_from_group('def_bullet')
		add_to_group('weapons')
		self.set_collision_mask_bit(5, true)
		$hit_box.set_collision_layer_bit(0, false)
		$hit_box.set_collision_layer_bit(5, false)
		ricochet = true
