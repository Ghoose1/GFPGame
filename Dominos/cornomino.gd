@tool
class_name Cornomino extends Domino

@export var faces : Array[Face]

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

func get_tilemap_cords() -> Array[Vector2i]:
	var tilemap : TileMapLayer = Globals.board.domino_tilemap
	var out : Array[Vector2i] = []
	var center_tile : Vector2i = tilemap.local_to_map(tilemap.to_local(global_position))
	
	# loop over each 'quadrant' of the 4x4 tile area
	for i : int in range(4):
		# if this quadrant is the one without a face, continue
		if i == rotation_direction:
			continue
		
		var Ivec : Vector2i = Vector2i(floor(i / 2.0) * 2 - 1, (i % 2) * 2 - 1)
		# loop over each tile in the quadrant
		for j : int in range(4):
			out.append(center_tile + Vector2i(floor(j / 2.0) - 1, (j % 2) - 1) + Ivec)
	
	return out
