@tool
## Basic domino type. Two faces
class_name BasicDomino extends Domino

## 'top' face when in default rotation
@export var face0 : Face
## 'bottom' face when in default rotation
@export var face1 : Face

var connecting_point : ConnectionPoint

func get_width() -> int: return 2
func get_height() -> int: return 4

func _ready() -> void:
	connection_points.resize(4)
	# initialise the face textures
	face0.update_frame()
	face1.update_frame()

func snap_to_point() -> bool:
	# check which face we should rotate with
	var face0_valid : bool = face0.can_connect_to(closest_snap_point.faces) 
	var face1_valid : bool = face1.can_connect_to(closest_snap_point.faces)

	if not (face0_valid or face1_valid):
		return false
	
	connecting_point = connection_points[0] if face0_valid else connection_points[1]

	# rotate so that face0 'points' towards other domino
	# (remember, closest_snap_point belongs to the other domino, so the direction is reversed)

	# rotate to opposite direction
	rotation_direction = ConnectionPoint.opposite_dir[closest_snap_point.direction]

	# flip if face 1 was the connecting face
	# (face0 is facing 'up' when rotation is 0)
	if face1_valid:
		rotation += PI

	# rotate by the amount the connecting domino is rotated
	global_rotation += closest_snap_domino.global_rotation

	# move so that our connection point would be the same position as their connection point
	global_position = closest_snap_domino.global_position + \
		closest_snap_point.position.rotated(closest_snap_domino.global_rotation) - \
		connecting_point.position.rotated(global_rotation)
	
	# move closer to the other domino in order to fully connect
	# basically, we need to move our face to their connection point
	const POINT_TO_FACE : int = 16
	global_position += ConnectionPoint.direction_vecs[closest_snap_point.direction].rotated(closest_snap_domino.global_rotation) * POINT_TO_FACE

	return true

func on_placed() -> void:
	# this works because the connection point order is ^v<>, and faces are ^ and v,
	# so we can use the same index for both things
	connecting_point.enabled = false

func score_value() -> int:
	return face0.get_score() + face1.get_score()
	
func score_animation() -> void:
	$AnimationPlayer.stop()
	$AnimationPlayer.play("Score")
