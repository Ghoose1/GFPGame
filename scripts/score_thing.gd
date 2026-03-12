class_name ScoreThing extends Node2D

var current_value : int = 0
var current_tile : Domino = null
var next_tile : Domino = null
var visited_tiles : Array[int] = []
var previous_connection : int = -1

## Initialises the scoring thing for the starter tile
func start_scoring_animation(starter : Domino) -> void:
	var connected_count := starter.connected_dominos.size()
	if connected_count != 0:
		initialize(starter, starter.score(), [ ], -1, starter.connected_dominos[0])
		
		if connected_count > 1:
			for i in range(1, connected_count):
				var split : ScoreThing = (preload("res://scenes/score_thing.tscn") as PackedScene).instantiate()
				get_parent().add_child(split)
				split.initialize(current_tile, current_value, visited_tiles, previous_connection, starter.connected_dominos[i])

## Initialises the scoring thing for branching tiles
func initialize(starter : Domino, start_value : int, prev_visited : Array[int], prev_connection : int, _next_tile : Domino) -> void:
	current_value = start_value
	current_tile = starter
	visited_tiles = prev_visited
	previous_connection = prev_connection
	next_tile = _next_tile

var timer : float = 0
func _process(delta: float) -> void:
	timer += delta * max(visited_tiles.size() / 2.0, 1)
	
	if timer >= 1:
		timer = 0
		
		# update data for moving to the next tile
		previous_connection = current_tile.get_instance_id()
		visited_tiles.append(current_tile.get_instance_id())
		current_tile = next_tile
		current_value += current_tile.score()
		
		# get tiles that we haven't visited before
		# TODO: loops
		var filtered_tiles := current_tile.connected_dominos.filter(
			func(d : Domino) -> bool: 
				return !visited_tiles.has(d.get_instance_id())
		)
		var filtered_count := filtered_tiles.size()
		
		if filtered_count == 1: # keep following line
			next_tile = filtered_tiles[0]
			
		elif filtered_count == 0: # terminate
			print("Final score: ", current_value)
			queue_free()
			
		elif filtered_count >= 2: # branch
			next_tile = filtered_tiles[0]
			# create several clones for each branch
			for i in range(1, filtered_count):
				var split : ScoreThing = (preload("res://scenes/score_thing.tscn") as PackedScene).instantiate()
				get_parent().add_child(split)
				split.initialize(current_tile, current_value, visited_tiles, previous_connection, filtered_tiles[i])
	
	# move between current and next tiles
	global_position = lerp(current_tile.position, next_tile.position, timer)
