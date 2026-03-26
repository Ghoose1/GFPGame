extends CanvasLayer

@onready var score_button: TextureButton = $Container/Control/ScoreButton

func _ready() -> void:
	if score_button != null:
		score_button.pressed.connect(_on_score_button_pressed)

func _on_score_button_pressed() -> void:
	var starter := Globals.board.get_node_or_null("Starter")
	if starter != null and starter.has_method("trigger_score"):
		starter.trigger_score()
