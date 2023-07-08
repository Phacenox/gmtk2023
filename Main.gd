extends Node2D

@export var tiles: TileMap
@export var mouseoverTile: TileMap
@export var portraitSprite: Sprite2D
@export var dialogText: RichTextLabel
#@export var FinalTimerText: RichTextLabel
#@export var fstTimerText: RichTextLabel
@export var finalTimer: ColorRect
@export var fstTimer: ColorRect
@export var UIBase: Control
@export var contextMenu: PanelContainer

func _ready():
	contextMenu.visible = false
	tiles.clear()
	drop_city("PlayerCity", Vector2i(4, 4))
	drop_city("EnemyCity", Vector2i(16, 13))

func drop_city(who, where):
	get_node("Tiles/" + who).build(3, where, true)
	for i in [Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT]:
		get_node("Tiles/" + who).build(1, where + i, true)
		


func mouseindex(mposition):
	var r = mposition / 16
	r  -= Vector2(2,2)
	r = Vector2(floor(r.x), floor(r.y))
	if r.x < 0 or r.y < 0 or r.x > 19 or r.y > 19:
		return null
	return r

func _input(event):
	if event is InputEventMouseMotion:
		mouseoverTile.clear()
		var mindex = mouseindex(event.position)
		if(mindex != null):
			mouseoverTile.set_cell(0, mouseindex(event.position), 2, Vector2(0,0))
		if(contextMenu.visible):
			mouseoverTile.set_cell(0, contextMenu.where, 2, Vector2(0, 0))

func show_context_menu(where):
	if where == null || get_node("Tiles/PlayerCity").Get(where)[0] == -1:
		contextMenu.visible = false
		return
	contextMenu.global_position = (where + Vector2(3, 2)) * 16
	contextMenu.showMenu(get_node("Tiles/PlayerCity").Get(where)[0] > 0)
	contextMenu.where = where



func _on_button_button_up():
	if !contextMenu.visible:
		show_context_menu(mouseindex(get_viewport().get_mouse_position()))
	pass # Replace with function body.

func _on_button_button_down():
	show_context_menu(mouseindex(get_viewport().get_mouse_position()))