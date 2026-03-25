class_name Player extends Node

## domino currently being dragged by the player 
## null if none are being dragged.
var held_domino : Domino

var dollars : int = 0:
	get:
		return dollars
	set(value):
		dollars = value
		dollars_changed.emit(dollars)
		
var score : int = 0:
	get:
		return score
	set(value):
		score = value
		score_changed.emit(score)

signal dollars_changed(new_value : int)
signal score_changed(new_value : int)

func _ready() -> void:
	Globals.player = self

	var score_label := $UILayer/Container/Control/ScoreRect/ScoreLabel
	if score_label != null and score_label.has_method("update_value"):
		score_changed.connect(Callable(score_label, "update_value"))
		score_label.update_value(score)

	var dollar_label := $UILayer/Container/Control/DollarRect/DollarLabel
	if dollar_label != null and dollar_label.has_method("update_value"):
		dollars_changed.connect(Callable(dollar_label, "update_value"))
		dollar_label.update_value(dollars)
