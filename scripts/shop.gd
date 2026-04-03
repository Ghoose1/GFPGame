extends Control

const BASIC_DOMINO_SCENE := preload("res://Dominos/basic.tscn")
const CORNOMINO_SCENE := preload("res://Dominos/cornomino.tscn")
const LONGNOMINO_SCENE := preload("res://Dominos/n_omino.tscn")

const SHOP_ITEMS := {
	"wild": { "cost": 5 },
	"money": { "cost": 4 },
	"one_four": { "cost": 6 },
}

@onready var money_label: Label = $Panel/MarginContainer/VBoxContainer/MoneyLabel
@onready var close_button: Button = $Panel/MarginContainer/VBoxContainer/HeaderRow/CloseButton

func _ready() -> void:
	hide()
	update_money_label()

	if Globals.player != null and !Globals.player.dollars_changed.is_connected(_on_dollars_changed):
		Globals.player.dollars_changed.connect(_on_dollars_changed)

	if close_button != null and !close_button.pressed.is_connected(_on_close_button_pressed):
		close_button.pressed.connect(_on_close_button_pressed)

func open_shop() -> void:
	update_money_label()
	show()

func close_shop() -> void:
	hide()

func update_money_label() -> void:
	if money_label == null:
		return

	if Globals.player == null:
		money_label.text = "$0"
		return

	money_label.text = "$" + str(Globals.player.dollars)

func _on_dollars_changed(_new_value: int) -> void:
	update_money_label()

func _on_close_button_pressed() -> void:
	close_shop()

func can_afford_item(item_id: String) -> bool:
	if Globals.player == null:
		return false
	if !SHOP_ITEMS.has(item_id):
		return false
	return Globals.player.dollars >= int(SHOP_ITEMS[item_id]["cost"])

func try_buy_item(item_id: String) -> void:
	if !SHOP_ITEMS.has(item_id):
		return

	var cost: int = int(SHOP_ITEMS[item_id]["cost"])
	if !spend_money(cost):
		return

	match item_id:
		"wild":
			var wild_domino: BasicDomino = BASIC_DOMINO_SCENE.instantiate()
			wild_domino.faces[0].wild = true
			wild_domino.faces[1].wild = true
			give_domino_to_player(wild_domino)

		"money":
			var money_domino: Cornomino = CORNOMINO_SCENE.instantiate()
			if money_domino.faces.size() >= 3:
				money_domino.faces[0].number = 1
				money_domino.faces[1].number = 2
				money_domino.faces[2].number = 3
			give_domino_to_player(money_domino)

		"one_four":
			var one_four_domino: Nnonimo = LONGNOMINO_SCENE.instantiate()
			
			give_domino_to_player(one_four_domino)
			one_four_domino.face_count = 4
			for face in one_four_domino.faces:
				face.wild = true

	update_money_label()

func spend_money(cost: int) -> bool:
	if Globals.player == null:
		return false

	if Globals.player.dollars < cost:
		return false

	Globals.player.dollars -= cost
	return true

func give_domino_to_player(domino: Domino) -> void:
	if Globals.board == null:
		push_warning("Board was not ready when trying to give a shop domino.")
		domino.queue_free()
		return

	if Globals.board.hand.size() < Globals.board.HAND_SIZE:
		Globals.board.spawn_in_hand(domino)
	else:
		Globals.board.dominoes.append(domino)
		Globals.board.boxed_dominoes.append(domino)
		Globals.board.box_parent.add_child(domino)
		domino.boxed = true
		Globals.board.box.change_count(
			Globals.board.boxed_dominoes.size(),
			Globals.board.dominoes.size() - 1
		)

	Globals.board.update_hand_domino_target_positions()
