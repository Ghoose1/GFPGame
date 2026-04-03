extends TextureRect

const DEFAULT_ICON := preload("res://Assets/NewBasic_Front.png")

@export var item_id: String = ""
@export var cost: int = 0

func _ready() -> void:
	texture = DEFAULT_ICON
	expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

func _get_drag_data(_at_position: Vector2) -> Variant:
	var preview := TextureRect.new()
	preview.texture = texture
	preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	preview.custom_minimum_size = Vector2(48, 48)

	var wrapper := Control.new()
	wrapper.custom_minimum_size = Vector2(48, 48)
	wrapper.add_child(preview)
	preview.position = Vector2.ZERO

	set_drag_preview(wrapper)

	return {
		"type": "shop_item",
		"item_id": item_id,
		"cost": cost
	}
