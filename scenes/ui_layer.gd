extends CanvasLayer

@onready var score_button: TextureButton = $Container/Control/VBoxContainer/ScoreButton
@onready var shop_button: TextureButton = $Container/Control/VBoxContainer/ShopButton
@onready var shop: Control = $Shop
@onready var level_complete : Control = $LevelCompleteMenu

func _ready() -> void:
	if score_button != null and !score_button.pressed.is_connected(_on_score_button_pressed):
		score_button.pressed.connect(_on_score_button_pressed)

	if shop_button != null and !shop_button.pressed.is_connected(_on_shop_button_pressed):
		shop_button.pressed.connect(_on_shop_button_pressed)

	if shop != null:
		shop.hide()
	
	Globals.score_finished.connect(_on_score_finished)
	level_complete.hide()

func _on_score_finished() -> void:
	level_complete.show()
	var target_pos := level_complete.global_position
	level_complete.global_position = target_pos + Vector2.DOWN * 300
	var tween := level_complete.create_tween()
	tween.tween_property(level_complete, "global_position", target_pos, 0.2)

func _on_score_button_pressed() -> void:
	if Globals.board == null:
		push_warning("Score button pressed before board was ready.")
		return

	var starter: Node = Globals.board.get_node_or_null("Starter")
	if starter != null and starter.has_method("trigger_score"):
		starter.trigger_score()

func _on_shop_button_pressed() -> void:
	if shop != null and shop.has_method("open_shop"):
		shop.open_shop()
