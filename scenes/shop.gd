extends Control

const BASIC_DOMINO_SCENE := preload("res://Dominos/basic.tscn")
const CORNOMINO_SCENE := preload("res://Dominos/cornomino.tscn")
const SIX_OF_HEARTS_SCENE := preload("res://Dominos/six_of_hearts.tscn")

const WILD_COST := 5
const MONEY_COST := 4
const SCORE_COST := 6

@onready var money_label: Label = $Panel/MarginContainer/VBoxContainer/MoneyLabel
@onready var close_button: Button = $Panel/MarginContainer/VBoxContainer/HeaderRow/CloseButton

@onready var buy_button_1: Button = $Panel/MarginContainer/VBoxContainer/ItemList/Item1/MarginContainer/Content/BuyButton
@onready var buy_button_2: Button = $Panel/MarginContainer/VBoxContainer/ItemList/Item2/MarginContainer/Content/BuyButton
@onready var buy_button_3: Button = $Panel/MarginContainer/VBoxContainer/ItemList/Item3/MarginContainer/Content/BuyButton

func _ready() -> void:
	hide()
	update_money_label()
	update_buy_buttons()

	if Globals.player != null and !Globals.player.dollars_changed.is_connected(_on_dollars_changed):
		Globals.player.dollars_changed.connect(_on_dollars_changed)

	if close_button != null and !close_button.pressed.is_connected(_on_close_button_pressed):
		close_button.pressed.connect(_on_close_button_pressed)

	if buy_button_1 != null and !buy_button_1.pressed.is_connected(_on_buy_wild_pressed):
		buy_button_1.pressed.connect(_on_buy_wild_pressed)

	if buy_button_2 != null and !buy_button_2.pressed.is_connected(_on_buy_money_pressed):
		buy_button_2.pressed.connect(_on_buy_money_pressed)

	if buy_button_3 != null and !buy_button_3.pressed.is_connected(_on_buy_score_pressed):
		buy_button_3.pressed.connect(_on_buy_score_pressed)

func open_shop() -> void:
	update_money_label()
	update_buy_buttons()
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

func update_buy_buttons() -> void:
	if Globals.player == null:
		return

	if buy_button_1 != null:
		buy_button_1.disabled = Globals.player.dollars < WILD_COST

	if buy_button_2 != null:
		buy_button_2.disabled = Globals.player.dollars < MONEY_COST

	if buy_button_3 != null:
		buy_button_3.disabled = Globals.player.dollars < SCORE_COST

func _on_dollars_changed(_new_value: int) -> void:
	update_money_label()
	update_buy_buttons()

func _on_close_button_pressed() -> void:
	close_shop()

func _on_buy_wild_pressed() -> void:
	if !spend_money(WILD_COST):
		return

	var domino: BasicDomino = BASIC_DOMINO_SCENE.instantiate()
	domino.face0.wild = true
	domino.face1.wild = true
	give_domino_to_player(domino)

func _on_buy_money_pressed() -> void:
	if !spend_money(MONEY_COST):
		return

	var domino: Cornomino = CORNOMINO_SCENE.instantiate()
	give_domino_to_player(domino)

func _on_buy_score_pressed() -> void:
	if !spend_money(SCORE_COST):
		return

	var domino: SixOfHearts = SIX_OF_HEARTS_SCENE.instantiate()
	give_domino_to_player(domino)

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
