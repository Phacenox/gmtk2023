extends TextureProgressBar

signal finished()
@export var length = 5
var max_length
func _ready():
	max_length = length
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	length -= delta
	value = length/max_length
	if(length < 0):
		emit_signal("finished")
		queue_free()
