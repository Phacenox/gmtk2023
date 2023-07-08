extends RichTextLabel

@export var timer: PackedScene
@export var effectsNode: Control
@export var sprite: Sprite2D

# Called when the node enters the scene tree for the first time.
func _ready():
	visible_characters = 0
	pass # Replace with function body.


var t = 0.03
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	t -= delta
	if t < 0:
		visible_characters += 1
		t += 0.03

func msg(m, who: int, ttime = 5):
	text = m
	visible_characters = 0
	sprite.frame = who

	var v = timer.instantiate()
	v.length = ttime
	effectsNode.add_child(v)
	v.global_position = global_position - Vector2(86, 22)
	await v.finished