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

@export var fonts: Array[Font]

func msg(m, who: int, ttime = 5):
	get_node("../../../../Audio").play(0)
	sprite.visible = true
	get_parent().get_parent().depth = -0.2
	get_parent().get_parent()._draw()
	visible = true

	add_theme_font_override("normal_font", fonts[who])
	text = m
	visible_characters = 0
	sprite.frame = who

	var v = timer.instantiate()
	v.length = ttime
	effectsNode.add_child(v)
	v.global_position = global_position - Vector2(86, 22)
	await v.finished
	if text == m:
		slow_hide()

func slow_hide():
	var cachetext = text
	await get_tree().create_timer(2).timeout
	if cachetext == text:
		sprite.visible = false
		get_parent().get_parent().depth = 0.4
		get_parent().get_parent()._draw()
		visible = false
