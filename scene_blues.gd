extends Sprite

var stopped = false

enum {
	IDLE,
	LILSTEP,
	WALK
}

func _ready():
	print(position,', Loaded!')
	change_anim("lil_step")

func change_anim(name):
	$anim.play(name)

func _on_anim_finished(anim_name):
	match name:
		"lil_step":
			if !stopped:
				change_anim("walk")
			else:
				change_anim("idle")
