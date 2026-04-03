extends SubViewportContainer

@export var item_id: String = ""
@export var cost: int = 0
@export var domino_scene: PackedScene
@export var preview_padding: float = 8.0

@onready var subviewport: SubViewport = $SubViewport
@onready var preview_root: Node2D = $SubViewport/PreviewRoot

var domino_instance: Domino

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	stretch = true
	custom_minimum_size = Vector2(72, 72)

	subviewport.transparent_bg = true
	subviewport.handle_input_locally = false
	subviewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS

	if domino_scene == null:
		return

	domino_instance = domino_scene.instantiate() as Domino
	if domino_instance == null:
		return

	preview_root.add_child(domino_instance)

	_setup_preview_domino()
	_freeze_preview_domino()
	call_deferred("_fit_domino_to_view")

func _setup_preview_domino() -> void:
	if domino_instance == null:
		return

	match item_id:
		"wild":
			if domino_instance is BasicDomino:
				var basic: BasicDomino = domino_instance as BasicDomino
				basic.faces[0].wild = true
				basic.faces[1].wild = true

		"money":
			if domino_instance is Cornomino:
				var corno: Cornomino = domino_instance as Cornomino
				assert(corno.faces.size() == 3)
				for face in corno.faces:
					face.number = 1
					face.gold = true

func _freeze_preview_domino() -> void:
	if domino_instance == null:
		return

	domino_instance.dragged = false
	domino_instance.placed = true
	domino_instance.set_process(false)
	domino_instance.set_process_unhandled_input(false)

func _fit_domino_to_view() -> void:
	if domino_instance == null:
		return

	var rect: Rect2 = _get_visible_rect(domino_instance)
	if rect.size.x <= 0.0 or rect.size.y <= 0.0:
		return

	var view_size: Vector2 = size
	if view_size.x <= 0.0 or view_size.y <= 0.0:
		view_size = Vector2(subviewport.size)
	if view_size.x <= 0.0 or view_size.y <= 0.0:
		view_size = Vector2(72, 72)

	var target_size: Vector2 = view_size - Vector2.ONE * preview_padding * 2.0
	var scale_factor: float = min(
		target_size.x / rect.size.x,
		target_size.y / rect.size.y
	)

	domino_instance.scale = Vector2.ONE * scale_factor

	var scaled_center: Vector2 = (rect.position + rect.size * 0.5) * scale_factor
	domino_instance.position = view_size * 0.5 - scaled_center

func _get_visible_rect(root: Node2D) -> Rect2:
	var sprites: Array[Node] = root.find_children("*", "Sprite2D", true, false)

	var has_rect: bool = false
	var out_rect: Rect2 = Rect2()

	for node in sprites:
		var sprite: Sprite2D = node as Sprite2D
		if sprite == null:
			continue
		if !sprite.visible:
			continue
		if sprite.texture == null:
			continue

		var sprite_rect: Rect2 = sprite.get_rect()
		var xform: Transform2D = root.global_transform.affine_inverse() * sprite.global_transform

		var corners := [
			xform * sprite_rect.position,
			xform * Vector2(sprite_rect.position.x + sprite_rect.size.x, sprite_rect.position.y),
			xform * Vector2(sprite_rect.position.x, sprite_rect.position.y + sprite_rect.size.y),
			xform * (sprite_rect.position + sprite_rect.size),
		]

		var min_x: float = corners[0].x
		var max_x: float = corners[0].x
		var min_y: float = corners[0].y
		var max_y: float = corners[0].y
		for corner: Vector2 in corners:
			min_x = min(min_x, corner.x)
			max_x = max(max_x, corner.x)
			min_y = min(min_y, corner.y)
			max_y = max(max_y, corner.y)

		sprite_rect = Rect2(Vector2(min_x, min_y), Vector2(max_x - min_x, max_y - min_y))

		if !has_rect:
			out_rect = sprite_rect
			has_rect = true
		else:
			out_rect = out_rect.merge(sprite_rect)

	return out_rect

func _get_drag_data(_at_position: Vector2) -> Variant:
	var preview: TextureRect = TextureRect.new()
	preview.texture = subviewport.get_texture()
	preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	preview.custom_minimum_size = Vector2(48, 48)
	preview.size = Vector2(48, 48)

	var wrapper: Control = Control.new()
	wrapper.custom_minimum_size = Vector2(48, 48)
	wrapper.size = Vector2(48, 48)
	wrapper.add_child(preview)
	preview.position = Vector2.ZERO

	set_drag_preview(wrapper)

	return {
		"type": "shop_item",
		"item_id": item_id,
		"cost": cost
	}
