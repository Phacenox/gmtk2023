extends GPUParticles2D

func _enter_tree():
	emitting = true

func _process(_delta):
	if !emitting:
		queue_free()
