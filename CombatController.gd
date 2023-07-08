extends Node2D

@export var playerCity: City
@export var enemyCity: City
@export var effectsNode: Control

@export var missileLaunch: PackedScene
@export var missileAttack: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func do_combat():
	var pa = playerCity.GetArmy()
	for i in pa:
		launch_missile(i)
	var ea = enemyCity.GetArmy()
	for i in ea:
		launch_missile(i)
	
	await get_tree().create_timer(5).timeout

	var attack_value = pa.count - ea.count

	for i in acquire_targets(enemyCity, min(0, attack_value)):
		target_location(i, enemyCity, true)
		pass #player wins. bomb targets.
	for i in acquire_targets(playerCity, min(0, -attack_value)):
		target_location(i, playerCity, true)
		pass #enemy wins. bomb targets. 9 tiles splash

func acquire_targets(who: City, power: int):
	var r = []
	var theirArmy = who.GetArmy()
	for i in power:#todo: remove until empty, then add the buildings, then the capitol and AI
		r.append(theirArmy[randi_range(0, theirArmy.count-1)])
	return r

func launch_missile(where: Vector2i):
	await get_tree().create_timer(randf()).timeout
	var v = missileLaunch.instantiate()
	effectsNode.add_child(v)
	v.global_position = where*16 + Vector2i(48, 48)

func target_location(where: Vector2i, who: City, splash: bool):
	await get_tree().create_timer(randf()).timeout
	var v = missileAttack.instantiate()
	effectsNode.add_child(v)
	v.global_position = where*16 + Vector2i(48, 48)
	await v.get_node("AnimationPlayer").animation_finished
	if(splash):
		for i in [-1, 0, 1]:
			for j in [-1, 0, 1]:
				who.destroy(where + Vector2i(i,j))
	else:
		who.destroy(where)