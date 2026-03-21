class_name Board extends Node2D

var dominoes : Array[Domino]

@onready var special_tilemap : TileMapLayer = $SpecialTiles
@onready var domino_tilemap : TileMapLayer = $DominoTiles

func _ready() -> void:
	reset_dominoes()
	Globals.board = self

func reset_dominoes() -> void:
	dominoes.clear()
	
	dominoes.append($Starter)
	
	for i in range(1, 7):
		for j in range(1, 7):
			var domino : BasicDomino = preload("res://Dominos/basic.tscn").instantiate()
			domino.position = Vector2(i * 32, j * 32)
			
			domino.face0.number = i
			domino.face1.number = j
			
			dominoes.append(domino)
			add_child(domino)
		
		var wild : BasicDomino = preload("res://Dominos/basic.tscn").instantiate()
		wild.face0.number = i
		wild.face1.wild = true
		
		wild.position = Vector2(i * 32, 7 * 32)
		
		dominoes.append(wild)
		add_child(wild)
