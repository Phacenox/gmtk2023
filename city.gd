extends Node2D

class_name City

@export var buildtimer: PackedScene
@export var costs: Array[int]
@export var build_times: Array[float]
@export var capitol_sprite_id: Vector2i

var tiles = [[]]
var resource

enum types{
	scaffold,
	building,
	war,
	ai,
	capitol
}
const type_count = 4
const capitol_id = 5

func _init():
	for i in 20:
		tiles += []
		for _j in 20:
			tiles[i] += null


func has(pos: Vector2i) -> bool:
	return tiles[pos.x][pos.y] != null

func Get(pos: Vector2i) -> Object:
	return tiles[pos.x][pos.y]

func absorb(other: City):
	for i in 20:
		for j in 20:
			if tiles[i][j] == null:
				tiles[i][j] = other.tiles[i][j]

func build(what: int, pos: Vector2i):
	pass

func complete_all():
	pass

func war_map(i):
	return i.filter(war_filter).count
func war_filter(i):
	return i == types.war
func sum(i, j):
	return i + j
func war_strength() -> int:
	return tiles.map(war_map).reduce(sum,0)