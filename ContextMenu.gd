extends PanelColor

var where = Vector2.ZERO
@export var playerCity: City

func showMenu(destroy: bool):
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
