extends Node2D

@export var city: City

var enabled = false

var step_delay = 0.9
var step_timer = 0.9
func _process(delta):
	if(!enabled):
		return
	step_timer -= delta
	if(step_timer < 0):
		step_timer += step_delay
		step()

func enable():
	enabled = true
	step_timer = step_delay
func disable():
	enabled = false

const cardinals = [Vector2i.UP, Vector2i.RIGHT, Vector2i.LEFT, Vector2i.DOWN]
func step():
	if(city.excess_energy() < city.costs[city.types.building]):
		return
	var e = city.GetArmy()
	if(city.excess_energy() > city.costs[city.types.building] + city.costs[city.types.war]):
		if len(e) > 0:
			for _i in 3:
				var choice = e.pick_random() + cardinals.pick_random()
				if can_build(choice):
					city.build(city.types.war, choice)
					return
	var b = city.GetHousing()
	if(len(b) > 0):
		for _i in 3:
			var choice = b.pick_random() + cardinals.pick_random()
			if can_build(choice):
				if(randf() > 0.7):
					city.build(2, choice)
				else:
					city.build(1, choice)
				return
	var s = city.GetBuildSpots()
	if(len(s) > 0):
		if(randf() > 0.7):
			city.build(2, s.pick_random())
		else:
			city.build(1, s.pick_random())

func can_build(where) -> bool:
	return city.in_bounds(where) and city.Get(where)[0] == 0