extends Node

# --- VARIABLES DE SESIÓN ---
var nombre_usuario_actual: String = ""
var score_actual: int = 0
var high_score_local: int = 0
var high_score_global_otro: int = 0
var clima_actual: String = "dia"
var manzanas_recolectadas: int = 0
var manzanas_totales: int = 0

# --- CONFIGURACIÓN SQLITE ---
var db : SQLite = null
const DB_PATH = "res://BD/usuarios_data.db"

func _ready():
	_inicializar_base_datos()

func limpiar_datos_memoria():
	score_actual = 0
	manzanas_recolectadas = 0
	manzanas_totales = 0
	print("DEBUG: Memoria del GameManager limpiada")

func _inicializar_base_datos():
	db = SQLite.new()
	db.path = DB_PATH
	db.open_db()
	
	# Definimos la estructura de la tabla
	# 'activo' será 1 para el usuario actual, 0 para los demás
	var tabla_usuarios = {
		"nombre": {"data_type":"text", "primary_key": true},
		"high_score": {"data_type":"int", "default": 0},
		"monedas": {"data_type":"int", "default": 0},
		"activo": {"data_type":"int", "default": 0},
		"fecha_registro": {"data_type":"text"}
	}
	db.create_table("usuarios", tabla_usuarios)
	
	# Al iniciar, buscamos si hay alguien marcado como 'activo'
	_cargar_sesion_activa()

func _cargar_sesion_activa():
	db.query("SELECT * FROM usuarios WHERE activo = 1")
	if db.query_result.size() > 0:
		var datos = db.query_result[0]
		nombre_usuario_actual = datos["nombre"]
		high_score_local = datos["high_score"]
		actualizar_high_scores(nombre_usuario_actual)
		print("Sesión restaurada para: ", nombre_usuario_actual)

# --- CRUD: CREATE / UPDATE ---

func guardar_nuevo_usuario(nickname: String):
	if nickname == "": return
	
	# Verificamos si ya existe
	db.query("SELECT nombre FROM usuarios WHERE nombre = '" + nickname + "'")
	if db.query_result.size() > 0:
		print("El usuario ya existe.")
		return
	
	var datos = {
		"nombre": nickname,
		"high_score": 0,
		"monedas": 0,
		"activo": 0,
		"fecha_registro": Time.get_date_string_from_system()
	}
	db.insert_row("usuarios", datos)
	print("Usuario ", nickname, " creado en SQLite.")

func establecer_usuario_activo(nickname: String):
	# Limpiamos lo que haya del usuario anterior
	limpiar_datos_memoria()
	
	# Lógica de SQL
	db.update_rows("usuarios", "1=1", {"activo": 0})
	db.update_rows("usuarios", "nombre = '" + nickname + "'", {"activo": 1})
	
	nombre_usuario_actual = nickname
	
	# Cargamos los datos reales del nuevo usuario desde la DB
	actualizar_memoria_manzanas() 
	actualizar_high_scores(nickname)
	
	print("Usuario activo cambiado a: ", nickname, " | Monedas iniciales: ", manzanas_totales)

func actualizar_puntuacion_final(puntos: int):
	if nombre_usuario_actual == "": 
		print("DEBUG: No hay usuario activo para guardar")
		return
	
	# DEBUG: Para ver cuánto tenemos antes de limpiar
	print("DEBUG: Guardando partida. Manzanas en esta ronda: ", manzanas_recolectadas)

	# Consultar datos actuales
	db.query("SELECT monedas, high_score FROM usuarios WHERE nombre = '" + nombre_usuario_actual + "'")
	
	if db.query_result.size() <= 0: return
	
	var datos_viejos = db.query_result[0]
	
	# CALCULO LOCAL (Para evitar errores de concurrencia)
	var manzanas_a_sumar = manzanas_recolectadas 
	var nuevas_monedas_totales = int(datos_viejos["monedas"]) + manzanas_a_sumar
	
	var datos_actualizar = {
		"monedas": nuevas_monedas_totales
	}
	
	if puntos > datos_viejos["high_score"]:
		datos_actualizar["high_score"] = puntos
		high_score_local = puntos
		print("DEBUG: ¡Nuevo récord personal!")

	# GUARDAR EN DB
	db.update_rows("usuarios", "nombre = '" + nombre_usuario_actual + "'", datos_actualizar)
	
	# ACTUALIZAR MEMORIA (Importante para que el menú lo vea bien)
	manzanas_totales = nuevas_monedas_totales
	
	# REINICIAR SOLO AL FINAL
	manzanas_recolectadas = 0
	print("DEBUG: Guardado exitoso. Total en DB: ", nuevas_monedas_totales)

# --- CRUD: READ ---

func obtener_lista_nombres() -> Array:
	db.query("SELECT nombre FROM usuarios")
	var nombres = []
	for fila in db.query_result:
		nombres.append(fila["nombre"])
	return nombres

func obtener_record_absoluto() -> Dictionary:
	# Pedimos el nombre y el score del que tenga el high_score más alto
	db.query("SELECT nombre, high_score FROM usuarios ORDER BY high_score DESC LIMIT 1")
	if db.query_result.size() > 0:
		return db.query_result[0]
	return {"nombre": "Nadie", "high_score": 0}

func actualizar_high_scores(nickname: String):
	# Obtener récord local
	db.query("SELECT high_score FROM usuarios WHERE nombre = '" + nickname + "'")
	if db.query_result.size() > 0:
		high_score_local = db.query_result[0]["high_score"]
	
	# Obtener récord global de "otros"
	db.query("SELECT MAX(high_score) as maximo FROM usuarios WHERE nombre != '" + nickname + "'")
	var resultado = db.query_result[0]["maximo"]
	high_score_global_otro = int(resultado) if resultado != null else 0

# --- CRUD: DELETE ---

func eliminar_usuario(nickname: String):
	db.delete_rows("usuarios", "nombre = '" + nickname + "'")
	if nombre_usuario_actual == nickname:
		nombre_usuario_actual = ""
		high_score_local = 0
	actualizar_high_scores(nombre_usuario_actual)
	print("Usuario eliminado de la base de datos.")

# --- LÓGICA DE PARTIDA ---

func iniciar_nueva_partida():
	score_actual = 0
	if nombre_usuario_actual != "":
		actualizar_high_scores(nombre_usuario_actual)

func preparar_inicio_de_juego(nombre_user: String):
	establecer_usuario_activo(nombre_user)
	iniciar_nueva_partida()

func actualizar_memoria_manzanas():
	if nombre_usuario_actual == "": return
	
	db.query("SELECT monedas FROM usuarios WHERE nombre = '" + nombre_usuario_actual + "'")
	if db.query_result.size() > 0:
		manzanas_totales = db.query_result[0]["monedas"]

func finalizar_partida_y_guardar():
	if nombre_usuario_actual == "": return
	
	# Consultamos cuántas manzanas TENÍA el usuario antes de empezar esta partida
	db.query("SELECT monedas FROM usuarios WHERE nombre = '" + nombre_usuario_actual + "'")
	var monedas_en_db = 0
	if db.query_result.size() > 0:
		monedas_en_db = db.query_result[0]["monedas"]
	
	# Sumamos las que recogió en esta partida
	var total_nuevo = monedas_en_db + manzanas_recolectadas
	
	# Guardamos el nuevo total en SQLite
	db.update_rows("usuarios", "nombre = '" + nombre_usuario_actual + "'", {"monedas": total_nuevo})
	
	# Limpiamos el contador para la próxima partida
	# manzanas_recolectadas = 0
	print("Base de Datos actualizada con las nuevas manzanas.")
