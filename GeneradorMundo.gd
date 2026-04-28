extends Node3D

@onready var sol = $"../DirectionalLight3D"
@onready var ambiente = $"../WorldEnvironment"

@export var carril_pasto: PackedScene
@export var carril_carretera: PackedScene
@export var carril_agua: PackedScene
@export var manzana_scena: PackedScene
@export var meta_scene: PackedScene = preload("res://MetaRecord.tscn")

@export var player: Node3D # Pony 
@export var distancia_renderizado: int = 15 # Cuántos carriles hay hacia adelante
@export var distancia_limpieza: float = 63 # Cuánta distancia atrás borramos

@export var spawn_escena: PackedScene # El punto de Spawn
@export var largo_spawn: int = 5      # Cuántos "carriles" de 7m ocupa el spawn

var lista_escenas: Array[PackedScene] = []
var carriles_activos: Array[Node3D] = []
var proxima_posicion_x: float = 0.0 # Usaremos X o Z según tu configuración de avance

var proxima_direccion_flujo: int = 1

func _ready():
	$"../ServicioTiempo".clima_determinado.connect(_aplicar_configuracion_visual)
	lista_escenas = [carril_pasto, carril_carretera, carril_agua]
	
	generar_spawn()
	crear_linea_de_meta_global()
	# Generamos el resto aleatorio
	for i in range(distancia_renderizado - 5):
		generar_carril_aleatorio()

func _process(_delta):
	if player:
		# Si el jugador se acerca al final de los carriles generados, creamos más
		if player.global_position.x > proxima_posicion_x - (distancia_renderizado * 7.0):
			generar_carril_aleatorio()
			limpiar_carriles_viejos()

func _aplicar_configuracion_visual(estado):
	var t = create_tween()
	match estado:
		"mañana":
			t.tween_property(sol, "light_color", Color(1, 0.9, 0.7), 2.0)
			t.parallel().tween_property(sol, "light_energy", 0.9, 2.0)
		"dia":
			t.tween_property(sol, "light_color", Color(1, 1, 1), 2.0)
			t.parallel().tween_property(sol, "light_energy", 1.2, 2.0)
		"tarde":
			t.tween_property(sol, "light_color", Color(1, 0.7, 0.4), 2.0)
			t.parallel().tween_property(sol, "light_energy", 0.9, 2.0)
		"atardecer":
			t.tween_property(sol, "light_color", Color(0.8, 0.3, 0.1), 2.0)
			t.parallel().tween_property(sol, "light_energy", 0.6, 2.0)
		"noche":
			t.tween_property(sol, "light_color", Color(0.1, 0.1, 0.3), 2.0)
			t.parallel().tween_property(sol, "light_energy", 0.2, 2.0)
	
	# Llamamos a la actualización de todos los elementos nocturnos/ambientales
	actualizar_elementos_mundo(estado)

func actualizar_elementos_mundo(estado):
	# Actualiza el Pony
	get_tree().call_group("Player", "actualizar_linterna", estado)
	
	# Actualiza los Vehículos
	get_tree().call_group("Vehiculos", "actualizar_luces_segun_clima", estado)
	
	# Actualiza los Troncos
	if estado == "noche" or estado == "atardecer":
		get_tree().call_group("Troncos", "encender_balizas")
	else:
		get_tree().call_group("Troncos", "apagar_balizas")

func generar_spawn():
	var instancia = spawn_escena.instantiate()
	add_child(instancia)
	
	# Lo ponemos en la posición inicial
	instancia.global_position = Vector3(0, 0, 0)
	
	# Lo añadimos a la lista de carriles activos para que se limpie solo
	carriles_activos.append(instancia)
	
	# Calculamos dónde empezará el siguiente carril aleatorio
	proxima_posicion_x = largo_spawn * 7.0

func generar_carril_aleatorio():
	var escena = lista_escenas.pick_random()
	generar_carril_especifico(escena)

func generar_carril_especifico(escena: PackedScene):
	var instancia = escena.instantiate()
	add_child(instancia)
	
	instancia.global_position = Vector3(proxima_posicion_x, 0, 0)
	instancia.force_update_transform() 
	
	# Si el carril es de pasto, hay un 20% de probabilidad de spawn
	# if escena == carril_pasto and randf() < 0.2:
	# 	# Esperamos un frame para que el _ready del pasto se ejecute y llene celdas_vacias
	# 	await get_tree().process_frame 
	# 	if instancia.celdas_vacias.size() > 0:
	# 		var z_libre = instancia.celdas_vacias.pick_random()
	# 		var nueva_manzana = manzana_scena.instantiate()
	# 		add_child(nueva_manzana)
	# 		# Usamos la proxima_posicion_x del carril y la Z que sabemos que está libre
	# 		nueva_manzana.global_position = Vector3(proxima_posicion_x, 1.2, z_libre)
	
	# Todos los carriles reciben la dirección y todos la invierten
	if instancia.has_method("preparar_carril"):
		instancia.preparar_carril(proxima_direccion_flujo)
		
		# Imprimimos el log para verificar
		var tipo = "Agua" if escena.resource_path.contains("agua") else "Carril"
		print(str(proxima_direccion_flujo) + tipo)
		
		# No importa si es agua, pasto o carretera
		proxima_direccion_flujo *= -1 
	
	carriles_activos.append(instancia)
	proxima_posicion_x += 7.0

func limpiar_carriles_viejos():
	# Si el primer carril de la lista está muy atrás del jugador, lo borramos
	if carriles_activos.size() > 0:
		var primer_carril = carriles_activos[0]
		if primer_carril.global_position.x < player.global_position.x - distancia_limpieza:
			carriles_activos.pop_front()
			primer_carril.queue_free()

func crear_linea_de_meta_global():
	# Limpiamos metas antiguas
	for hijo in get_children():
		if hijo.is_in_group("Meta"):
			hijo.queue_free()
	
	var mejor_dato = GameManager.obtener_record_absoluto()
	var mejor_score = mejor_dato["high_score"]
	var mejor_usuario = mejor_dato["nombre"]
	
	# Si hay un récord mayor a 0, ponemos la línea roja
	if mejor_score > 0:
		var meta_instancia = meta_scene.instantiate()
		meta_instancia.add_to_group("Meta")
		add_child(meta_instancia)
		meta_instancia.configurar(mejor_score, mejor_usuario)
