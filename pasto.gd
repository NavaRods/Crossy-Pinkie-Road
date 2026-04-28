extends Node3D

@export var escenas: Array[PackedScene]
@export var pesos: Array[int]

# Configuración de la rejilla (Basada en tus medidas 126x7x70)
var tamaño_celda = 7

func _ready():
	# Limpieza de seguridad: Si hay hijos previos, los quitamos
	for n in get_children():
		if n is StaticBody3D: n.queue_free()
	
	generar_decoracion()

func generar_decoracion():
	# Elegimos una "Zona Segura" aleatoria para este carril
	# En lugar de ser siempre Z=0, elegimos una celda al azar entre -35 y 35
	var pasillo_seguro_z = (randi_range(-5, 5)) * 7 
	
	for z_pos in range(-63, 70, 7):
		# Si es la zona segura, o una celda adyacente (para pasillo ancho), no spawneamos
		if z_pos == pasillo_seguro_z or z_pos == pasillo_seguro_z + 7:
			continue
		
		# Probabilidad normal para el resto del carril
		if randf() < 0.4:
			spawn_objeto(z_pos)

func elegir_escena_por_peso() -> PackedScene:
	var total = 0
	for p in pesos: total += p
	
	var r = randi() % total
	var acc = 0
	for i in range(escenas.size()):
		acc += pesos[i]
		if r < acc:
			return escenas[i]
	return escenas[0]

func spawn_objeto(pos_z: float):
	var escena_elegida = elegir_escena_por_peso()
	var instancia = escena_elegida.instantiate()
	add_child(instancia)
	instancia.position = Vector3(0, 0, pos_z)
	instancia.rotation_degrees.y = [0, 90, 180, 270].pick_random()
