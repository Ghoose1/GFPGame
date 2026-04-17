extends Panel

@export var shop_path: NodePath

@onready var shop: Node = get_node_or_null(shop_path)
@onready var buy_image: TextureRect = get_node_or_null("BuyImage") as TextureRect

var atlas_texture: AtlasTexture
var _hovering_valid_drop: bool = false

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP

	if buy_image != null:
		buy_image.mouse_filter = Control.MOUSE_FILTER_IGNORE
		atlas_texture = buy_image.texture as AtlasTexture

	_update_visual(false)
	set_process(true)

func _process(_delta: float) -> void:
	# When no GUI drag is happening anymore, force the image back.
	if not get_viewport().gui_is_dragging() and _hovering_valid_drop:
		_update_visual(false)

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	var valid: bool = (
		typeof(data) == TYPE_DICTIONARY
		and data.has("type")
		and data["type"] == "shop_item"
		and data.has("item_id")
	)

	_update_visual(valid)
	return valid

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	_update_visual(false)

	if shop == null:
		return

	var valid: bool = (
		typeof(data) == TYPE_DICTIONARY
		and data.has("item_id")
	)

	if !valid:
		return

	if shop.has_method("try_buy_item"):
		shop.try_buy_item(data["item_id"])

func _notification(what: int) -> void:
	if what == NOTIFICATION_DRAG_END:
		_update_visual(false)

func _update_visual(is_valid: bool) -> void:
	_hovering_valid_drop = is_valid

	if atlas_texture == null:
		return

	if is_valid:
		# BUY
		atlas_texture.region = Rect2(0, 32, 244, 32)
	else:
		# DROP HERE TO BUY
		atlas_texture.region = Rect2(0, 0, 244, 32)
