# Indica que este script hereda (extiende) la funcionalidad de la clase base 'Control' de Godot.
# Los nodos 'Control' se usan principalmente para construir interfaces de usuario (UI).
extends Control

# --- CONSTANTES ---
# Las constantes son valores que no cambiarán durante la ejecución del juego.

# Precarga la textura (imagen) para la ficha 'O'.
# 'preload' carga el recurso cuando el juego se inicia (o el editor lo carga),
# lo que es más eficiente que cargarlo durante el juego con 'load'.
const o_texture = preload("res://assets/o.png")

# Precarga la textura (imagen) para la ficha 'X'.
const x_texture = preload("res://assets/x.png")


# --- VARIABLES DE ESTADO ---
# Estas variables guardan información sobre el estado actual del juego.

# Variable para almacenar qué jugador tiene el turno actual ('X' o 'O').
# Se inicializa con "X", indicando que 'X' empieza la partida.
# El tipo ': String' indica que esta variable siempre guardará texto.
var current_player: String = "X"

# Array (arreglo o lista) para representar el estado del tablero.
# Guardará el contenido de cada una de las 9 casillas.
# Se inicializa como un array vacío, pero se llenará en la función _ready().
# Cada elemento guardará "" (vacío), "X" o "O".
# El tipo ': Array[String]' indica que es un array que contendrá elementos de tipo String.
var board: Array[String] = []


# --- REFERENCIAS A NODOS (@onready) ---
# Variables que contendrán referencias a otros nodos en la escena.
# '@onready' asegura que la asignación se realiza solo cuando el nodo
# referenciado está listo en el árbol de escenas (después de _ready() de los hijos).

# Variable que contendrá una referencia al nodo 'GridContainer' llamado 'Buttons'
# en la escena. Se usa el símbolo '%' para obtener un nodo único por su nombre.
# Asumimos que este GridContainer contiene los 9 botones del tablero.
@onready var buttons: GridContainer = %Buttons


# --- FUNCIONES DE GODOT (_ready) ---
# Funciones especiales que Godot llama automáticamente en ciertos momentos.

# Esta función se ejecuta automáticamente UNA VEZ cuando el nodo (y este script)
# entra en el árbol de la escena y está listo.
# Se usa comúnmente para inicializar variables, configurar conexiones, etc.
# '-> void' indica que esta función no devuelve ningún valor.
func _ready() -> void:
	# Cambia el tamaño del array 'board' para que tenga exactamente 9 elementos.
	# Necesitamos 9 espacios para representar las 9 casillas del tres en raya.
	board.resize(9)

	# Inicia un bucle 'for' que recorrerá los índices del array 'board'.
	# 'board.size()' devuelve 9 (el tamaño actual del array).
	# La variable 'i' tomará los valores 0, 1, 2, ..., hasta 8.
	for i in board.size():
		# Inicializa cada casilla del tablero como vacía.
		# Usamos una cadena de texto vacía ("") para representar que no hay ficha.
		board[i] = ""

		# Obtiene una referencia al nodo hijo número 'i' dentro del GridContainer 'buttons'.
		# Asumimos que los botones están añadidos como hijos directos del GridContainer
		# y en el orden correcto (0 al 8) para que coincidan con los índices del tablero.
		# ':=' es una forma corta de declarar e inferir el tipo de la variable 'button'.
		var button := buttons.get_child(i)

		# Establece la textura normal del botón a 'null' (nada).
		# Esto asegura que los botones aparezcan vacíos al inicio del juego,
		# sin ninguna imagen por defecto.
		button.texture_normal = null

		# Conecta la señal 'pressed' de cada botón con nuestra función '_on_button_pressed'.
		# La señal 'pressed' se emite automáticamente por Godot cuando un botón es pulsado.
		# '.connect()' es el método para establecer esta conexión.
		# '_on_button_pressed' es la función en ESTE script que se ejecutará cuando la señal se emita.
		# '.bind(i)' es MUY IMPORTANTE: pasa el valor actual de 'i' (el índice del botón, 0-8)
		# como argumento a la función '_on_button_pressed' cada vez que ese botón específico sea pulsado.
		# Sin '.bind(i)', no sabríamos qué botón se pulsó dentro de la función.
		button.pressed.connect(_on_button_pressed.bind(i))


# --- FUNCIONES PERSONALIZADAS (Callbacks y Lógica del Juego) ---

# Esta función se llama automáticamente CADA VEZ que uno de los 9 botones es presionado,
# gracias a la conexión hecha en _ready().
# Recibe como argumento el 'index' (0-8) del botón específico que fue pulsado,
# gracias al '.bind(i)' usado en la conexión.
func _on_button_pressed(index: int) -> void:
	# Comprobación inicial: Si la casilla en el tablero (representada por 'board[index]')
	# ya está ocupada (es decir, no es una cadena vacía ""), entonces no hacemos nada.
	# Esto evita que un jugador pueda sobrescribir una ficha ya colocada.
	if board[index] != "":
		# 'return' sale inmediatamente de la función.
		return

	# Si la casilla está libre, continuamos.
	# Obtenemos una referencia al nodo Button específico que fue presionado usando su índice.
	var button := buttons.get_child(index)

	# Comprobamos de quién es el turno actual.
	if current_player == "X":
		# Si es el turno de 'X':
		# 1. Establecemos la textura normal del botón presionado a la imagen de 'X'.
		button.texture_normal = x_texture
		# 2. Actualizamos nuestro array 'board' para registrar que 'X' ha ocupado esta casilla.
		board[index] = "X"
	else:
		# Si no es el turno de 'X', entonces es el de 'O':
		# 1. Establecemos la textura normal del botón presionado a la imagen de 'O'.
		button.texture_normal = o_texture
		# 2. Actualizamos nuestro array 'board' para registrar que 'O' ha ocupado esta casilla.
		board[index] = "O"

	# Después de colocar la ficha y actualizar el tablero, comprobamos si el jugador actual ha ganado.
	# Llamamos a la función '_check_winner' pasándole el jugador que acaba de mover ('current_player').
	if _check_winner(current_player):
		# Si '_check_winner' devuelve 'true' (¡alguien ha ganado!):
		# 1. Llamamos a la función '_disable_all_buttons' para desactivar todos los botones.
		#    Esto evita que se puedan hacer más movimientos después de que termine la partida.
		_disable_all_buttons()

		# 2. Esperamos 3 segundos antes de reiniciar.
		#    'get_tree().create_timer(3)' crea un objeto Timer que emitirá la señal 'timeout' después de 3 segundos.
		#    'await' pausa la ejecución de ESTA función (_on_button_pressed) hasta que esa señal 'timeout' se emita.
		#    Esto da tiempo al jugador a ver la línea ganadora antes de que el juego se reinicie.
		await get_tree().create_timer(3).timeout

		# 3. Recargamos la escena actual.
		#    'get_tree().reload_current_scene()' vuelve a cargar la escena desde el principio,
		#    lo que efectivamente reinicia el juego a su estado inicial.
		get_tree().reload_current_scene()
	else:
		# Si nadie ha ganado después de este movimiento:
		# Cambiamos el turno al otro jugador.
		# Esta es una forma corta (operador ternario) de escribir la lógica if/else:
		# Si 'current_player' es "X", se le asigna "O".
		# Si 'current_player' no es "X" (es decir, es "O"), se le asigna "X".
		current_player = "O" if current_player == "X" else "X"


# Función para comprobar si un jugador específico ha ganado la partida.
# Recibe el símbolo del jugador ('player', que será "X" o "O") como argumento.
# Devuelve 'true' si ese jugador ha ganado, 'false' en caso contrario.
func _check_winner(player: String) -> bool:
	# Definimos todas las posibles combinaciones de índices que forman una línea ganadora.
	# Es un array que contiene otros arrays. Cada sub-array representa una línea.
	var win_positions: Array = [
		[0, 1, 2], [3, 4, 5], [6, 7, 8], # Filas (horizontal)
		[0, 3, 6], [1, 4, 7], [2, 5, 8], # Columnas (vertical)
		[0, 4, 8], [2, 4, 6]             # Diagonales
	]

	# Recorremos cada una de las combinaciones ganadoras definidas arriba.
	# En cada iteración, 'positions' será uno de los sub-arrays (ej: [0, 1, 2]).
	for positions in win_positions:
		# Comprobamos si las TRES casillas correspondientes a los índices en 'positions'
		# dentro de nuestro tablero 'board' contienen el símbolo del jugador ('player')
		# que estamos verificando.
		if board[positions[0]] == player and board[positions[1]] == player and board[positions[2]] == player:
			# Si las tres casillas coinciden con el jugador, ¡hemos encontrado una línea ganadora!
			# Llamamos a la función 'fade_pieces' para aplicar un efecto visual,
			# pasando las posiciones de las fichas ganadoras.
			fade_pieces(positions)
			# Devolvemos 'true' inmediatamente, ya que hemos confirmado una victoria.
			return true

	# Si hemos recorrido todas las combinaciones ('win_positions') y ninguna coincidió
	# con el jugador, significa que ese jugador no ha ganado (aún).
	# Devolvemos 'false'.
	return false


# Función para aplicar un efecto visual cuando alguien gana:
# Atenúa (hace semitransparentes) las fichas que NO forman parte de la línea ganadora.
# Recibe como argumento 'winning_positions', que es el array con los 3 índices de la línea ganadora.
func fade_pieces(winning_positions: Array):
	# Recorremos todos los índices del tablero, del 0 al 8.
	for i in board.size():
		# Comprobamos si el índice actual 'i' NO está incluido en la lista de 'winning_positions'.
		# Es decir, si esta casilla NO es parte de la línea ganadora.
		if not i in winning_positions:
			# Si no es una ficha ganadora:
			# 1. Obtenemos el nodo Button correspondiente a este índice 'i'.
			var button = buttons.get_child(i)
			# 2. Creamos una animación usando Tween.
			#    'create_tween()' crea un objeto Tween temporal para esta animación.
			#    '.tween_property()' define qué animar:
			#      - 'button': el objeto a animar.
			#      - '"modulate:a"': la propiedad a animar. 'modulate' es un color que multiplica
			#        la textura del botón. ':a' se refiere al canal alfa (transparencia) de ese color.
			#        Un valor de 1 es totalmente opaco, 0 es totalmente transparente.
			#      - 0.2: el valor final al que queremos llegar (20% de opacidad, bastante transparente).
			#      - 0.5: la duración de la animación en segundos (medio segundo).
			create_tween().tween_property(button, "modulate:a", 0.2, 0.5)


# Función sencilla para desactivar todos los botones del tablero.
# Se usa cuando el juego termina (alguien gana) para evitar más clics.
func _disable_all_buttons() -> void:
	# Recorremos todos los nodos hijos directos del GridContainer 'buttons'.
	# Asumimos que todos los hijos son los botones del tablero.
	for button in buttons.get_children():
		# Establecemos la propiedad 'disabled' de cada botón a 'true'.
		# Un botón desactivado no responde a los clics y puede cambiar su apariencia (generalmente se atenúa).
		button.disabled = true
