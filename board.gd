class_name Board extends Node2D

var dominoes : Array[Domino]

func _ready():
	reset_dominoes()
	
func reset_dominoes():
	dominoes.clear()
	
	for i in range(0, 6):
		for j in range(0, 6):
			var domino : BasicDomino = preload("res://basic.tscn").instantiate()
			domino.face0 = i
			domino.face1 = j
			
			domino.position = Vector2(i * 32, j * 32)
			
			dominoes.append(domino)
			add_child(domino)
