@tool
extends TileMap

@export var speed: float
var t = 0

func _process(delta):
	t += delta * speed
	modulate.a = (sin(t))/5 + 0.5