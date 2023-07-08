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
	if where == null: return
	contextMenu.global_position = (where + Vector2(3, 2)) * 16
	contextMenu.visible = true
	contextMenu.where = where



func _on_button_button_up():
	if !contextMenu.visible:
		show_context_menu(mouseindex(get_viewport().get_mouse_position()))
	pass # Replace with function body.

func _on_button_button_down():
	print(1)
	if mouseindex(get_viewport().get_mouse_position()) == null: contextMenu.visible = false
	else: show_context_menu(mouseindex(get_viewport().get_mouse_position()))