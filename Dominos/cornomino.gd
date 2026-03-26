@tool
class_name Cornomino extends Domino

@export var faces : Array[Face]

func get_width() -> int:
	return 4
func get_height() -> int:
	return 4

var connecting_point : ConnectionPoint

func _ready() -> void:
	for face in faces:
		face.update_frame()

func snap_to_point() -> bool:
	var valid_connection_points : Array[ConnectionPoint] = connection_points.filter(
		func(p : ConnectionPoint) -> bool:
			return Face.can_faces_connect(p.faces, closest_snap_point.faces)
	)

	if valid_connection_points.is_empty():
		return false
	
	connecting_point = valid_connection_points[0]
	var connecting_idx := connection_points.find(connecting_point)

	# rotate to opposite direction
	rotation = ConnectionPoint.direction_rotations[ConnectionPoint.opposite_dir[closest_snap_point.direction]] - ConnectionPoint.direction_rotations[connecting_point.direction]
	
	# rotate by the amount the connecting domino is rotated
	global_rotation += closest_snap_domino.global_rotation
	
	# 'up' now points towards the other
	
	# move so that our connection point would be the same position as their connection point
	global_position = closest_snap_domino.global_position + \
		closest_snap_point.position.rotated(closest_snap_domino.global_rotation) - \
		connecting_point.position.rotated(global_rotation)
	
	const POINT_TO_FACE : int = 16
	
	## move closer to the other domino in order to fully connect
	## basically, we need to move our face to their connection point
	global_position += ConnectionPoint.direction_vecs[closest_snap_point.direction].rotated(closest_snap_domino.global_rotation) * POINT_TO_FACE

	return true

func on_placed() -> void:
	connecting_point.enabled = false

func score_animation() -> void:
	$AnimationPlayer.stop()
	$AnimationPlayer.play("Score")

func score_value() -> int:
	return 0

func rotate_sprites() -> void:
	var base : Sprite2D = $Sprites/Base
	var front : Sprite2D = $Sprites/Front
	
	base.frame = rotation_direction
	front.frame = rotation_direction
