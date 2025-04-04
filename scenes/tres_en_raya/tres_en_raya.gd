extends Control

@export var tic_texture: Texture2D
@export var toe_texture: Texture2D

signal piece_dropped(index: int, player: String)

var current_player: String = "X"
var board: Array[String] = []

func _ready() -> void:
	board.resize(9)
	for i in board.size():
		board[i] = ""
		var button := $GridContainer.get_child(i)
		button.pressed.connect(_on_button_pressed.bind(i))

func _on_button_pressed(index: int) -> void:
	if board[index] != "":
		return

	var button := $GridContainer.get_child(index)
	if current_player == "X":
		button.texture_normal = tic_texture
		board[index] = "X"
	else:
		button.texture_normal = toe_texture
		board[index] = "O"

	piece_dropped.emit(index, current_player)

	if _check_winner(current_player):
		print("¡Ganador: %s!" % current_player)
		_disable_all_buttons()
	else:
		current_player = "O" if current_player == "X" else "X"

func _check_winner(player: String) -> bool:
	var win_positions: Array = [
		[0, 1, 2], [3, 4, 5], [6, 7, 8], # filas
		[0, 3, 6], [1, 4, 7], [2, 5, 8], # columnas
		[0, 4, 8], [2, 4, 6]             # diagonales
	]
	for pos in win_positions:
		if board[pos[0]] == player and board[pos[1]] == player and board[pos[2]] == player:
			return true
	return false

func _disable_all_buttons() -> void:
	for i in board.size():
		$GridContainer.get_child(i).disabled = true
