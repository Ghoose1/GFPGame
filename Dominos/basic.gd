@tool
## Basic domino type. Two faces
class_name BasicDomino extends Domino

## 'top' face when in default rotation
var face0 : Face = Face.new()
## 'bottom' face when in default rotation
var face1 : Face = Face.new()

var connecting_face : int = 0

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

func snap_to_point() -> void:
	# check which face we should rotate with
	var face0_valid : bool = face0.can_connect_to(closest_snap_point.faces) 
	var face1_valid : bool = face1.can_connect_to(closest_snap_point.faces)
	
	if face0_valid or face1_valid:
		# rotate so that face0 'points' towards other domino
		# (remember, closest_snap_point belongs to the other domino, so the direction is reversed)
		
		# rotate to opposite direction
		rotation_direction = ConnectionPoint.opposite_dir[closest_snap_point.direction]
		
		# flip if face 1 was the connecting face
		# (face0 is facing 'up' when rotation is 0)
		if face1_valid:
			connecting_face = 1
			rotation += PI
		else:
			connecting_face = 0
		
		# rotate by the amount the connecting domino is rotated
		global_rotation += closest_snap_domino.global_rotation
		
		# move to correct position
		global_position = closest_snap_domino.global_position + \
			closest_snap_point.position.rotated(closest_snap_domino.global_rotation) - \
			ConnectionPoint.direction_vecs[closest_snap_point.direction].rotated(closest_snap_domino.global_rotation) * 7


func on_placed() -> void:
	# this works because the connection point order is ^v<>, and faces are ^ and v,
	# so we can use the same index for both things
	connection_points[connecting_face].enabled = false

func score_value() -> int:
	return face0.number + face1.number
	
func score_animation() -> void:
	$AnimationPlayer.stop()
	$AnimationPlayer.play("Score")
