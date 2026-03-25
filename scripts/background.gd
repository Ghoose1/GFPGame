@tool 
extends Node

#var texture_rect_scene : PackedScene = preload("res://scenes/background_texture_rect.tscn") 
@onready var textureRect := $TextureRect

const TEXTURE_RECT_SIZE : Vector2 = Vector2(512, 512)

func _process(_delta: float) -> void:
	
	var viewport := EditorInterface.get_editor_viewport_2d() if Engine.is_editor_hint() else get_viewport()
	var camera := viewport.get_camera_2d()
	if camera == null:
		return;
	
	#var screen_center := camera.get_screen_center_position()
	#var viewport_rect := viewport.get_visible_rect()
	#textureRect.size = viewport_rect.size / camera.zoom
	#textureRect.offset = screen_center - textureRect.size / 2
	#if !textureRect.get_rect().encloses(viewport_rect):
		#print(viewport_rect)
		#print("test")
		#var new_rect := Rect2(screen_center - TEXTURE_RECT_SIZE / 2, TEXTURE_RECT_SIZE)
		#var texture := (textureRect.texture as NoiseTexture2D)
		#var noise := (texture.noise as FastNoiseLite)
		#noise.offset = Vector3(new_rect.position.x, new_rect.position.y, 0)
		#textureRect.position = new_rect.position
		#textureRect.size = new_rect.size
	#else:
		#print("test2")
	
