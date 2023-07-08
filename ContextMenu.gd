extends PanelColor

var where = Vector2.ZERO

func showMenu(destroy: bool):
	visible = true
	if(destroy):
		get_node("Vlist/PanelContainer").visible = false
		get_node("Vlist/PanelContainer2").visible = false
		get_node("Vlist/PanelContainer3").visible = true
	else:
		get_node("Vlist/PanelContainer").visible = true
		get_node("Vlist/PanelContainer2").visible = true
		get_node("Vlist/PanelContainer3").visible = false
	size = Vector2.ZERO

func _on_button_button_down(which: int):
	match which:
		0:
			get_node("../../Tiles/PlayerCity").build(City.types.building, where)
		1:
			get_node("../../Tiles/PlayerCity").build(City.types.war, where)
		2:
			get_node("../../Tiles/PlayerCity").destroy(where, true)
	visible = false
