extends PanelContainer

@export var uibase: Control
@export var label1: Label
@export var label2: Label
@export var label3: Label

@onready var labels = [label1, label2, label3]

@export var themes: Array[Theme]

func set_theme_to(to):
	await change_themes(themes[to])

func do_initialize():
	visible = true
	$Control/RichTextLabel.text = "Initializing..."
	var time = 2.0
	var t = 0.0
	while t < time:
		show_bar()
		$Control/ColorRect2.value = t/time
		$Control/MouseStopper/ColorRect.color = Color(0, 0, 0, pow(time-t, 2)/time)
		t += get_process_delta_time()
		await get_tree().process_frame
	await(get_tree().create_timer(0.5).timeout)
	visible = false


func change_themes(to: Theme):
	get_node("/root/Game/Audio").play(6)
	show_bar()
	visible = true
	$Control/RichTextLabel.text = "Updating..."
	var starting_color = uibase.theme.get_color("PanelColor", "PanelContainer")
	var ending_color = to.get_color("PanelColor", "PanelContainer")
	var time = 2.0
	var t = 0.0
	while t < time:
		if t < time/2 and t + get_process_delta_time() >= time/2:
			uibase.theme.set_color("PanelColor", "PanelContainer", starting_color)
			uibase.theme = to
		uibase.theme.set_color("PanelColor", "PanelContainer", starting_color.lerp(ending_color, t/time))
		for i in labels:
			i.visible_characters = floor(abs(t-time/2)*2/time * i.get_total_character_count())
		$Control/ColorRect2.value = t/time
		t += get_process_delta_time()
		await get_tree().process_frame
			
	
	$Control/ColorRect2.value = 1
	
	uibase.theme.set_color("PanelColor", "PanelContainer", ending_color)
	for i in labels:
		i.visible_characters = -1
	await(get_tree().create_timer(1).timeout)
	visible = false

func show_text():
	$Control/ColorRect2.visible = false
	$Control/HintLabel.visible = true
	$Control/button.visible = true

func show_bar():
	$Control/ColorRect2.visible = true
	$Control/HintLabel.visible = false
	$Control/button.visible = false

func do_game_over(msg):
	get_node("/root/Game/Audio").play(7)
	show_text()
	visible = true
	$Control/RichTextLabel.text = "GAME OVER:"
	$Control/HintLabel.text = msg
