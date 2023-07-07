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


func mouseindex(mposition):
	var r = mposition / 16
	r  -= Vector2(2,2)
	r = Vector2(floor(r.x), floor(r.y))
	if r.x < 0 or r.y < 0 or r.x > 19 or r.y > 19:
		return null
	return r

func _input(event):
	if event is InputEventMouseMotion:
		contextMenu.global_position = event.position
		mouseoverTile.clear()
		var mindex = mouseindex(event.position)
		if(mindex != null):
			mouseoverTile.set_cell(0, mouseindex(event.position), 2, Vector2(0,0))
