## Domino that appears at the start of the level
class_name StarterTile extends Domino

# only one face
var face : Face = Face.new()

func _ready() -> void:
	face.number = randi_range(0, 5)
	$Face_0.texture = Globals.faceSprites[face.number]
	placed = true

static func max_connection_count() -> int: return 4

const DirectionVecs : Array[Vector2] = [
	Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT
]

func get_connection_points() -> Array[ConnectionPoint]:
	var out : Array[ConnectionPoint] = []
	for i in range(4):
		if (!connected_dirs[i]):
			out.append(ConnectionPoint.new(DirectionVecs[i] * 18, i, [face])) 
	return out

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("Start Score"):
		# basically just search through the graph of connected dominos and add up the values
		# this isn't how scoring will actually work but we can do the animations off of this
		var nodes : Array[Domino] = [ self ]
		var total_score : int = 0
		var nodes_checked : Array[int] = []
		
		while !nodes.is_empty():
			var tile = nodes[0]
			nodes.pop_front()
			nodes.append_array(tile.connected_dominos)
			nodes_checked.append(tile.get_instance_id())
			nodes = nodes.filter(func(n : Node): return !nodes_checked.has(n.get_instance_id()))
			
			var tile_score = tile.score()
			total_score += tile_score
			
			print("Total: %s, +%s" % [total_score, tile_score])
		
		print("Final total: %s" % total_score)

func score() -> int:
	return face.number
