@tool
### Note: faces and connection points are not initialised until after init
class_name Nnonimo
extends Domino

var loop_connections : Array[ConnectionPoint]

@export var face_count : int = 3:
	get:
		return face_count
	set(value):
		face_count = value
		init_faces()

func init_faces() -> void:
	if !is_inside_tree():
		return
	
	width = 2
	height = face_count * 2
	
	var sprites_node : Node2D = $Sprites
	var connection_node : Node = $Connections
	var loop_connection_node : Node = $LoopConnections
	
	base_sprites.clear()
	front_sprites.clear()
	
	for child in sprites_node.get_children(true):
		child.free()
	for child in connection_node.get_children(true):
		child.free()
	for child in loop_connection_node.get_children(true):
		child.free()
	
	faces.clear()
	
	for i in range(0, face_count):
		var base := Sprite2D.new()
		var front := Sprite2D.new()
		base.z_index = -1
		var pos := Vector2.DOWN * (i + 0.5 - face_count / 2.0) * 16.0
		base.position = pos
		front.position = pos
		base.texture = preload("res://Assets/N-nomino_Back.png")
		front.texture = preload("res://Assets/N-nomino_Front.png")
		base.region_enabled = true
		front.region_enabled = true
		
		match i + 1:
			1:
				base.region_rect = Rect2(0, 0, 20, 16)
				front.region_rect = Rect2(0, 0, 16, 16)
			face_count:
				base.region_rect = Rect2(0, 30, 20, 20)
				front.region_rect = Rect2(0, 32, 16, 16)
			_:
				base.region_rect = Rect2(0, 16, 20, 16)
				front.region_rect = Rect2(0, 16, 16, 16)
		
		sprites_node.add_child(base)
		sprites_node.add_child(front)
		base_sprites.append(base)
		front_sprites.append(front)
		
		var face : Face = preload("res://scenes/face.tscn").instantiate()
		face.position = base.position
		face.number = 1
		sprites_node.add_child(face, true, Node.INTERNAL_MODE_BACK)
		
		faces.append(face)
	
	for v : Vector2 in [Vector2.UP, Vector2.DOWN]:
		var point := ConnectionPoint.new()
		point.position = (face_count * 8 + 8) * v
		point.direction = ConnectionPoint.Direction.V_UP if int(v.y) == -1 else ConnectionPoint.Direction.V_DOWN
		@warning_ignore("integer_division")
		point.faces = [ faces[(int(v.y) + 1) / 2] ]
		
		connection_node.add_child(point)
		connection_points.append(point)
	
	for i in range(0, face_count):
		var pos := Vector2.DOWN * (i + 1 - face_count / 2.0) * 16.0
		
		if i != face_count - 1:
			for v : Vector2 in [Vector2.LEFT, Vector2.RIGHT]:
				var point := ConnectionPoint.new()
				point.position = pos + v * 16
				point.direction = ConnectionPoint.Direction.H_LEFT if int(v.x) == -1 else ConnectionPoint.Direction.H_RIGHT
				point.faces = [ faces[i], faces[i + 1] ]
				
				connection_node.add_child(point)
				connection_points.append(point)
				loop_connections.append(point)
		
		for v : Vector2 in [Vector2.LEFT, Vector2.RIGHT]:
			var point := ConnectionPoint.new()
			point.position = pos + Vector2.UP * 8 + v * 16
			point.direction = ConnectionPoint.Direction.H_LEFT if int(v.x) == -1 else ConnectionPoint.Direction.H_RIGHT
			point.faces = [ faces[i] ]
			
			loop_connection_node.add_child(point)
			loop_connections.append(point)
	
	queue_redraw()

func get_rect() -> Rect2:
	return Rect2(-8, (face_count / 2.0) * -16, 16, face_count * 16)

func _ready() -> void:
	init_faces()

#func get_tilemap_cords() -> Array[Vector2i]:
	#var tilemap : TileMapLayer = Globals.board.domino_tilemap
	#var out : Array[Vector2i] = []
	#var center_tile : Vector2i = tilemap.local_to_map(tilemap.to_local(global_position))
	#
	## loop over each face and add 2x2 tiles
	#for i : int in range(face_count):
		#var Ivec : Vector2i = Vector2i(0, i * 2 - face_count)
		## loop over each tile in the quadrant
		#for j : int in range(4):
			#out.append(center_tile + Vector2i(floor(j / 2.0) - 1, (j % 2) - 1) + Ivec)
	#
	#return out

func get_loop_connection_points() -> Array[ConnectionPoint]:
	return loop_connections
	
func score_animation() -> void:
	$AnimationPlayer.stop()
	$AnimationPlayer.play("Score")

var base_sprites : Array[Sprite2D] = [ ]
var front_sprites : Array[Sprite2D] = [ ]
func rotate_sprites() -> void:	
	for i in range(face_count):
		var base := base_sprites[i]
		var front := front_sprites[i]
		
		match i + 1:
			1:
				if rotation_direction == ConnectionPoint.Direction.V_DOWN or rotation_direction == ConnectionPoint.Direction.H_RIGHT:
					base.region_rect = Rect2(0, 32, 20, 20)
					front.region_rect = Rect2(0, 32, 16, 16) 
				else:
					base.region_rect = Rect2(0, 2, 20, 16)
					front.region_rect = Rect2(0, 0, 16, 16)
			face_count:
				if rotation_direction == ConnectionPoint.Direction.V_DOWN or rotation_direction == ConnectionPoint.Direction.H_RIGHT:
					base.region_rect = Rect2(0, 2, 20, 16)
					front.region_rect = Rect2(0, 0, 16, 16)
				else:
					base.region_rect = Rect2(0, 32, 20, 20)
					front.region_rect = Rect2(0, 32, 16, 16) 
		
		rotate_basic_sprite(base, rotation_direction)
		rotate_basic_sprite(front, rotation_direction)
