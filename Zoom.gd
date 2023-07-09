extends TileMap
@export var playerCity: City
@export var enemyCity: City

func FinalZoomOut():
	get_node("AnimationPlayer").play("ZoomOut")

func ZoomOut():
	get_node("AnimationPlayer").play("ZoomOut")
	await get_tree().create_timer(2).timeout

	var copy = duplicate()
	add_sibling(copy)
	
	copy.set_script("")
	for i in copy.get_children():
		i.free()
	
	get_node("AnimationPlayer").play("RESET")
	playerCity.reset()
	enemyCity.reset()

	var best_tiles = {}
	for i in 20:
		for j in 20:
			#find original 4 tiles
			var tiles = []
			for k in tiles_of(i, j):
				tiles.append(get_cell_atlas_coords(0, k).x)
			#choose the best tile
			var best_tile = -1
			if tiles.count(playerCity.types.building) > 0:
				best_tile = playerCity.types.building
			if tiles.count(playerCity.types.war) > 0 and  tiles.count(playerCity.types.war) >  tiles.count(playerCity.types.building):
				best_tile = playerCity.types.war
			if tiles.has(playerCity.types.capitol):
				best_tile = playerCity.types.capitol
			if tiles.has(playerCity.types.ai):
				best_tile = playerCity.types.ai
				best_tiles[Vector2i(i+1, j)] = playerCity.types.comms
				best_tiles[Vector2i(i-1, j)] = playerCity.types.comms
				best_tiles[Vector2i(i, j+1)] = playerCity.types.comms
				best_tiles[Vector2i(i, j-1)] = playerCity.types.comms
			#build it
			if best_tile > 0:
				best_tiles[Vector2i(i, j)] = best_tile


	clear()
	for key in best_tiles:
		build(best_tiles[key], key)

	await get_tree().create_timer(1).timeout
	copy.queue_free()



func build(what, where):
	await get_tree().create_timer(randf()).timeout
	playerCity.build(what, where, true)


func tiles_of(x: int, y: int):
	var start = Vector2i(x, y) * 2 - Vector2i(10, 10)
	var r = []
	for i in 2:
		for j in 2:
			r.append(start + Vector2i(i, j))
	return r
