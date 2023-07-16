@tool
extends TextureRect

@export var depth: float = 0

func _draw():
	texture = get_theme_icon("emblem", "PanelContainer")
	self_modulate = get_theme_color("PanelColor", "PanelContainer") - Color(depth, depth, depth, 0)

