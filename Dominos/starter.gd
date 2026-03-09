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
