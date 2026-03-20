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
const MIN_SNAP_DIST_SQ : float = 32.0 * 32.0

# Raised from 4.0 so the closing loop piece can connect more reliably
const EXTRA_CONNECT_POS_TOLERANCE_SQ : float = 100.0

func snap_position() -> void:
	closest_domino = null
	closest_point = null
	connecting_face = 0
	
	var other_dominos : Array[Domino] = []
	other_dominos = Globals.board.dominoes.filter(func(d : Domino) -> bool: return d != self)
	
	var closest_distance : float = MIN_SNAP_DIST_SQ
	
	# find the closest snap point out of all the other dominoes
	for other in other_dominos:
		assert(other is BasicDomino or other is StarterTile)
		
		for point in other.connection_points:
			if not point.enabled:
				continue
			
			var pos : Vector2 = other.global_position + point.position.rotated(other.global_rotation)
			var dist : float = global_position.distance_squared_to(pos)
			
			if dist < closest_distance:
				closest_distance = dist
				closest_point = point
				closest_domino = other
	
	if closest_domino != null:
		assert(closest_point != null)
		
		# actually snap to the point
		var face0_valid : bool = closest_point.faces.all(func(f : Face) -> bool: return f.number == face0.number)
		var face1_valid : bool = closest_point.faces.all(func(f : Face) -> bool: return f.number == face1.number)
		
		if face0_valid or face1_valid:
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
				closest_point.position.rotated(closest_domino.global_rotation) - \
				ConnectionPoint.direction_vecs[closest_point.direction].rotated(closest_domino.global_rotation) * 7

func get_point_global_position(point : ConnectionPoint) -> Vector2:
	return global_position + point.position.rotated(global_rotation)

func can_connect_to_faces(face : Array[Face]) -> bool:
	return face.all(func(f : Face) -> bool: return f.number == face0.number) or \
		face.all(func(f : Face) -> bool: return f.number == face1.number)

func domino_accepts_faces(domino : Domino, faces : Array[Face]) -> bool:
	if domino is BasicDomino:
		return (domino as BasicDomino).can_connect_to_faces(faces)

	if domino is StarterTile:
		var starter : StarterTile = domino as StarterTile
		for f in faces:
			if f.number != starter.face.number:
				return false
		return true

	return false

func get_expected_snap_rotation(point : ConnectionPoint, use_face1 : bool, other_rotation : float) -> float:
	var out_rotation : float = 0.0

	match point.direction:
		ConnectionPoint.Direction.V_UP:
			out_rotation = PI
		ConnectionPoint.Direction.V_DOWN:
			out_rotation = 0.0
		ConnectionPoint.Direction.H_LEFT:
			out_rotation = PI / 2.0
		ConnectionPoint.Direction.H_RIGHT:
			out_rotation = -PI / 2.0

	if use_face1:
		out_rotation += PI

	return out_rotation + other_rotation

func get_expected_snap_position(other : Domino, point : ConnectionPoint) -> Vector2:
	return other.global_position + \
		point.position.rotated(other.global_rotation) - \
		ConnectionPoint.direction_vecs[point.direction].rotated(other.global_rotation) * 7

func transform_matches_extra_connection(other : Domino, other_point : ConnectionPoint, use_face1 : bool) -> bool:
	var expected_position : Vector2 = get_expected_snap_position(other, other_point)
	if global_position.distance_squared_to(expected_position) > EXTRA_CONNECT_POS_TOLERANCE_SQ:
		return false

	var expected_direction : ConnectionPoint.Direction = ConnectionPoint.round_to_direction(
		get_expected_snap_rotation(other_point, use_face1, other.global_rotation)
	)
	var current_direction : ConnectionPoint.Direction = ConnectionPoint.round_to_direction(global_rotation)

	return current_direction == expected_direction

func find_best_matching_point(other : Domino, other_point : ConnectionPoint) -> ConnectionPoint:
	if not domino_accepts_faces(self, other_point.faces):
		return null

	var other_point_pos : Vector2 = other.global_position + other_point.position.rotated(other.global_rotation)

	var best_point : ConnectionPoint = null
	var best_dist : float = INF

	for my_point in connection_points:
		if not my_point.enabled:
			continue

		if not domino_accepts_faces(other, my_point.faces):
			continue

		var dist : float = get_point_global_position(my_point).distance_squared_to(other_point_pos)
		if dist < best_dist:
			best_dist = dist
			best_point = my_point

	if best_dist > MIN_SNAP_DIST_SQ:
		return null

	return best_point

func try_connect_extra_neighbours() -> void:
	for other in Globals.board.dominoes:
		if other == self:
			continue
		if not other.placed:
			continue
		if connected_dominos.has(other):
			continue

		for other_point in other.connection_points:
			if not other_point.enabled:
				continue

			var face0_valid : bool = other_point.faces.all(func(f : Face) -> bool: return f.number == face0.number)
			var face1_valid : bool = other_point.faces.all(func(f : Face) -> bool: return f.number == face1.number)

			var matches_current_transform : bool = false

			if face0_valid and transform_matches_extra_connection(other, other_point, false):
				matches_current_transform = true
			elif face1_valid and transform_matches_extra_connection(other, other_point, true):
				matches_current_transform = true

			if not matches_current_transform:
				continue

			var my_point : ConnectionPoint = find_best_matching_point(other, other_point)
			if my_point == null:
				continue

			connect_to(other, my_point)
			other.connect_to(self, other_point)
			break

var connecting_face : int = 0
func on_placed() -> void:
	for point in connection_points:
		point.enabled = true

	# main snapped connection
	connected_dominos.append(closest_domino)
	connection_points[connecting_face].enabled = false
	closest_domino.connect_to(self, closest_point)

	# extra valid touching neighbours for real loops
	try_connect_extra_neighbours()

	placed = true

	var tilemap : TileMapLayer = Globals.board.domino_tilemap
	for vec in get_tilemap_cords():
		tilemap.set_cell(vec, 1, Vector2i.ZERO)

func score_value() -> int:
	return face0.number + face1.number

func score_animation() -> void:
	$AnimationPlayer.stop()
	$AnimationPlayer.play("Score")
