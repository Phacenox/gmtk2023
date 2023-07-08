extends Node2D

class_name City

@export var poofparticles: PackedScene

@export var buildtimer: PackedScene
@export var costs: Array[int]
@export var build_times: Array[float]
@export var capitol_sprite_id: Vector2i
@export var effectsNode: Control

@onready var tilemap: TileMap = get_parent()

var tiles = []
var resource

enum types{
	scaffold,
	building,
	war,
	ai,
	capitol
}
const type_count = 4

func _init():
	for i in 20:
		tiles.append([])
		for _j in 20:
			tiles[i].append([-1, false])


func has(pos: Vector2i) -> bool:
	return tiles[pos.x][pos.y][0] >= 0

func Get(pos: Vector2i):
	return tiles[pos.x][pos.y]

func absorb(other: City):
	for i in 20:
		for j in 20:
			if tiles[i][j] == [-1, false]:
				tiles[i][j] = other.tiles[i][j]

func build(what: int, pos: Vector2i, force = false):
	if force or (what == 0 and Get(pos)[0] == -1) or Get(pos)[0] == 0:
		tilemap.set_cell(0, pos, 0, Vector2(what,0))
		tiles[pos.x][pos.y] = [what, true]
		doparticles(pos)
		if what > 0:
			scaffold_from(pos)

func scaffold_from(pos: Vector2i):
	for i in [Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT, Vector2i.UP]:
		if Get(pos + i)[0] < 0:
			build(0, pos + i)


func in_bounds(pos: Vector2i):
	return pos.x < 0 or pos.y < 0 or pos.x >= 20 or pos.y >= 20

func destroy(pos: Vector2i, voluntary: bool = false):
	if(voluntary and Get(pos)[0] > 0):
		build(0, pos, true)
	else:
		tiles[pos.x][pos.y] = [-1, false]
		tilemap.set_cell(0, pos, -1)
		doparticles(pos)

func doparticles(pos):
	var v = poofparticles.instantiate()
	effectsNode.add_child(v)
	v.global_position = pos * 16 + Vector2i(40, 40)


func complete_all():
	pass

func war_map(i):
	return i.filter(war_filter).count
func war_filter(i):
	return i[0] == types.war and i[1] == true
func sum(i, j):
	return i + j
func war_strength() -> int:
	return tiles.map(war_map).reduce(sum,0)

func building_map(i):
		return i.building_filter(war_filter).count
func building_filter(i):
	return i[0] == types.building and i[1] == true
func building_strength() -> int:
	return tiles.map(building_map).reduce(sum,0)

func GetArmy():
	var r = []
	for i in 20:
		for j in 20:
			if(tiles[i][j][0] == types.war):
				r.append(Vector2i(i,j))
	return r
func GetHousing():
	var r = []
	for i in 20:
		for j in 20:
			if(tiles[i][j][0] == types.building):
				r.append(Vector2i(i,j))
	return r
func GetCapitol():
	for i in 20:
		for j in 20:
			if(tiles[i][j][0] == types.capitol):
				return [Vector2i(i,j)]
func GetAI():
	for i in 20:
		for j in 20:
			if(tiles[i][j][0] == types.ai):
				return [Vector2i(i,j)]