extends Area3D

@export var puntos_valor: int = 1
var tiempo: float = 0

var posicion_inicial_y: float

func _ready():
	posicion_inicial_y = global_position.y

func _process(delta):
	tiempo += delta
	
	# Rotación (Gira sobre su eje Y)
	rotate_y(deg_to_rad(90) * delta) # 90 grados por segundo
	
	# Flote (Sube y baja suavemente)
	# La función sin() devuelve valores entre -1 y 1
	position.y = 1.2 + sin(tiempo * 3.0) * 0.2

func recolectar():
	var usuario = GameManager.nombre_usuario_actual
	
	if usuario == "":
		print("Error: No hay un usuario activo.")
		queue_free()
		return

	# Sumamos la manzana a la variable temporal de la partida
	# Esto hará que se vea reflejado en la UI inmediatamente
	GameManager.manzanas_recolectadas += 1
	
	print("¡Manzana recolectada! En esta partida llevas: ", GameManager.manzanas_recolectadas)
	
	# Desaparece la manzana de la escena
	queue_free()
