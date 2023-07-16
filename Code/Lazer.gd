extends Sprite2D


var state = 2
var time = .15
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time -= delta
	if(time < 0):
		position.y += state
		state *= -1
		time += 0.15
