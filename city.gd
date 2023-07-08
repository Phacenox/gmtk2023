extends Node2D

class_name City

@export var poofparticles: PackedScene

@export var buildtimer: PackedScene
@export var costs: Array[float]
@export var build_times: Array[float]
@export var capitol_sprite_id: Vector2i
@export var effectsNode: Control
@export var otherCity: City

@onready var tilemap: TileMap = get_parent()

var tiles = []
var resource

const building_energy_worth = 0.6
var available_energy = 0.001
var consumption = 0

enum types{
	scaffold,
	building,
	war,
	comms,
	capitol,
	ai
}
const type_count = 4

func excess_energy():
	return available_energy - consumption

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
				if(other.tiles[i][j][0] == types.building):
					available_energy += building_energy_worth
	other.reset()
func reset():
	tiles = []
	available_energy = 0.001
	consumption = 0
	_init()

func build(what: int, pos: Vector2i, force = false):
	if otherCity.Get(pos)[0] != -1:
		return
	if force or (what == 0 and Get(pos)[0] == -1) or Get(pos)[0] == 0:
		tilemap.set_cell(0, pos, 0, Vector2(what,0))
		tiles[pos.x][pos.y] = [what, true]
		doparticles(pos)
		if(what == types.building):
			available_energy += building_energy_worth
		if what > 0:
			if what == types.comms:
				get_parent().get_parent().reduce_timer(5)
			consumption += costs[what] if what < 4 else 0.0
			var v = buildtimer.instantiate()
			v.length = build_times[what] if what < 4 else 0.0
			if force:
				v.length = min(v.length, 1)
			effectsNode.add_child(v)
			v.global_position = pos * 16 + Vector2i(32, 32)
			await v.finished
			consumption -= costs[what] if what < 4 else 0.0
			scaffold_from(pos)

func scaffold_from(pos: Vector2i):
	for i in [Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT, Vector2i.UP]:
		if in_bounds(pos + i) and Get(pos + i)[0] < 0:
			build(0, pos + i)


func in_bounds(pos: Vector2i) -> bool:
	return !(pos.x < 0 or pos.y < 0 or pos.x >= 20 or pos.y >= 20)

func destroy(pos: Vector2i, voluntary: bool = false):
	if(voluntary and Get(pos)[0] > 0):
		build(0, pos, true)
	else:
		if(tiles[pos.x][pos.y][0] == types.building):
			available_energy -= building_energy_worth
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
	return []
func GetAI():
	for i in 20:
		for j in 20:
			if(tiles[i][j][0] == types.ai):
				return [Vector2i(i,j)]
	return []


func GetBuildSpots():
	var r = []
	for i in 20:
		for j in 20:
			if(tiles[i][j][0] == types.scaffold):
				r.append(Vector2i(i,j))
	return r
