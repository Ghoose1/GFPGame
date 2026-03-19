class_name ScoreThing extends Node2D

const SCORE_THING_SCENE := preload("res://scenes/score_thing.tscn")
const SCORE_MARKER_SCENE := preload("res://scenes/domino_score_animation.tscn")
const SCORE_MOVE_SPEED : float = 1.0

static var active_runs : int = 0

var current_value : int = 0
var current_tile : Domino = null
var next_tile : Domino = null
var visited_tiles : Array[int] = []
var visited_tile_nodes : Array[Domino] = []
var previous_connection : int = -1

func start_scoring_animation(starter : Domino) -> void:
	DominoScoreAnimation.sync_started_ms = Time.get_ticks_msec()
	DominoScoreAnimation.cleanup_at_ms = -1
	clear_old_markers()

	active_runs = 1

	var connected_count : int = starter.connected_dominos.size()
	if connected_count != 0:
		initialize(starter, starter.score_value(), [], [], -1, starter.connected_dominos[0])

		if connected_count > 1:
			for i in range(1, connected_count):
				active_runs += 1

				var split : ScoreThing = SCORE_THING_SCENE.instantiate()
				get_parent().add_child(split)
				split.initialize(
					current_tile,
					current_value,
					visited_tiles.duplicate(),
					visited_tile_nodes.duplicate(),
					previous_connection,
					starter.connected_dominos[i]
				)

func initialize(
	starter : Domino,
	start_value : int,
	prev_visited : Array[int],
	prev_visited_nodes : Array[Domino],
	prev_connection : int,
	_next_tile : Domino
) -> void:
	current_value = start_value
	current_tile = starter
	visited_tiles = prev_visited.duplicate()
	visited_tile_nodes = prev_visited_nodes.duplicate()
	previous_connection = prev_connection
	next_tile = _next_tile

	for tile : Domino in visited_tile_nodes:
		ensure_marker(tile)
		update_marker_visual(tile)

	ensure_marker(current_tile)
	update_marker_visual(current_tile)

func clear_old_markers() -> void:
	for node in get_tree().get_nodes_in_group("domino_score_animation"):
		node.queue_free()

func ensure_marker(tile : Domino) -> DominoScoreAnimation:
	var marker : DominoScoreAnimation = find_marker_for_tile(tile)

	if marker == null:
		marker = SCORE_MARKER_SCENE.instantiate()
		Globals.board.add_child(marker)
		marker.setup_for_tile(tile)

	return marker

func find_marker_for_tile(tile : Domino) -> DominoScoreAnimation:
	for node in get_tree().get_nodes_in_group("domino_score_animation"):
		var marker := node as DominoScoreAnimation
		if marker != null and marker.tile_id == tile.get_instance_id():
			return marker

	return null

func update_marker_visual(tile : Domino) -> void:
	var marker : DominoScoreAnimation = find_marker_for_tile(tile)
	if marker == null:
		return

	marker.set_visual_for_tile(tile)

func finish_run() -> void:
	active_runs -= 1

	if active_runs <= 0:
		active_runs = 0
		DominoScoreAnimation.cleanup_at_ms = Time.get_ticks_msec() + 1000

	queue_free()

var timer : float = 0.0

func _process(delta : float) -> void:
	timer += delta * SCORE_MOVE_SPEED

	if timer >= 1.0:
		timer = 0.0

		previous_connection = current_tile.get_instance_id()
		visited_tiles.append(current_tile.get_instance_id())
		visited_tile_nodes.append(current_tile)

		current_tile = next_tile
		current_value += current_tile.score_value()
		ensure_marker(current_tile)
		update_marker_visual(current_tile)

		var tile_cords := current_tile.get_tilemap_cords()
		for vec in tile_cords:
			var data : TileData = Globals.board.special_tilemap.get_cell_tile_data(vec)
			if data == null:
				continue
			if data.get_custom_data("is_reward"):
				Globals.player.dollars += 1

		var filtered_tiles := current_tile.connected_dominos.filter(
			func(d : Domino) -> bool:
				return !visited_tiles.has(d.get_instance_id())
		)
		var filtered_count : int = filtered_tiles.size()

		if filtered_count == 1:
			next_tile = filtered_tiles[0]

		elif filtered_count == 0:
			print("Final score: ", current_value)
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
					visited_tile_nodes.duplicate(),
					previous_connection,
					filtered_tiles[i]
				)

	global_position = lerp(current_tile.position, next_tile.position, timer)
