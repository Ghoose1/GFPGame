## Point that a domino can connect to
class_name ConnectionPoint extends Node

## Position relative to the domino
##
## This would be the center of a face connecting to this point
var position : Vector2
## direction from the domino
##
## Basic dominos will use this to rotate when snapping
var direction : Direction
## Faces that this point connects from.
var faces : Array[Face]
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
	rot = fmod(rot + PI, PI * 2) + PI / 4
	if rot < PI / 2: return Direction.V_DOWN
	if rot < PI: return Direction.H_RIGHT
	if rot < 3 * PI / 2: return Direction.V_UP
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

func _init(pos : Vector2, dir : Direction, sides : Array[Face]) -> void:
	position = pos
	direction = dir
	faces = sides
