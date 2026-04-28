extends CharacterBody3D

'''
Resulta mas conveniente realizar las animaciones por codigo que en el propio
modelo de blander, me a constado mayor trabajo haciendolos en el modelo
pero al darme cuenta que tardaban mucho y que acelerarlo hacia que se vieran mal
el codigo el la mejor opcion, asi tambien ahorro recursos y no tengo que reproducir
la animacion de salto todo el tiempo.

La animacion de Salto del Pony esta en mi Twitter @Karlos_del_shat
'''

@export var jump_distance: float = 7.0
@export var jump_speed: float = 50.0
@export var jump_height: float = 1.0 

var target_position: Vector3
var start_position: Vector3
var is_moving: bool = false
var jump_progress: float = 0.0
var morira_al_chocar: bool = false 
var start_game: bool = false
var posicion_inicial_x: float = 0.0
var distancia_avanzada: int = 0

const Ancho_limite: float = 28

@onready var animation_player: AnimationPlayer = $Pony/AnimationPlayer
@onready var ray_suelo: RayCast3D = $Marker3D/RayCast3D
@onready var sonido_salto = $Salto
@onready var sonido_atropello = $MuerteAtropello
@onready var sonido_objeto = $MuerteObjeto
@onready var sonido_ahogo = $MuerteAhogado
@onready var linterna = $SpotLight3D

func _physics_process(delta):
	if not start_game: return
	
	if is_moving:
		jump_progress += (jump_speed * delta) / jump_distance
		jump_progress = clamp(jump_progress, 0.0, 1.0)
		
		var current_pos = start_position.lerp(target_position, jump_progress)
		var y_offset = 4 * jump_height * jump_progress * (1.0 - jump_progress)
		current_pos.y += y_offset
		
		global_position = current_pos
		
		if jump_progress >= 1.0:
			finalizar_salto()
	else:
		handle_input()
		if abs(global_position.z) > Ancho_limite:
			muerte_por_caida()
		revisar_colisiones_constantes()
	
	# CÁLCULO DE METROS (INT)
	# Calculamos la distancia desde el punto de inicio
	var distancia = global_position.x - posicion_inicial_x
	var metros_avanzados = int(distancia/7)
	
	# Si la distancia es positiva (avanzaste), actualizamos el GameManager
	if metros_avanzados > GameManager.score_actual:
		
		# int() convierte el número decimal (float) a entero truncándolo
		GameManager.score_actual = metros_avanzados

func _ready():
	add_to_group("Activos")
	add_to_group("Player")
		
	$AreaRecoleccion.area_entered.connect(_on_manzana_tocada)
	if "clima_actual" in GameManager:
		actualizar_linterna(GameManager.clima_actual)

func actualizar_linterna(estado: String):
	var energia_objetivo: float = 0.0
	
	match estado:
		"mañana", "dia":
			energia_objetivo = 0.0
		"tarde":
			energia_objetivo = 0.0  
		"atardecer":
			energia_objetivo = 10.0  # Empieza a ser útil
		"noche":
			energia_objetivo = 20.0 # Luz potente para ver el camino
			
	if linterna:
		linterna.light_energy = energia_objetivo
		linterna.visible = energia_objetivo > 0

func _on_manzana_tocada(area):
	# Si el área que tocamos tiene el método para recolectar, lo ejecutamos
	if area.has_method("recolectar"):
		area.recolectar()

func handle_input():
	var move_dir = Vector3.ZERO
	if Input.is_action_just_pressed("ui_up"): move_dir = Vector3(jump_distance, 0, 0)
	elif Input.is_action_just_pressed("ui_down"): move_dir = Vector3(-jump_distance, 0, 0)
	elif Input.is_action_just_pressed("ui_right"): move_dir = Vector3(0, 0, jump_distance)
	elif Input.is_action_just_pressed("ui_left"): move_dir = Vector3(0, 0, -jump_distance)
	elif Input.is_action_just_pressed("W"): move_dir = Vector3(jump_distance, 0, 0)
	elif Input.is_action_just_pressed("S"): move_dir = Vector3(-jump_distance, 0, 0)
	elif Input.is_action_just_pressed("D"): move_dir = Vector3(0, 0, jump_distance)
	elif Input.is_action_just_pressed("A"): move_dir = Vector3(0, 0, -jump_distance)

	if move_dir != Vector3.ZERO:
		# Calculamos la rotación (lo que ya funciona)
		var target_angle = atan2(move_dir.x, move_dir.z)
		global_rotation.y = target_angle - deg_to_rad(90)
		
		# POSICIONAMOS EL RAYCAST MANUALMENTE
		# Esto mueve el Marker3D a la celda de destino para "espiar" antes de saltar
		$Marker3D.global_position = global_position + move_dir
		
		# FORZAMOS LA ACTUALIZACIÓN
		ray_suelo.force_raycast_update()

		# Salto
		if get_parent() is AnimatableBody3D:
			liberar_de_padre()
		execute_relative_jump(move_dir)

func revisar_colisiones_constantes():
	ray_suelo.force_raycast_update()
	
	if ray_suelo.is_colliding():
		var col = ray_suelo.get_collider()
		
		# Si lo que toca el RayCast es de la Capa 3 (Obstáculos/Vehículos)
		if col.get_collision_layer_value(3):
			if col.is_in_group("Vehiculos"):
				ejecutar_muerte_por_atropello()
			else:
				# Esto evita que te quedes parado "dentro" de un árbol
				ejecutar_muerte_por_choque()
		if col.get_collision_layer_value(6):
			if col.has_method("recolectar"):
				col.recolectar()

func execute_relative_jump(move_dir: Vector3):
	start_position = global_position
	target_position = start_position + move_dir
	# Forzamos que el destino del salto sea a nivel del suelo
	target_position.y = 0.0 
	jump_progress = 0.0
	sonido_salto.play()
	is_moving = true

func finalizar_salto():
	is_moving = false
	ray_suelo.force_raycast_update()
	
	if ray_suelo.is_colliding():
		var col = ray_suelo.get_collider()
		
		if col.get_collision_layer_value(3): # OBSTACULO 
			if col.is_in_group("Vehiculos"):
				print("Murió atropellado por: ", col.name)
				ejecutar_muerte_por_atropello() 
			else:
				print("Chocó contra un objeto estático: ", col.name)
				ejecutar_muerte_por_choque()
		elif col.get_collision_layer_value(4): # TRONCO
			var tronco = col if col is AnimatableBody3D else col.get_parent()
			reparentar_a_tronco(tronco)
		
		elif col.get_collision_layer_value(5): # AGUA
			morir_ahogado()
		elif col.get_collision_layer_value(6): 
			if col.has_method("recolectar"):
				col.recolectar() # Esto llamará a la función en manzana.gd
		else: # SUELO FIRME
			# Ajustamos la posición actual
			global_position = ajustar_a_rejilla(global_position)
	else:
		# Caída al vacío o error de colisión
		global_position = ajustar_a_rejilla(global_position)

	if animation_player:
		animation_player.play("Ilde/IDLE")

func reparentar_a_tronco(tronco: Node3D):
	# Guardamos la rotación que traemos del aire
	var rot_actual = global_rotation
	
	reparent(tronco)
	
	# Ajustamos posición local para centrarlo en el carril
	position.x = 0
	position.y = 1.2
	
	# Restauramos la rotación global para que el cambio de padre no lo gire
	global_rotation = rot_actual

func morir_ahogado():
	print("¡Splash! El Pony se hundió")
	set_physics_process(false)
	is_moving = false # Bloqueamos movimiento
	
	var t = create_tween()
	t.tween_property(self, "position:y", -2.0, 0.5)
	# Usamos un valor muy pequeño pero no cero.
	sonido_ahogo.play()
	t.parallel().tween_property(self, "scale", Vector3(0.01, 0.01, 0.01), 0.5)
	t.finished.connect(func():
		await get_tree().create_timer(1.0).timeout
		reiniciar_nivel()
	)


func ejecutar_muerte_por_choque():
	print("¡CRASH! Muerte por obstáculo")
	# is_moving = false
	set_physics_process(false)
	sonido_objeto.play()
	var t = create_tween()
	t.set_trans(Tween.TRANS_BOUNCE)
	t.tween_property(self, "rotation_degrees:x", 90, 0.3)
	await get_tree().create_timer(1.0).timeout
	reiniciar_nivel()


func liberar_de_padre():
	if get_parent() is AnimatableBody3D:
		var pos_actual = global_position
		var rot_actual = global_rotation # Guardamos rotación
		
		reparent(get_tree().current_scene)
		
		global_position = pos_actual
		global_rotation = rot_actual # La mantenemos al soltarnos

func muerte_por_caida():
	# Si ya estamos en proceso de muerte, no hacemos nada
	if morira_al_chocar:
		return
	
	morira_al_chocar = true
	# Desactivar physics_process de inmediato para detener el bucle
	set_physics_process(false)
	
	print("Muerte Lateral Detectada")
	
	# Reproducir sonido (solo sonará una vez porque desactivamos el proceso)
	if has_node("MuerteObjeto"):
		$MuerteObjeto.play()

	var t = create_tween()
	t.set_trans(Tween.TRANS_BOUNCE)
	t.tween_property(self, "rotation_degrees:x", 90, 0.3)
	
	# Esperar antes de reiniciar
	await get_tree().create_timer(1.0).timeout
	reiniciar_nivel()

func ajustar_a_rejilla(pos: Vector3) -> Vector3:
	var nueva_pos = pos
	# Redondeamos X y Z al múltiplo de 7 más cercano
	nueva_pos.x = round(pos.x / 7.0) * 7.0
	nueva_pos.z = round(pos.z / 7.0) * 7.0
	# La Y la dejamos fija o según el suelo (0.0 suele ser el suelo normal)
	nueva_pos.y = 0.0
	return nueva_pos

func ejecutar_muerte_por_atropello():
	print("¡CRASH! El Pony fue atropellado")
	
	# Bloqueamos todo el movimiento y la física
	is_moving = false
	set_physics_process(false)
	
	# Creamos un Tween para los efectos visuales
	var tween = create_tween()
	
	# --- EFECTO: Aplastamiento (Estilo Crossy Road) ---
	# Escalamos el Pony para que se vea "aplastado" contra el suelo
	tween.tween_property(self, "scale", Vector3(1.5, 0.1, 1.5), 0.15).set_trans(Tween.TRANS_BOUNCE)
	print("Muerte por atropello")
	sonido_atropello.play()
	# Esperar un momento y reiniciar el juego
	tween.finished.connect(func():
		await get_tree().create_timer(1.0).timeout
		reiniciar_nivel()
	)

func reiniciar_nivel():
	GameManager.actualizar_puntuacion_final(GameManager.score_actual)
	var ir_escena = preload("res://GameOver.tscn").instantiate()
	get_tree().current_scene.add_child(ir_escena)
	# Recarga la escena actual
	# get_tree().reload_current_scene()
