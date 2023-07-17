@tool
extends Control
class_name PanelColor

@export var depth: float = 0

func _draw():
	self_modulate = get_theme_color("PanelColor", "PanelContainer") - Color(depth, depth, depth, 0)
