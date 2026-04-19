extends Node

var board : Board
var player : Player
var domino_box : DominoBox
var alt_mode : bool = true

var current_level_scene : Node2D
var is_level_previous : bool = false

var connection_hint_animations_enabled : bool = true

signal score_finished()
