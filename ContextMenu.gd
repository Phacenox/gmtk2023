extends PanelColor

var where = Vector2.ZERO
@export var playerCity: City

func _input(event):
	if visible:
		if event is InputEventKey:
			if event.keycode == KEY_S and get_node("Vlist/PanelContainer").visible:
				_on_button_button_down(0)
			if event.keycode == KEY_W and get_node("Vlist/PanelContainer2").visible:
				_on_button_button_down(1)
			if event.keycode == KEY_A and get_node("Vlist/PanelContainer4").visible:
				_on_button_button_down(3)
			if event.keycode == KEY_D and get_node("Vlist/PanelContainer3").visible:
				_on_button_button_down(2)

func showMenu(destroy: bool):
	get_node("../../Audio").play(1)
	visible = true
	if(destroy):
		get_node("Vlist/PanelContainer").visible = false
		get_node("Vlist/PanelContainer2").visible = false
		get_node("Vlist/PanelContainer3").visible = true
		get_node("Vlist/PanelContainer4").visible = false
	else:
		get_node("Vlist/PanelContainer").visible = true
		get_node("Vlist/PanelContainer2").visible = true
		get_node("Vlist/PanelContainer3").visible = false
		get_node("Vlist/PanelContainer4").visible = true
	size = Vector2.ZERO

func _on_button_button_down(which: int):
	get_node("../../Audio").play(1)
	match which:
		0:
			if(playerCity.excess_energy() > playerCity.costs[1]):
				playerCity.build(City.types.building, where)
		1:
			if(playerCity.excess_energy() > playerCity.costs[2]):
				playerCity.build(City.types.war, where)
		2:
				playerCity.destroy(where, true)
		3:
			if(playerCity.excess_energy() > playerCity.costs[3]):
				playerCity.build(City.types.comms, where)
	visible = false
