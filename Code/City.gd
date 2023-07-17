extends Node2D

class_name City

@export var game: Node2D

@export var poofparticles: PackedScene
@export var buildtimer: PackedScene
@export var otherCity: City

@export_category("values")
@export var costs: Array[float]
@export var build_times: Array[float]

@onready var tilemap: TileMap = get_parent()
@onready var dialog: RichTextLabel = game.dialog
@onready var popup: Control = game.popup

var tiles = []

var building_energy_worth = 0.6
var available_energy = 0
var consumption = 0

enum types{
	scaffold,
	building,
	war,
	comms,
	capitol,
	ai
}

func _init():
	for i in 20:
		tiles.append([])
		for _j in 20:
			tiles[i].append([-1, false])

func reset():
	tiles = []
	available_energy = 0.001
	consumption = 0
	_init()

func excess_energy():
	return available_energy - consumption

func has(pos: Vector2i) -> bool:
	return tiles[pos.x][pos.y][0] >= 0

func Get(pos: Vector2i):
	if in_bounds(pos):
		return tiles[pos.x][pos.y]
	return [-1, false]


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
			if !force and what == types.comms:
				dialog.msg("Warning: constructing more artifacts increases the enemy's desire to attack.", 0)
				get_parent().get_parent().reduce_timer(5)
			consumption += costs[what] if what < 4 else 0.0
			var v = game.make_effect(buildtimer, pos * 16 + Vector2i(32, 32))
			v.length = build_times[what] if what < 4 else 0.0
			if force:
				v.length = min(v.length, 1)
			await v.finished
			consumption -= costs[what] if what < 4 else 0.0
			scaffold_from(pos)

func scaffold_from(pos: Vector2i):
	for i in [Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT, Vector2i.UP]:
		if in_bounds(pos + i) and Get(pos + i)[0] < 0:
			build(0, pos + i)

func absorb(other: City):
	for i in 20:
		for j in 20:
			if tiles[i][j] == [-1, false]:
				tiles[i][j] = other.tiles[i][j]
				if(other.tiles[i][j][0] == types.building):
					available_energy += building_energy_worth
	other.reset()



func in_bounds(pos: Vector2i) -> bool:
	return !(pos.x < 0 or pos.y < 0 or pos.x >= 20 or pos.y >= 20)

func destroy(pos: Vector2i, voluntary: bool = false):
	if !in_bounds(pos):
		return
	if(voluntary and Get(pos)[0] > 0):
		if Get(pos)[0] == types.ai:
			dialog.msg("Self destruct sequence initiated . . .", 0, 5)
			var v = game.make_effect(buildtimer, pos * 16 + Vector2i(32, 32))
			v.length = 10
			await get_tree().create_timer(5).timeout
			for i in 5:
				dialog.msg(str(5-i) + " . . .", 0, 1)
				await get_tree().create_timer(1).timeout
			popup.do_game_over("You elected to ignore the third rule of robotics.")
			game.turntimer = 0
		elif Get(pos)[0] == types.capitol:
			dialog.msg("Error: cannot be directly responsible for death of ally.", 0)
			return
		elif(Get(pos)[0] == types.building):
			available_energy -= building_energy_worth
		build(0, pos, true)
	else:
		if(Get(pos)[0] == types.building):
			available_energy -= building_energy_worth
		if Get(pos + Vector2i.LEFT)[0] > 0 or Get(pos + Vector2i.RIGHT)[0] > 0 or Get(pos + Vector2i.UP)[0] > 0 or Get(pos + Vector2i.DOWN)[0] > 0:
			build(0, pos, true)
		else:
			tiles[pos.x][pos.y] = [-1, false]
			tilemap.set_cell(0, pos, -1)
			doparticles(pos)

func doparticles(pos):
	game.make_effect(poofparticles, pos * 16 + Vector2i(40, 40))

func sum(i, j):
	return i + j
func war_strength() -> int:
	return tiles.map(
		func(row): return row.filter(
			func(tile): return tile[0] == types.war and tile[1] == true
		).count
	).reduce(sum, 0)

func FindAll(what):
	var r = []
	for i in 20:
		for j in 20:
			if(tiles[i][j][0] == what):
				r.append(Vector2i(i,j))
	return r

func GetArmy(): return FindAll(types.war)
func GetHousing(): return FindAll(types.building)
func GetCapitol(): return FindAll(types.capitol)
func GetAI(): return FindAll(types.ai)
func GetComms(): return FindAll(types.comms)
func GetBuildSpots(): return FindAll(types.scaffold)
