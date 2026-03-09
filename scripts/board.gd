class_name Board extends Node2D

var dominoes : Array[Domino]

func _ready():
	reset_dominoes()
	Globals.board = self

func reset_dominoes():
	dominoes.clear()
	
	dominoes.append($Starter)
	
	for i in range(0, 6):
		for j in range(0, 6):
			var domino : BasicDomino = preload("res://Dominos/basic.tscn").instantiate()
			domino.face0.number = i
			domino.face1.number = j
			
			domino.position = Vector2(i * 32, j * 32)
			
			dominoes.append(domino)
			add_child(domino)
