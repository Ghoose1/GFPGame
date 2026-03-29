## Domino that appears at the start of the level
@tool
class_name StarterTile
extends Domino

# only one face
@export var face : Face

const LOOP_MULTIPLIER : float = 1.5

func _ready() -> void:
	super()
	
	for point in connection_points:
		point.enabled = true
	placed = true
	
	if Engine.is_editor_hint():
		return
	face.number = randi_range(1, 6)
	face.update_frame()

func trigger_score() -> void:
	Globals.player.dollars = 0
	Globals.player.score = 0
	
	var score_thing : ScoreThing = (load("res://scenes/score_thing.tscn") as PackedScene).instantiate()
	Globals.board.add_child(score_thing)
	score_thing.start_scoring_animation(self)

	print("Final total: %s" % calculate_score_total())

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("Start Score"):
		trigger_score()

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
	return face.get_score()

func score_animation() -> void:
	pass

@onready var sprites : Array[Sprite2D] = [ $Sprites/Base, $Sprites/Front ]
func rotate_sprites() -> void:
	for sprite : Sprite2D in sprites:
		rotate_basic_sprite(sprite, rotation_direction)
