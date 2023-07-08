@tool
extends Sprite2D


var timer = 0.3
func _process(delta):
	timer -= delta
	if timer < 0:
		timer += 0.3
		frame = 1 if frame == 0 else 0
	pass
