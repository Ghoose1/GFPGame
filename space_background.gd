class_name SpaceBackground extends Control

const GRID_SIZE = 32
const OFFSET_STRENGTH = 0.9

@export var star_textures : Array[Texture2D]
@export var gradient : Gradient
@export var brightness_gradient : Gradient
func _draw() -> void:
	#var zoom := get_viewport().get_camera_2d().zoom
	#var screen_world_pos := get_viewport().get_camera_2d().get_screen_center_position() - (size / zoom / 2)
	var zoom := Vector2.ONE
	var screen_world_pos := Vector2.ZERO
	seed(0)
	
	for x in range((int)(size.x / zoom.x / GRID_SIZE)):
		for y in range((int)(size.y / zoom.y / GRID_SIZE)):
			if randi() % 5 != 0:
				continue
			
			var random_offset := Vector2(randf_range(0, GRID_SIZE), randf_range(0, GRID_SIZE)) * OFFSET_STRENGTH
			var star_pos := Vector2(x, y) * GRID_SIZE + random_offset
			
			var star_size : float = randf_range(0.1, 2.2)
			var star_shape : int = randi_range(0, star_textures.size())
			var star_colour : Color = gradient.sample(randf_range(0, 1))
			star_colour.a = brightness_gradient.sample(randf_range(0, 1)).r
			
			if star_shape < star_textures.size():
				draw_set_transform(star_pos, 0, Vector2.ONE * star_size / 4)
				draw_texture(star_textures[star_shape], Vector2.ZERO, star_colour) 
			else:
				draw_set_transform(Vector2.ZERO)
				draw_circle(star_pos, star_size, star_colour)
			

func _process(_delta: float) -> void:
	#if Engine.is_editor_hint():
	queue_redraw()
