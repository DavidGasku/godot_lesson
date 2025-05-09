extends Control

const o_texture = preload("res://assets/o.png")
const x_texture = preload("res://assets/x.png")

var current_player: String = "X"
var board: Array[String] = []

@onready var buttons: GridContainer = %Buttons


func _ready() -> void:
	reset_game()
	for i in board.size():
		var button := buttons.get_child(i)
		button.pressed.connect(_on_button_pressed.bind(i))


func reset_game() -> void:
	$TiePanel.hide()
	$WinPanel.hide()
	board.resize(9)
	_disable_all_buttons(false)
	for i in board.size():
		board[i] = ""
		var button := buttons.get_child(i)
		button.texture_normal = null
		button.modulate.a = 1.0


# Se llama por cada botón pulsado
# recibe el índice del botón
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
		
	$Sounds/Drop.play()

	if _check_winner(current_player):
		_end_game(current_player)
	elif _check_full_board():
		_end_game("Tie")
	else:
		current_player = "O" if current_player == "X" else "X"


# comprueba si existe alguna de las posibles combinaciones ganadoras
func _check_winner(player: String) -> bool:
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


func _check_full_board() -> bool:
	return board.all(func(cell): return cell != "")


# end game (X, O, Tie)
func _end_game(result: String):
	_disable_all_buttons(true)
	await get_tree().create_timer(1).timeout
	
	if result == "Tie":
		$Sounds/Lose.play()
		_show_tie_panel()
	else:
		$Sounds/Win.play()
		_show_winner_panel(current_player)
	
	await get_tree().create_timer(3).timeout
	reset_game()



# atenúa las piezas no ganadoras
func fade_pieces(winning_positions: Array):
	for i in board.size():
		if not i in winning_positions:
			var button = buttons.get_child(i)
			create_tween().tween_property(button, "modulate:a", 0.2, 0.5)


func _disable_all_buttons(enable: bool) -> void:
	for button in buttons.get_children():
		button.disabled = enable


func _show_winner_panel(winner: String):
	var winner_tex = o_texture if winner == "O" else x_texture
	$WinPanel/HBox/WinnerTex.texture = winner_tex
	$WinPanel.show()
	create_tween().tween_property($WinPanel, "modulate:a", 1.0, 0.3).from(0.0)


func _show_tie_panel():
	$TiePanel.show()
	create_tween().tween_property($TiePanel, "modulate:a", 1.0, 0.3).from(0.0)
