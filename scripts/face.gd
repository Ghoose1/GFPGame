
## The side of a domino.
## Includes information such as symbol displayed (number) and anything needed for
## enhancements and special effects
class_name Face
extends Sprite2D

#region properties

@export var number : int:
	get:
		return number
	set(value):
		if value != number:
			number = value
			update_frame()

# e.g. var is_gold : bool
@export var wild : bool:
	get:
		return wild
	set(value):
		if value != wild:
			wild = value
			update_frame()

#endregion

func _ready() -> void:
	update_frame()

func update_frame() -> void:
	if wild:
		frame = 10
		return
	
	frame = number % 10

func get_score() -> int:
	if wild: return 0
	return number

func can_connect_to(faces : Array[Face]) -> bool:
	if wild:
		return true
	
	return faces.all(func(f : Face) -> bool: 
		return f.number == number || f.wild
	)

static func can_faces_connect(a : Array[Face], b : Array[Face]) -> bool:
	match a.size():
		0:
			return false
		1:
			return a[0].can_connect_to(b)
	
	match b.size():
		0: 
			return false
		1:
			return b[0].can_connect_to(a)
	
	return false
