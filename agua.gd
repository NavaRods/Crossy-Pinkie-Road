extends CSGBox3D

@export var tronco_escena: PackedScene
@export var manzana_scena: PackedScene
@export var velocidad_min: float = 9.0
@export var velocidad_max: float = 9.0

var velocidad: float
var direccion: int = 1 

# Configuración de la rejilla (coincidero que el mapa son 70 unidades de ancho)
var tamaño_celda: float = 7.0

# Recibimos la dirección obligatoria del Generador
func preparar_carril(dir_obligatoria: int):
	# Si es 0 (porque viene de pasto), entonces sí elegimos azar, 
	# si no, usamos la que nos mandaron.
	print(dir_obligatoria, "Agua")
	if dir_obligatoria != 0:
		direccion = dir_obligatoria
	else:
		direccion = [-1, 1].pick_random()

	velocidad = randf_range(velocidad_min, velocidad_max)
	
	# Iniciar el ritmo de 7 metros
	generar_fila_inicial()
	iniciar_timer_ritmico()

func iniciar_timer_ritmico():
	var timer_ritmo = Timer.new()
	timer_ritmo.name = "TimerRitmo"
	# cambiar el tiempo en cada ciclo
	timer_ritmo.one_shot = true 
	add_child(timer_ritmo)
	timer_ritmo.timeout.connect(spawn_ritmico)
	
	# Iniciamos el primer ciclo
	recalcular_y_lanzar_timer()

func recalcular_y_lanzar_timer():
	var timer = $TimerRitmo
	
	# ELEGIMOS LA DISTANCIA ALEATORIA (en múltiplos de 7)
	# [7, 14, 21] -> Troncos pegados, hueco de 7m, o hueco de 14m
	var distancias_posibles = [7.0, 14.0, 21.0]
	var distancia_elegida = distancias_posibles.pick_random()
	
	# Calculamos el tiempo basado en esa distancia
	timer.wait_time = distancia_elegida / velocidad
	timer.start()

func spawn_ritmico():
	# Aparece el tronco
	var z_inicio = -65.0 * direccion
	instanciar_tronco_en_posicion(z_inicio)
	
	# Preparamos el siguiente tronco con una distancia nueva
	recalcular_y_lanzar_timer()

func generar_fila_inicial():
	# Recorremos el ancho del carril (de -63 a 63) en saltos de 7 o 14
	# Esto asegura que nunca se encimen
	var z_actual = -63.0
	while z_actual < 63.0:
		# Decidimos si en este hueco va un tronco
		# 60% de probabilidad de que haya un tronco
		if randf() < 0.6:
			instanciar_tronco_en_posicion(z_actual)
			# Si ponemos un tronco, saltamos 7 o 14 para dejar espacio
			z_actual += tamaño_celda * [1, 2].pick_random()
		else:
			# Si no ponemos nada, saltamos solo una celda
			z_actual += tamaño_celda

func instanciar_tronco_en_posicion(pos_z: float):
	if not tronco_escena: return
	
	var t = tronco_escena.instantiate()
	
	# Usamos la X de este carril y la Z que le pasamos
	# IMPORTANTE: Usamos 'position' para evitar errores de !is_inside_tree
	t.position = Vector3(global_position.x, 0.6, pos_z)
	
	get_tree().current_scene.add_child.call_deferred(t)
	
	#  LÓGICA PARA MANZANAS EN TRONCOS
	# 0.5% de probabilidad de que el tronco traiga una manzana
	if randf() < 0.05:
		var nueva_manzana = manzana_scena.instantiate()
		t.add_child(nueva_manzana) # La hacemos hija del tronco
		nueva_manzana.position = Vector3(0, 0.8, 0) # Posición local relativa al tronco
	
	if t.has_method("configurar"):
		t.configurar(velocidad, direccion)
