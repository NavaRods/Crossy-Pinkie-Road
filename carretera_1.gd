extends CSGBox3D

@export var modelos_vehiculos: Array[PackedScene] 

var velocidad_base: float
var direccion: int = 1

func preparar_carril(dir_obligatoria: int):
	print(dir_obligatoria, "Carril")
	# Si recibimos 1 o -1, la usamos. Si recibimos 0, elegimos al azar.
	if dir_obligatoria != 0:
		direccion = dir_obligatoria
	else:
		direccion = [-1, 1].pick_random()
	# Velocidad base del carril
	velocidad_base = randf_range(15.0, 25.0)
	
	iniciar_trafico()

func iniciar_trafico():
	var timer = Timer.new()
	timer.name = "TimerTrafico"
	timer.one_shot = true
	add_child(timer)
	timer.timeout.connect(spawn_vehiculo)
	
	# Primer spawn aleatorio para que no salgan todos a la vez al iniciar
	recalcular_y_esperar(randf_range(0.5, 2.0))

func spawn_vehiculo():
	if modelos_vehiculos.is_empty(): return
	
	# Elegimos un modelo al azar de la lista
	var escena_elegida = modelos_vehiculos.pick_random()
	var vehiculo = escena_elegida.instantiate()
	
	# Posición inicial (fuera de cámara)
	# Usamos la X de la carretera y la Z del borde del mapa
	var z_inicio = -70.0 * direccion
	vehiculo.position = Vector3(global_position.x, 0.5, z_inicio)
	
	# Añadimos a la escena
	get_tree().current_scene.add_child.call_deferred(vehiculo)
	
	# Configurar velocidad
	# Podemos darle un pequeño bono de velocidad si es una Ambulancia, por ejemplo
	var multiplicador = 1.0
	if "Ambulancia" in vehiculo.name or "auto_deportivo" in vehiculo.name:
		multiplicador = 1.8 # Más rápido
	elif "tractor" in vehiculo.name:
		multiplicador = 0.5 # Más lento
		
	# Nota: no siento que funcione, creo que se debe a que la velocidad se define
	# cuando se genera el carril
		
	vehiculo.configurar(velocidad_base * multiplicador, direccion)
	
	# Esperar al siguiente
	recalcular_y_esperar()

func recalcular_y_esperar(tiempo_fijo: float = 0.0):
	var timer = $TimerTrafico
	if tiempo_fijo > 0.0:
		timer.wait_time = tiempo_fijo
	else:
		var distancia = [35.0, 28.0].pick_random()
		timer.wait_time = distancia / velocidad_base
	
	timer.start()
