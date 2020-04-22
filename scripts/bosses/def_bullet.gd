extends KinematicBody2D

onready var world = get_parent().get_parent()

var type = 0

var reverse
var velocity = Vector2()
var angle = 0
var speed = 0
var move = false

var target = 0
var wall = false

func _ready():
	#Add necessary code for the big bullet.
	match type:
		0:
			$sprite.frame = 6
			$box_b.set_deferred("disabled", false)
		1:
			$sprite.frame = 7
		2:
			$sprite.frame = 6
			
		
	$sprite.show()

func _physics_process(delta):
	
	if !move:
		reverse = velocity.angle() - PI
		reverse = wrapf(reverse, -PI, PI)
		angle = reverse
		reverse = Vector2(cos(reverse), sin(reverse))
		velocity = velocity * speed
		move = true

	velocity = move_and_slide(velocity, Vector2(0, -1))
	
	if type == 0:
		if is_on_wall() and !wall:
			velocity = reverse * speed
			$box_b.set_deferred("disabled", true)
			for b in range(3):
				var bullet = b + 1
				var up = load("res://scenes/bosses/def_bullet.tscn").instance()
				up.type = 3
				up.velocity = Vector2(cos(angle - ((PI / 8) * bullet)), sin(angle - ((PI / 8) * bullet)))
				up.speed = speed
				up.position = global_position
				world.get_child(1).add_child(up)
				var down = load("res://scenes/bosses/def_bullet.tscn").instance()
				down.type = 3
				down.velocity = Vector2(cos(angle + ((PI / 8) * bullet)), sin(angle + ((PI / 8) * bullet)))
				down.speed = speed
				down.position = global_position
				world.get_child(1).add_child(down)
			wall = true
