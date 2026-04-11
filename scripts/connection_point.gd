@tool
class_name ConnectionPoint
extends Node2D

@export var direction : Direction
@export var faces : Array[Face]
var enabled : bool = false

enum Direction {
	V_UP = 0,
	V_DOWN = 1,
	H_LEFT = 2,
	H_RIGHT = 3,
}

static func round_to_direction(rot : float) -> Direction:
	rot = fmod(rot + PI * 20 + PI / 4, PI * 2)
	if rot < PI / 2:
		return Direction.V_UP
	if rot < PI:
		return Direction.H_RIGHT
	if rot < 3 * PI / 2:
		return Direction.V_DOWN
	return Direction.H_LEFT

const direction_vecs := [
	Vector2.DOWN,
	Vector2.UP,
	Vector2.RIGHT,
	Vector2.LEFT,
]

const direction_rotations := [
	0, PI, -PI / 2, PI / 2
]

const opposite_dir := [
	Direction.V_DOWN,
	Direction.V_UP,
	Direction.H_RIGHT,
	Direction.H_LEFT,
]

func _init() -> void:
	pass

func init(pos : Vector2, dir : Direction, sides : Array[Face]) -> void:
	position = pos
	direction = dir
	faces = sides

func _draw() -> void:
	if !Engine.is_editor_hint():
		return

	var parent_node := get_parent()
	if parent_node == null:
		return

	var domino_node := parent_node.get_parent() as Domino
	if domino_node == null:
		return

	const colours := [Color.RED, Color.GREEN, Color.BLUE, Color.YELLOW]
	draw_rect(
		Rect2(
			domino_node.position + position.rotated(domino_node.global_rotation) + Vector2(-7.5, -7.5) - position,
			Vector2(15, 15)
		),
		colours[direction],
		false,
		1
	)

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		queue_redraw()

func get_connectable_face_num() -> int:
	# wild = 10
	
	if faces.size() == 1:
		return faces[0].number if !faces[0].wild else 10
	elif (faces.size() == 2 && Face.can_faces_connect([faces[0]], [faces[1]])):
		return faces[0].number if !faces[0].wild else (faces[1].number if !faces[1].wild else 10)
	
	return 10
