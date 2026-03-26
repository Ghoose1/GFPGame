@tool
## Point that a domino can connect to
class_name ConnectionPoint extends Node2D

## direction from the domino to the point
## Basic dominos will use this to rotate when snapping
@export var direction : Direction
## Faces that this point connects from. Order doesn't matter
@export var faces : Array[Face]
var enabled : bool = false

enum Direction {
	V_UP = 0,
	V_DOWN = 1,
	H_LEFT = 2,
	H_RIGHT = 3,
}

static func round_to_direction(rot : float) -> Direction:
	# magic
	
	# basically normalizes the rotation to 0 < r < 2*PI, then rotates by 45 
	# degrees and rounds down to get the direction
	rot = fmod(rot + PI * 20 + PI / 4, PI * 2)
	if rot < PI / 2: return Direction.V_UP
	if rot < PI: return Direction.H_RIGHT
	if rot < 3 * PI / 2: return Direction.V_DOWN
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
	
	var domino := get_parent().get_parent() as Domino
	draw_rect(Rect2(global_position.rotated(domino.global_rotation) + Vector2(-7.5, -7.5) - position, Vector2(15, 15)), Color.HOT_PINK, false, 1)
	
func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		queue_redraw()
