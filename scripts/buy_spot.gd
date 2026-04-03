extends Panel

@export var shop_path: NodePath

@onready var shop: Node = get_node_or_null(shop_path)
@onready var label: Label = get_node_or_null("BuySpotLabel") as Label

var _hovering_valid_drop: bool = false

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	if label != null:
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
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

	if label == null:
		return

	if is_valid:
		label.text = "DROP TO BUY"
	else:
		label.text = "DROP DOMINO HERE TO BUY"
