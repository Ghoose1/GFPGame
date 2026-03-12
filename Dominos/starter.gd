## Domino that appears at the start of the level
class_name StarterTile extends Domino

# only one face
var face : Face = Face.new()

func _ready() -> void:
	face.number = randi_range(1, 6)
	$Face_0.texture = Globals.faceSprites[face.number]
	placed = true

func init_connection_points() -> void:
	for i in range(4):
		connection_points.append(ConnectionPoint.new(DirectionVecs[i] * 17, i, [face])) 
		connection_points.back().enabled = true

func get_width() -> int: return 2
func get_height() -> int: return 2
func snap_position() -> void: pass

const DirectionVecs : Array[Vector2] = [
	Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT
]

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("Start Score"):
		var score_thing : ScoreThing = (load("res://scenes/score_thing.tscn") as PackedScene).instantiate()
		Globals.board.add_child(score_thing)
		score_thing.start_scoring_animation(self)
		
		print("Final total: %s" % simulate_score(self, 0, [ ]))

func simulate_score(current_tile : Domino, current_score : int, visited_tiles : Array[int]) -> int:
	var filtered_tiles := current_tile.connected_dominos.filter(
		func(d : Domino) -> bool: 
			return !visited_tiles.has(d.get_instance_id())
	)
	
	current_score += current_tile.score_value()
	var filtered_count := filtered_tiles.size()
	if filtered_count == 0:
		return current_score
	
	var result := 0
	visited_tiles.append(current_tile.get_instance_id())
	for i in range(0, filtered_count):
		result += simulate_score(filtered_tiles[i], current_score, visited_tiles.duplicate())
	
	return result

func score_value() -> int:
	return face.number
