@tool
class_name SixOfHearts extends Domino

## 'top' face when in default rotation
@export var face : Face

func get_width() -> int: return 10
func get_height() -> int: return 14

var connecting_point : ConnectionPoint

func _ready() -> void:
	connection_points.resize(4)

func snap_to_point() -> bool:
	# check which face we should rotate with
	var face_valid : bool = face.can_connect_to(closest_snap_point.faces) 

	if not face_valid:
		return false
	
	connecting_point = connection_points[connection_points.find_custom(func(p : ConnectionPoint) -> bool: return p.direction == ConnectionPoint.opposite_dir[closest_snap_point.direction])]

	# rotate to opposite direction
	rotation = ConnectionPoint.direction_rotations[ConnectionPoint.opposite_dir[closest_snap_point.direction]] - ConnectionPoint.direction_rotations[connecting_point.direction]


	# rotate by the amount the connecting domino is rotated
	global_rotation += closest_snap_domino.global_rotation

	# move to correct position
	global_position = closest_snap_domino.global_position + \
		closest_snap_point.position.rotated(closest_snap_domino.global_rotation) - \
		connecting_point.position.rotated(closest_snap_domino.global_rotation) + \
		ConnectionPoint.direction_vecs[closest_snap_point.direction].rotated(closest_snap_domino.global_rotation) * 16

	return true

func on_placed() -> void:
	connecting_point.enabled = false

func score_value() -> int:
	return 36
	
func score_animation() -> void:
	$AnimationPlayer.stop()
	$AnimationPlayer.play("Score")

@onready var sprites : Array[Sprite2D] = [ $Sprites/Base, $Sprites/Front ]
func rotate_sprites() -> void:
	rotate_basic_sprite(sprites[0], rotation_direction)
	rotate_basic_sprite(sprites[1], rotation_direction)
	#for sprite : Sprite2D in sprites:
