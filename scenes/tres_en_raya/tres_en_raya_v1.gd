extends Control

const o_texture = preload("res://assets/o.png")
const x_texture = preload("res://assets/x.png")

var current_player: String = "X"
var board: Array[String] = []

@onready var buttons: GridContainer = %Buttons


func _ready() -> void:
	board.resize(9)
	for i in board.size():
		board[i] = ""
		var button := buttons.get_child(i)
		button.texture_normal = null
		button.pressed.connect(_on_button_pressed.bind(i))


# Se llama por cada botón pulsado
# recibe el índice del botón (0-8)
func _on_button_pressed(index: int) -> void:
	if board[index] != "":
		return

	var button := buttons.get_child(index)
	
	if current_player == "X":
		button.texture_normal = x_texture
		board[index] = "X"
	else:
		button.texture_normal = o_texture
		board[index] = "O"

	if _check_winner(current_player):
		_disable_all_buttons()
		await get_tree().create_timer(3).timeout
		get_tree().reload_current_scene()
	else:
		current_player = "O" if current_player == "X" else "X"



func _check_winner(player: String) -> bool:
# comprueba si existe alguna de las posibles combinaciones ganadoras
# pej: _check_winner("X")

	var win_positions: Array = [
		[0, 1, 2], [3, 4, 5], [6, 7, 8], # filas
		[0, 3, 6], [1, 4, 7], [2, 5, 8], # columnas
		[0, 4, 8], [2, 4, 6]             # diagonales
	]
	for positions in win_positions:
		if board[positions[0]] == player and board[positions[1]] == player and board[positions[2]] == player:
			fade_pieces(positions)
			return true
	return false


func fade_pieces(winning_positions: Array):
# atenúa las piezas no ganadoras
	for i in board.size():
		if not i in winning_positions:
			var button = buttons.get_child(i)
			create_tween().tween_property(button, "modulate:a", 0.2, 0.5)


func _disable_all_buttons() -> void:
	for button in buttons.get_children():
		button.disabled = true
