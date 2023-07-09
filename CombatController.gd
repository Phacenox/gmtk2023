extends Node2D

@export var playerCity: City
@export var enemyCity: City
@export var effectsNode: Control

@export var missileLaunch: PackedScene
@export var missileAttack: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
@export var dialogText: RichTextLabel

func do_combat():
	var pa = playerCity.GetArmy()
	for i in pa:
		launch_missile(i)
	var ea = enemyCity.GetArmy()
	for i in ea:
		launch_missile(i)
	
	await get_tree().create_timer(5).timeout

	var attack_value = len(pa) - len(ea)
	if attack_value < 0:
		dialogText.msg("Combat: stopped %d rockets. Incoming: %d" % [len(pa), -attack_value], 0)
	elif attack_value > 0:
		dialogText.msg("Combat: enemy stopped %d rockets. %d will reach their target." % [len(ea), attack_value], 0)
	else:
		dialogText.msg("Combat: near stalemate. Incoming: one rocket.", 0)
		attack_value = -1


	await get_tree().create_timer(2).timeout

	for i in acquire_targets(enemyCity, max(0, attack_value)):
		target_location(i, enemyCity, true)
		pass #player wins. bomb targets.
	for i in acquire_targets(playerCity, max(0, -attack_value)):
		target_location(i, playerCity, true)
		pass #enemy wins. bomb targets. 9 tiles splash
	await get_tree().create_timer(4).timeout

func acquire_targets(who: City, power: int):
	var r = []
	var buildings = who.GetArmy()
	var state = 0
	for i in power:
		if len(buildings) == 0:
			match state:
				0:
					buildings = who.GetHousing()
					buildings.append_array(who.GetComms())
				1:
					buildings = who.GetAI()
					buildings.append_array(who.GetCapitol())
				2:
					return r
			state += 1
		var ri = buildings.pop_at(randi_range(0, len(buildings)-1))
		if ri != null:
			r.append(ri)

	return r

func launch_missile(where: Vector2i):
	await get_tree().create_timer(randf()).timeout
	var v = missileLaunch.instantiate()
	effectsNode.add_child(v)
	v.global_position = where*16 + Vector2i(39, 39)

func target_location(where: Vector2i, who: City, splash: bool):
	await get_tree().create_timer(randf()).timeout
	var v = missileAttack.instantiate()
	effectsNode.add_child(v)
	v.global_position = where*16 + Vector2i(40, 40)
	await v.get_node("AnimationPlayer").animation_finished
	get_node("/root/Game/Audio").play(8)
	if(splash):
		for i in [-1, 0, 1]:
			for j in [-1, 0, 1]:
				who.destroy(where + Vector2i(i,j))
		who.destroy(where)
	else:
		who.destroy(where)
