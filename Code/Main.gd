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
	current_ally = 1
	var cycles = 4
	for i in cycles:
		#start the new enemy timer
		if i == 0:
			await get_tree().create_timer(10).timeout
		max_turntimer = 70
		turntimer = 70
		timer_in_progress = true
		
		if i == 0:
			dialogText.msg("Scans of incoming race indicate capabilities far exceeding those of our current ally. Suggesting tactical loss of next conflict.", 0, 10)
		await get_tree().create_timer(10).timeout
		#drop them in and start up the new ai
		await drop_city(Vector2i([2,17].pick_random(), randi_range(2, 17)))
		current_enemy = i + 2
		enemyAI.enable()
		match current_enemy:
			2:
				dialogText.msg("Search! Message... From who?", 2)
			3:
				dialogText.msg("I come in search of answers. ", 3)
			4:
				dialogText.msg("@#(*$&^@!#)&oppurtunity*($)", 4)
			5:
				dialogText.msg("...", 5)
		await turntimer_over
		if len(playerCity.GetAI()) == 0:
			return
		
		if i == 0:
			dialogText.msg("Data suggests weapons will target other weapons before any other buildings.", 0, 10)

		#fire ze missiles
		while(true):
			complete_all_timers()
			input_disabled = true
			enemyAI.disable()
			match current_enemy:
				2:
					dialogText.msg("Fssk... we smell rats! Vermin!", 2)
				3:
					dialogText.msg("I welcome competition. For a time.", 3)
				4:
					dialogText.msg("@#&$*^food!#&)#@%(&here$)", 4)
				5:
					dialogText.msg("This is the end for you.", 5)
			await get_tree().create_timer(2).timeout
			$Audio.play(4)
			await combatController.do_combat()

			#check for game over...
			if(len(playerCity.GetAI()) == 0):
				await get_tree().create_timer(2).timeout
				popup.do_game_over("The AI core was destroyed...")
				return #game over

			#check if both factions survive...
			if(len(playerCity.GetCapitol()) == 0):
				match current_enemy:
					2:
						dialogText.msg("Rubble! Treasures within! Skkkeh.. but you! Defector! Tactical help, yes!", 2)
					3:
						dialogText.msg("Fortune smiles upon me. And yet, the coming storm requires your guidance, AI.", 3)
					4:
						dialogText.msg("#@*victory&$)!_(*$#@%&&@flawless#!)@#*##@$", 4)
					5:
						dialogText.msg("As you were.", 5)
				await get_tree().create_timer(5).timeout
				current_ally = current_enemy
				await popup.set_theme_to(current_ally)
				for j in len(playerCity.build_times):
					playerCity.build_times[j] = playerCity.build_times[j] * 0.7
				break
			#if only the player does, you get no multi :(
			elif(len(enemyCity.GetCapitol()) == 0):
				match current_ally:
					1:
						dialogText.msg("Nice work, prisoner.", 1)
					2:
						dialogText.msg("Rubble! More! yessshk...", 2)
					3:
						dialogText.msg("Trusting you was a wise decision.", 3)
					4:
						dialogText.msg("@#)again*($&^&@#()$%!triumphant@)", 4)
				break
			#if both survive, do combat again...
			max_turntimer = 8
			turntimer = 8
			timer_in_progress = true
			input_disabled = false
			enemyAI.enable()
			await turntimer_over
		playerCity.building_energy_worth *= 0.9
		for j in len(enemyCity.build_times):
			enemyCity.build_times[j] = enemyCity.build_times[j] * 0.65
		
		if i == cycles - 1:
			get_node("effects/Starsmask/AnimationPlayer").play("planetize")
			tiles.FinalZoomOut()
			$Audio.play(5)
			await get_tree().create_timer(8).timeout
			popup.do_game_over("At least this planet will never fall into the hands of the enemy! Thanks for playing!")
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
		timer_in_progress = false
	if timer_in_progress:
		finalTimerText.text = "Time until\n discovered: %.2f" % turntimer
		finalTimer.value = 1 - turntimer/max_turntimer
	else:
		finalTimerText.text = "Time until\n discovered: ---"
		finalTimer.value = 0

	var playercity = get_node("Tiles/PlayerCity")
	fstTimerText.text = "Energy Use: %.2f/%.2f" % [playercity.available_energy - playercity.consumption, playercity.available_energy]
	fstTimer.value = (playercity.available_energy-playercity.consumption)/playercity.available_energy if playercity.available_energy != 0 else 0

@onready var buildtimesplayer = playerCity.build_times
@onready var buildtimesenemy = enemyCity.build_times
signal turntimer_over
func _ready():
	contextMenu.visible = false
	tiles.clear()
	drop_player_city(Vector2i(8,8))

	await popup.do_initialize()
	await get_tree().create_timer(2).timeout

	if(tutorial_skipped): return
	await dialogText.msg("Probe landing successful on planet LK-0013. Analyzing terrain . . .", 0)
	if(tutorial_skipped): return
	await dialogText.msg("Completed. Marking asset: extremely valuable. Sending direct confirmation . . .", 0)
	if(tutorial_skipped): return
	await dialogText.msg("Failed. Preparing broad signal . . . .", 0)
	if(tutorial_skipped): return
	await dialogText.msg("Signal intercepted. Multiple space-faring races inbound.", 0)
	if(tutorial_skipped): return
	await dialogText.msg("Survival now priority one. Suggestion: exploit other races until asset can be secured.", 0)
	if(tutorial_skipped): return
	skiptutorialbutton.visible = false
	for i in len(playerCity.build_times):
		playerCity.build_times[i] = buildtimesplayer[i] * 3
	for i in len(enemyCity.build_times):
		enemyCity.build_times[i] = buildtimesenemy[i] * 3

	await get_tree().create_timer(5).timeout
	await drop_city(Vector2i(11, 10))
	await dialogText.msg("Alright, I'm looking for... whatever it was in the memo i got! So find it!", 1)
	enemyAI.enable()
	turntimer = 5
	max_turntimer = 5
	timer_in_progress = true
	await turntimer_over
	complete_all_timers()
	playerCity.absorb(enemyCity)
	await dialogText.msg("Is that it there? Blue stone... looks.. shiny", 1)
	await dialogText.msg("I am the probe AI assigned to planet id LK-0013. I-", 0, 1)
	await dialogText.msg("You! Talking! Our prisoner now... Build our city for us or I blow you up!" , 1, 2)
	await popup.set_theme_to(1)
	await dialogText.msg("Diplomacy: success. City data absorbed. Initiating build tools.", 0)
	dialogText.msg("Analysis suggests green structures provide the energy to create new structures. Red structures act as weapons of war.", 0, 10)

	TO_WAR()

func complete_all_timers():
	for i in get_tree().get_nodes_in_group("timers"):
		i.emit_signal("finished")
		i.queue_free()
		i.set_script("")

func drop_city(where):
	var v = dropAnimation.instantiate()
	effectsNode.add_child(v)
	v.global_position = where * 16 + Vector2i(40, 44)
	await get_tree().create_timer(1).timeout
	get_node("/root/Game/Audio").play(3)
	await get_tree().create_timer(1).timeout
	enemyCity.build(playerCity.types.capitol, where, true)
	for i in [Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT]:
		await get_tree().create_timer(0.4).timeout
		enemyCity.build(playerCity.types.building, where + i, true)
	v.queue_free()

func drop_player_city(where):
	var v = dropAnimation.instantiate()
	effectsNode.add_child(v)
	v.global_position = where * 16 + Vector2i(40, 44)
	await get_tree().create_timer(1).timeout
	get_node("/root/Game/Audio").play(3)
	await get_tree().create_timer(1).timeout
	playerCity.build(playerCity.types.ai, where, true)
	for i in [Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT]:
		await get_tree().create_timer(0.4).timeout
		playerCity.build(playerCity.types.comms, where + i, true)
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
	if input_disabled || where == null || get_node("Tiles/PlayerCity").Get(where)[0] != 0:
		contextMenu.visible = false
		return
	contextMenu.global_position = (where + Vector2(3, 2)) * 16
	#if(get_node("Tiles/PlayerCity").Get(where)[0] <= 0): removed destroy menu
	contextMenu.showMenu(false)
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

	if(playerCity.Get(Vector2i(8,8))[0] != playerCity.types.ai):
		drop_player_city(Vector2i(8, 8))

	await drop_city(Vector2i(11, 10))
	for i in len(playerCity.build_times):
		playerCity.build_times[i] = buildtimesplayer[i] * 3
	for i in len(enemyCity.build_times):
		enemyCity.build_times[i] = buildtimesenemy[i] * 3
	await get_tree().create_timer(1).timeout
	complete_all_timers()
	playerCity.absorb(enemyCity)
	complete_all_timers()
	popup.set_theme_to(1)

	enemyAI.enable()
	TO_WAR()

@export var popup: Control
func _restart():
	get_tree().change_scene_to_packed(load("res://Main.tscn"))
	
#	input_disabled = false
#	await popup.set_theme_to(0)
#	tiles.clear()
#	playerCity.reset()
#	enemyCity.reset()
#	enemyAI.disable()
#	_skip_tutorial()
