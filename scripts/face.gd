@tool
## The side of a domino.
## Includes information such as symbol displayed (number) and anything needed for
## enhancements and special effects
class_name Face
extends Sprite2D

static func get_as_atlas(input : Texture2D, rect : Rect2) -> Texture2D:
	var atlas : AtlasTexture = AtlasTexture.new();
	atlas.atlas = input
	atlas.region = rect
	return atlas

static var gold_extra : Texture2D = get_as_atlas(preload("res://Assets/face_extras.png"), Rect2(0, 0, 16, 16))
static var mult_extra : Texture2D = get_as_atlas(preload("res://Assets/face_extras.png"), Rect2(0, 16, 16, 16))

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

@export var gold : bool:
	get:
		return gold
	set(value):
		if value != gold:
			gold = value
			queue_redraw()

var is_mult : bool:
	get:
		return mult > 1;

@export var mult : float = 1: 
	get:
		return mult
	set(value):
		if value != mult:
			mult = value
			queue_redraw()

#endregion

func _ready() -> void:
	update_frame()

func _draw() -> void:
	if gold:
		draw_texture(gold_extra, Vector2.ONE * -8)
	if is_mult:
		draw_texture(mult_extra, Vector2.ONE * -8)

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
