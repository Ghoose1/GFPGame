@tool
extends Control

@export var digit_width: int = 16
@export var digit_height: int = 15
@export var digit_count: int = 4
@export var start_offset: Vector2 = Vector2.ZERO
@export var digit_spacing: int = 22

var value: int = 0
var digit_sprites: Array[Sprite2D] = []

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	for i in range(digit_count):
		var sprite : Sprite2D = preload("res://scenes/digit.tscn").instantiate()
		
		sprite.position = start_offset + Vector2(i * digit_spacing, 0)
		add_child(sprite)
		digit_sprites.append(sprite)

	update_value(0)

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		queue_redraw()

func _draw() -> void:
	if !Engine.is_editor_hint():
		return
	for i in range(digit_count):
		draw_rect(Rect2(i * digit_spacing + start_offset.x, 0 + start_offset.y, digit_width, digit_height), Color.RED, false)

func update_value(new_value: int) -> void:
	value = max(new_value, 0)

	var max_value := int(pow(10, digit_count)) - 1
	if value > max_value:
		value = max_value

	var text_value := str(value).lpad(digit_count, "0")

	for i in range(digit_count):
		var digit := int(text_value[i])
		digit_sprites[i].frame = digit
