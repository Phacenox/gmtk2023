extends TextureProgressBar

signal finished()
@export var length = 5
var max_length

func _process(delta):
	if max_length == null:
		max_length = length
	
	length -= delta
	value = length/max_length
	if(length < 0):
		emit_signal("finished")
		queue_free()
