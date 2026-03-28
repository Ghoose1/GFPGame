extends Node2D

@export var digits_texture: Texture2D
@export var digit_width: int = 16
@export var digit_height: int = 15
@export var digit_count: int = 4
@export var start_offset: Vector2 = Vector2(82, 16)
@export var digit_spacing: int = 22

var value: int = 0
var digit_sprites: Array[Sprite2D] = []

func _ready() -> void:
	for i in range(digit_count):
		var sprite := Sprite2D.new()
		sprite.texture = digits_texture
		sprite.region_enabled = true
		sprite.centered = false
		sprite.position = start_offset + Vector2(i * digit_spacing, 0)
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		add_child(sprite)
		digit_sprites.append(sprite)

	update_value(0)

func update_value(new_value: int) -> void:
	value = max(new_value, 0)

	var max_value := int(pow(10, digit_count)) - 1
	if value > max_value:
		value = max_value

	var text_value := str(value).lpad(digit_count, "0")

	for i in range(digit_count):
		var digit := int(text_value[i])
		digit_sprites[i].region_rect = Rect2(
			digit * digit_width,
			0,
			digit_width,
			digit_height
		)
