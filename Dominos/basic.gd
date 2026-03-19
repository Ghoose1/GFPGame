@tool
## Basic domino type. Two faces
class_name BasicDomino extends Domino

## 'top' face when in default rotation
var face0 : Face = Face.new()
## 'bottom' face when in default rotation
var face1 : Face = Face.new()

func init_connection_points() -> void:
	connection_points = [
		ConnectionPoint.new(Vector2.UP * 25, ConnectionPoint.Direction.V_UP, [face0]),
		ConnectionPoint.new(Vector2.DOWN * 25, ConnectionPoint.Direction.V_DOWN, [face1]),
		ConnectionPoint.new(Vector2.LEFT * 17, ConnectionPoint.Direction.H_LEFT, [face0, face1]),
		ConnectionPoint.new(Vector2.RIGHT * 17, ConnectionPoint.Direction.H_RIGHT, [face1, face0])
	]

func get_width() -> int: return 2
func get_height() -> int: return 4

func _ready() -> void:
	# initialise the face textures
	$Sprites/Face_0.texture = Globals.faceSprites[face0.number]
	$Sprites/Face_1.texture = Globals.faceSprites[face1.number]

## minimum distance to snap to a connection point
const MIN_SNAP_DIST_SQ = 32 * 32

func snap_position() -> void:
	closest_domino = null
	closest_point = null
	connecting_face = 0
	
	var other_dominos : Array[Domino] = []
	other_dominos = Globals.board.dominoes.filter(func(d : Domino) -> bool: return d != self)
	
	var closest_distance : float = MIN_SNAP_DIST_SQ
	
	# find the closest snap point out of all the other dominoes
	for other in other_dominos:
		assert(other is BasicDomino or StarterTile) # expand this when more logic is added
		
		for point in other.connection_points:
			if not point.enabled: continue
			var pos := other.global_position + point.position.rotated(other.global_rotation)
			var dist := global_position.distance_squared_to(pos)
			
			if dist < closest_distance:
				closest_distance = dist
				closest_point = point
				closest_domino = other
	
	if closest_domino != null:
		assert(closest_point != null)
		
		# actually snap to the point
		var face0_valid : bool = closest_point.faces.all(func(f : Face) -> bool: return f.number == face0.number)
		var face1_valid : bool = closest_point.faces.all(func(f : Face) -> bool: return f.number == face1.number)
		
		if face0_valid || face1_valid:
			# rotate so that face0 'points' towards other domino
			# (remember, closest_point belongs to the other domino, so the direction is reversed)
			match closest_point.direction:
				ConnectionPoint.Direction.V_UP:
					rotation = PI 
				ConnectionPoint.Direction.V_DOWN:
					rotation = 0
				ConnectionPoint.Direction.H_LEFT:
					rotation = PI / 2
				ConnectionPoint.Direction.H_RIGHT:
					rotation = -PI / 2
			
			# flip if face 1 was the connecting face
			if face1_valid:
				connecting_face = 1
				rotation += PI
			
			# snap position and rotation
			global_rotation += closest_domino.global_rotation
			
			global_position = closest_domino.global_position + \
				(closest_point.position).rotated(closest_domino.global_rotation) - \
				ConnectionPoint.direction_vecs[closest_point.direction].rotated(closest_domino.global_rotation) * 7
				

var connecting_face : int = 0
func on_placed() -> void:
	for point in connection_points: 
		point.enabled = true
	connected_dominos.append(closest_domino)
	# this works because the connection point order is ^v<>, and faces are ^ and v,
	# so we can use the same index for both things
	connection_points[connecting_face].enabled = false
	closest_domino.connect_to(self, closest_point)
	placed = true
	
	var tilemap : TileMapLayer = Globals.board.domino_tilemap
	for vec in get_tilemap_cords():
		tilemap.set_cell(vec, 1, Vector2i.ZERO)

func can_connect_to_faces(face : Array[Face]) -> bool:
	return face.all(func(f : Face) -> bool: return f.number == face0.number) || \
		face.all(func(f : Face) -> bool: return f.number == face1.number)

func score_value() -> int:
	return face0.number + face1.number
	
func score_animation() -> void:
	$AnimationPlayer.play("Score")
	
