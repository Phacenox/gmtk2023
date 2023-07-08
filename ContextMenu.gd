extends PanelColor

var where = Vector2.ZERO

func _on_button_button_down(which: int):
	if which < 2:
		get_node("../../Tiles/PlayerCity").build(which, where)
	else:
		get_node("../../Tiles/PlayerCity").destroy(where, true)
	visible = false