@tool
class_name SixOfHearts extends Domino

## 'top' face when in default rotation
@export var face : Face

func get_width() -> int: return 2
func get_height() -> int: return 4

var connecting_point : ConnectionPoint

func _ready() -> void:
	connection_points.resize(4)

func snap_to_point() -> bool:
	# check which face we should rotate with
	var face_valid : bool = face.can_connect_to(closest_snap_point.faces) 

	if not face_valid:
		return false
	
	connecting_point = connection_points[connection_points.find_custom(func(p : ConnectionPoint) -> bool: return p.direction == ConnectionPoint.opposite_dir[closest_snap_point.direction])]

	# rotate so that face0 'points' towards other domino
	# (remember, closest_snap_point belongs to the other domino, so the direction is reversed)

	# rotate to opposite direction
	rotation_direction = ConnectionPoint.opposite_dir[closest_snap_point.direction]

	# flip if face 1 was the connecting face
	# (face0 is facing 'up' when rotation is 0)

	# rotate by the amount the connecting domino is rotated
	global_rotation += closest_snap_domino.global_rotation

	# move to correct position
	global_position = closest_snap_domino.global_position + \
		closest_snap_point.position.rotated(closest_snap_domino.global_rotation) - \
		connecting_point.position.rotated(closest_snap_domino.global_rotation) + \
		ConnectionPoint.direction_vecs[closest_snap_point.direction].rotated(closest_snap_domino.global_rotation) * 18

	return true

func on_placed() -> void:
	pass
	# this works because the connection point order is ^v<>, and faces are ^ and v,
	# so we can use the same index for both things
	#connection_points[connecting_face].enabled = false

func score_value() -> int:
	return 36
	
func score_animation() -> void:
	pass
	#$AnimationPlayer.stop()
	#$AnimationPlayer.play("Score")
