class_name ScoreThing
extends Node2D

const SCORE_MOVE_SPEED : float = 2.0
const SCORE_THING_SCENE : PackedScene = preload("res://scenes/score_thing.tscn")

static var active_runs : int = 0
static var globally_claimed_tiles : Array[int] = []
static var final_total_to_apply : int = 0

var current_value : int = 0
var current_tile : Domino = null
var next_tile : Domino = null
var visited_tiles : Array[int] = []
var previous_connection : int = -1

func start_scoring_animation(starter : Domino) -> void:
	if active_runs > 0:
		return

	active_runs = 0
	globally_claimed_tiles.clear()
	globally_claimed_tiles.append(starter.get_instance_id())
	final_total_to_apply = 0

	if starter is StarterTile:
		final_total_to_apply = (starter as StarterTile).calculate_score_total()
		SoundManager.play_score()

	var connected_count : int = starter.connected_dominos.size()
	if connected_count == 0:
		queue_free()
		return

	initialize(starter, starter.score_value(), [], -1, starter.connected_dominos[0])
	active_runs = 1

	if connected_count > 1:
		for i in range(1, connected_count):
			active_runs += 1
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

	# Keep the score thing color/frame change from score_thing.png
	($Sprite2D as Sprite2D).frame = active_runs % 8

	# Spawn it on the current tile straight away
	global_position = current_tile.position

func finish_run() -> void:
	active_runs -= 1

	if active_runs <= 0:
		active_runs = 0
		print("Global score total: ", final_total_to_apply)
		Globals.player.score += final_total_to_apply
		globally_claimed_tiles.clear()
		final_total_to_apply = 0
		Globals.score_finished.emit()

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

		# update data for moving to the next tile
		previous_connection = current_tile.get_instance_id()
		visited_tiles.append(previous_connection)

		current_tile = next_tile
		var current_id : int = current_tile.get_instance_id()

		# Only trigger score-like side effects once globally
		var first_global_visit : bool = !globally_claimed_tiles.has(current_id)
		if first_global_visit:
			current_value += current_tile.score_value()
			globally_claimed_tiles.append(current_id)

			# keep domino tile animation
			current_tile.score_animation()
			current_tile.score_extras()

			# keep reward tile dollar gain once
			var tile_cords := current_tile.get_tilemap_cords()
			for vec in tile_cords:
				var data : TileData = Globals.board.special_tilemap.get_cell_tile_data(vec)
				if data == null:
					continue
				if data.get_custom_data("is_reward"):
					Globals.player.dollars += 1

		# keep moving based on this score thing's own visited path
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
