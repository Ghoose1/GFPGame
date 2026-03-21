## Domino that appears at the start of the level
class_name StarterTile extends Domino

# only one face
var face : Face = Face.new()

const LOOP_MULTIPLIER : float = 1.5

func _ready() -> void:
	face.number = randi_range(1, 6)
	$Sprites/Face_0.texture = Globals.faceSprites[face.number]
	placed = true

func init_connection_points() -> void:
	for i in range(4):
		connection_points.append(ConnectionPoint.new(DirectionVecs[i] * 17, i, [face]))
		connection_points.back().enabled = true

func get_width() -> int: return 2
func get_height() -> int: return 2
func snap_to_point() -> void: pass
func on_placed() -> void: pass

const DirectionVecs : Array[Vector2] = [
	Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT
]

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("Start Score"):
		var score_thing : ScoreThing = (load("res://scenes/score_thing.tscn") as PackedScene).instantiate()
		Globals.board.add_child(score_thing)
		score_thing.start_scoring_animation(self)

		print("Final total: %s" % calculate_score_total())

func calculate_score_total() -> int:
	var connected_tiles : Array[Domino] = get_connected_tiles(self)

	var total : int = 0
	for tile in connected_tiles:
		total += tile.score_value()

	if graph_has_loop(self, -1, []):
		total = int(round(total * LOOP_MULTIPLIER))

	return total

func get_connected_tiles(start_tile : Domino) -> Array[Domino]:
	var out : Array[Domino] = []
	var stack : Array[Domino] = [start_tile]
	var visited_ids : Array[int] = []

	while not stack.is_empty():
		var current : Domino = stack.pop_back()
		var current_id : int = current.get_instance_id()

		if visited_ids.has(current_id):
			continue

		visited_ids.append(current_id)
		out.append(current)

		for next_tile in current.connected_dominos:
			if not visited_ids.has(next_tile.get_instance_id()):
				stack.append(next_tile)

	return out

func graph_has_loop(current_tile : Domino, parent_id : int, visited_ids : Array[int]) -> bool:
	var current_id : int = current_tile.get_instance_id()
	visited_ids.append(current_id)

	for next_tile in current_tile.connected_dominos:
		var next_id : int = next_tile.get_instance_id()

		# ignore the tile we just came from
		if next_id == parent_id:
			continue

		# if we see a visited tile again, we found a loop
		if visited_ids.has(next_id):
			return true

		if graph_has_loop(next_tile, current_id, visited_ids):
			return true

	return false

func score_value() -> int:
	return face.number

func score_animation() -> void:
	pass
