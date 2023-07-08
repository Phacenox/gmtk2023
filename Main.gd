extends Node2D

@export var tiles: TileMap
@export var mouseoverTile: TileMap
@export var portraitSprite: Sprite2D
@export var dialogText: RichTextLabel
@export var finalTimerText: Label
@export var fstTimerText: Label
@export var finalTimer: PanelColor
@export var fstTimer: PanelColor
@export var UIBase: Control
@export var contextMenu: PanelContainer
@export var dropAnimation: PackedScene
@export var effectsNode: Control
@export var enemyAI: Node2D
@export var combatController: Node2D
@export var playerCity: Node2D
@export var enemyCity: Node2D

func reduce_timer(amount):
	turntimer -= amount

var input_disabled = false
var current_ally = 0
var current_enemy = 1
func TO_WAR():

	var cycles = 4
	for i in cycles:
		#start the new enemy timer
		if tutorial_skipped and i == 0:
			await get_tree().create_timer(10).timeout
		max_turntimer = 70
		turntimer = 70
		await get_tree().create_timer(10).timeout
		#drop them in and start up the new ai
		await drop_city("EnemyCity", Vector2i(2, 2))
		enemyAI.enable()
		await turntimer_over

		input_disabled = true
		enemyAI.disable()
		complete_all_timers()
		#fire ze missiles
		while(true):
			await combatController.do_combat()

			#check for game over...
			if(len(playerCity.GetAI()) == 0):
				return #game over

			#check if both factions survive...
			if(len(playerCity.GetCapitol()) == 0):
				for j in len(playerCity.build_times):
					playerCity.build_times[j] = playerCity.build_times[j] * 0.7
				break
			#if only the player does, you get no multi :(
			elif(len(enemyCity.GetCapitol()) == 0):
				break
			#if both survive, do combat again...

		for j in len(enemyCity.build_times):
			enemyCity.build_times[j] = enemyCity.build_times[j] * 0.7
		if i == cycles - 1:
			get_node("effects/Starsmask/AnimationPlayer").play("planetize")
			await get_tree().create_timer(2).timeout
			tiles.FinalZoomOut()
			return
		else:
			await tiles.ZoomOut()
			input_disabled = false
	#you win!

var turntimer = 90.0
var max_turntimer = 90
var timer_in_progress = false
func _process(delta):
	if(turntimer > 0):
		turntimer -= delta
	else:
		emit_signal("turntimer_over")
	if timer_in_progress:
		finalTimerText.text = "Time until\n discovered: %.2f" % turntimer
		finalTimer.value = 1 - turntimer/max_turntimer
	else:
		finalTimerText.text = "Time until\n discovered: ---"
		finalTimer.value = 0

	var playercity = get_node("Tiles/PlayerCity")
	fstTimerText.text = "Energy Use: %.2f/%.2f" % [playercity.available_energy - playercity.consumption, playercity.available_energy]
	fstTimer.value = (playercity.available_energy-playercity.consumption)/playercity.available_energy

signal turntimer_over
func _ready():
	contextMenu.visible = false
	tiles.clear()

	await dialogText.msg("Welcome to thing", 0)
	if(tutorial_skipped): return
	await dialogText.msg("second message...", 0)
	if(tutorial_skipped): return
	skiptutorialbutton.visible = false

	playerCity.build(playerCity.types.ai, Vector2i(8, 8), true)
	await get_tree().create_timer(5).timeout
	await drop_city("EnemyCity", Vector2i(11, 10))
	for i in len(playerCity.build_times):
		playerCity.build_times[i] = playerCity.build_times[i] * 3
	for i in len(enemyCity.build_times):
		enemyCity.build_times[i] = enemyCity.build_times[i] * 3
	enemyAI.enable()
	turntimer = 5
	max_turntimer = 5
	timer_in_progress = true
	await turntimer_over
	complete_all_timers()
	playerCity.absorb(enemyCity)

	TO_WAR()

func complete_all_timers():
	for i in get_tree().get_nodes_in_group("timers"):
		i.emit_signal("finished")
		i.queue_free()
		i.set_script("")

func drop_city(who, where):
	var v = dropAnimation.instantiate()
	effectsNode.add_child(v)
	v.global_position = where * 16 + Vector2i(40, 44)
	await get_tree().create_timer(2).timeout
	get_node("Tiles/" + who).build(playerCity.types.capitol, where, true)
	for i in [Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT]:
		await get_tree().create_timer(0.4).timeout
		get_node("Tiles/" + who).build(playerCity.types.building, where + i, true)
	v.queue_free()
		


func mouseindex(mposition):
	var r = mposition / 16
	r  -= Vector2(2,2)
	r = Vector2(floor(r.x), floor(r.y))
	if r.x < 0 or r.y < 0 or r.x > 19 or r.y > 19:
		return null
	return r

func _input(event):
	if(input_disabled):
		mouseoverTile.clear()
		return
	if event is InputEventMouseMotion:
		mouseoverTile.clear()
		var mindex = mouseindex(event.position)
		if(mindex != null):
			mouseoverTile.set_cell(0, mouseindex(event.position), 2, Vector2(0,0))
		if(contextMenu.visible):
			mouseoverTile.set_cell(0, contextMenu.where, 2, Vector2(0, 0))

func show_context_menu(where):
	if input_disabled || where == null || get_node("Tiles/PlayerCity").Get(where)[0] == -1:
		contextMenu.visible = false
		return
	contextMenu.global_position = (where + Vector2(3, 2)) * 16
	contextMenu.showMenu(get_node("Tiles/PlayerCity").Get(where)[0] > 0)
	contextMenu.where = where



func _on_button_button_up():
	if(input_disabled):
		contextMenu.visible = false
		return
	if !contextMenu.visible:
		show_context_menu(mouseindex(get_viewport().get_mouse_position()))
	pass # Replace with function body.

func _on_button_button_down():
	if(input_disabled):
		contextMenu.visible = false
		return
	show_context_menu(mouseindex(get_viewport().get_mouse_position()))

@export var skiptutorialbutton: PanelContainer
var tutorial_skipped = false
func _skip_tutorial():
	skiptutorialbutton.visible = false
	tutorial_skipped = true

	
	playerCity.build(playerCity.types.ai, Vector2i(8, 8), true)
	await drop_city("EnemyCity", Vector2i(11, 10))
	for i in len(playerCity.build_times):
		playerCity.build_times[i] = playerCity.build_times[i] * 3
	for i in len(enemyCity.build_times):
		enemyCity.build_times[i] = enemyCity.build_times[i] * 3
	await get_tree().create_timer(1).timeout
	complete_all_timers()
	playerCity.absorb(enemyCity)
	complete_all_timers()

	enemyAI.enable()
	TO_WAR()
