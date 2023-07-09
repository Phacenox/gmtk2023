extends GPUParticles2D

func _enter_tree():
	get_node("/root/Game/Audio").play(2)
	emitting = true

func _process(_delta):
	if !emitting:
		queue_free()
