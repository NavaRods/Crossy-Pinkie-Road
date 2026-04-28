extends Camera3D

@export var base_scroll_speed: float = 2.0  # Velocidad constante hacia adelante
@export var follow_smoothness: float = 2.5   # Qué tan rápido acelera para alcanzarte
@export var death_margin: float = 30.0       # Distancia a la que mueres si te quedas atrás

var offset_x: float
var current_speed: float = 0.0
var start_game: bool = false

func _ready():
	# Esto indica que la camara debe estar al mismo nivel que el Nodo Padre
	# por que cuando la camara es hijo esta hererada los movimientos 
	# por lo que si el jugador gira la camara tambien lo hara
	set_as_top_level(true)
	
	# Calculamos la distancia inicial en X respecto al padre (Player)
	if get_parent():
		offset_x = global_position.x - get_parent().global_position.x
	
	current_speed = base_scroll_speed

func _process(delta):
	var player = get_parent()
	if not player:
		return
		
	if not start_game: return
		
	# Calculamos la posición ideal de la cámara (donde "debería" estar según el player)
	var target_x = player.global_position.x + offset_x
	
	# Lógica de velocidad adaptativa:
	# Si el jugador está por delante de la cámara, la cámara acelera
	if target_x > global_position.x:
		# Suavizamos el seguimiento para que no sea un golpe seco
		global_position.x = lerp(global_position.x, target_x, follow_smoothness * delta)
	
	# Movimiento constante
	# Esto hace que la cámara siempre avance, incluso si tú no lo haces
	global_position.x += base_scroll_speed * delta
	
	# Si la posición de la cámara (menos el offset) supera al jugador por el margen
	# Básicamente: "Si el jugador ya no se ve en pantalla por la izquierda"
	if (global_position.x - offset_x) - player.global_position.x > death_margin:
		die()

func die():
	# Aquí puedes conectar señales o reiniciar, por ahora solo consola:
	print("GAME OVER: El jugador fue alcanzado por el borde de la pantalla")
	await get_tree().create_timer(1.0).timeout
	reiniciar_nivel()

func reiniciar_nivel():
	GameManager.actualizar_puntuacion_final(GameManager.score_actual)
	var ir_escena = preload("res://GameOver.tscn").instantiate()
	get_tree().current_scene.add_child(ir_escena)
