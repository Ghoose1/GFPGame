class_name ScoreThing extends Node2D

const SCORE_MOVE_SPEED : float = 2.0
const SCORE_THING_SCENE : PackedScene = preload("res://scenes/score_thing.tscn")

static var active_runs : int = 0
static var score_total : int = 0

var current_value : int = 0
var current_tile : Domino = null
var next_tile : Domino = null
var visited_tiles : Array[int] = []
var previous_connection : int = -1

func start_scoring_animation(starter : Domino) -> void:
	if active_runs > 0:
		return
		
	active_runs = 0
	score_total = 0

	var connected_count : int = starter.connected_dominos.size()
	if connected_count == 0:
		return

	active_runs = connected_count

	initialize(starter, starter.score_value(), [], -1, starter.connected_dominos[0])

	if connected_count > 1:
		for i in range(1, connected_count):
			var split : ScoreThing = SCORE_THING_SCENE.instantiate()
			get_parent().add_child(split)
			split.initialize(
				starter,
				starter.score_value(),
				[],
				-1,
				starter.connected_dominos[i]
			)

func initialize(
	starter : Domino,
	start_value : int,
	prev_visited : Array[int],
	prev_connection : int,
	_next_tile : Domino
) -> void:
	current_value = start_value
	current_tile = starter
	visited_tiles = prev_visited.duplicate()
	previous_connection = prev_connection
	next_tile = _next_tile

func finish_run() -> void:
	active_runs -= 1
	score_total += current_value
	if active_runs <= 0:
		active_runs = 0
		print("Global score total: ", score_total)
		
	queue_free()

func get_available_tiles() -> Array[Domino]:
	var filtered_tiles : Array[Domino] = []

	for d in current_tile.connected_dominos:
		var tile_id : int = d.get_instance_id()

		if visited_tiles.has(tile_id):
			continue

		filtered_tiles.append(d)

	return filtered_tiles

var timer : float = 0.0

func _process(delta : float) -> void:
	if next_tile == null:
		return

	timer += delta * SCORE_MOVE_SPEED * ((visited_tiles.size() / 4.0) + 1)

	if timer >= 1.0:
		timer = 0.0

		var next_id : int = next_tile.get_instance_id()

		# If another score thing already reached this tile, stop here.
		if visited_tiles.has(next_id):
			finish_run()
			return

		# update data for moving to the next tile
		previous_connection = current_tile.get_instance_id()
		visited_tiles.append(previous_connection)

		current_tile = next_tile
		current_value += current_tile.score_value()

		# restore tile animation
		current_tile.score_animation()

		# restore reward tile dollar gain
		var tile_cords := current_tile.get_tilemap_cords()
		for vec in tile_cords:
			var data : TileData = Globals.board.special_tilemap.get_cell_tile_data(vec)
			if data == null:
				continue
			if data.get_custom_data("is_reward"):
				Globals.player.dollars += 1

		# detect branches, but do not enter tiles already claimed by another score thing
		var filtered_tiles : Array[Domino] = get_available_tiles()
		var filtered_count : int = filtered_tiles.size()

		if filtered_count == 1:
			next_tile = filtered_tiles[0]

		elif filtered_count == 0:
			finish_run()
			return

		elif filtered_count >= 2:
			next_tile = filtered_tiles[0]

			for i in range(1, filtered_count):
				active_runs += 1

				var split : ScoreThing = SCORE_THING_SCENE.instantiate()
				get_parent().add_child(split)
				split.initialize(
					current_tile,
					current_value,
					visited_tiles.duplicate(),
					previous_connection,
					filtered_tiles[i]
				)

	# Actually move the position
	global_position = lerp(current_tile.position, next_tile.position, timer)
