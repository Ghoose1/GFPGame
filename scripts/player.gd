class_name Player extends Node

## domino currently being dragged by the player 
## null if none are being dragged.
var held_domino : Domino

func _ready() -> void:
	Globals.player = self
