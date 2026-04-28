extends Control

@onready var input_nickname = $CanvasLayer/PanelContainer2/MarginContainer/GridContainer/LineEdit
@onready var option_button = $CanvasLayer/PanelContainer2/MarginContainer/GridContainer/OptionButton
@onready var btn_jugar = $CanvasLayer/PanelContainer/VBoxContainer/VBoxContainer/ButtonJugar
@onready var label_jugar = $CanvasLayer/PanelContainer/VBoxContainer/VBoxContainer/ButtonJugar/Label
@onready var label_conf = $CanvasLayer/PanelContainer/VBoxContainer/VBoxContainer/ButtonConf/Label
@onready var label_manzanas_menu = $CanvasLayer/PanelContainer3/HBoxContainer/Label
@onready var button_guardar = $CanvasLayer/PanelContainer2/MarginContainer/GridContainer/MarginContainer/HBoxContainer/Guardar
@onready var button_eliminar = $CanvasLayer/PanelContainer2/MarginContainer/GridContainer/MarginContainer/HBoxContainer/Eliminar

var en_juego: bool = false

func _ready():
	# Al cargar, llenamos la lista con usuarios que ya existan
	actualizar_lista_desplegable()
	mostrar_datos_usuario_actual()

# --- FUNCIONES DEL PANEL DE USUARIO (CRUD) ---

func mostrar_datos_usuario_actual():
	if GameManager.nombre_usuario_actual != "":
		# Pedimos al GameManager que refresque el dato desde SQLite
		GameManager.actualizar_memoria_manzanas()
		# Mostramos el total
		label_manzanas_menu.text = str(GameManager.manzanas_totales)
	else:
		label_manzanas_menu.text = "0"

func _on_guardar_pressed():
	var nick = input_nickname.text.strip_edges()
	if nick != "":
		GameManager.guardar_nuevo_usuario(nick)
		input_nickname.text = ""
		actualizar_lista_desplegable()
		# Después de guardar, como el nuevo tiene 0, lo mostramos
		mostrar_datos_usuario_actual()

func _on_eliminar_pressed():
	# Obtenemos el nombre seleccionado en el OptionButton
	var id = option_button.get_selected_id()
	if id != -1:
		var nombre_a_borrar = option_button.get_item_text(id)
		# Borramos en el Singleton (CRUD: Delete)
		GameManager.eliminar_usuario(nombre_a_borrar)
		actualizar_lista_desplegable()

func actualizar_lista_desplegable():
	option_button.clear()
	var usuarios = GameManager.obtener_lista_nombres() # (CRUD: Read)
	
	for u in usuarios:
		option_button.add_item(u)
		if u == GameManager.nombre_usuario_actual:
			var	 index = option_button.get_item_count() - 1
			option_button.select(index)
	
	# Si no hay usuarios, desactivamos el botón Jugar
	btn_jugar.disabled = usuarios.is_empty()
	mostrar_datos_usuario_actual()

# --- FUNCIONES DE NAVEGACIÓN ---

func _on_button_jugar_pressed():
	var id = option_button.get_selected_id()
	if id == -1 or option_button.get_item_text(id) == "No hay usuarios":
		return

	# Datos
	var nombre_user = option_button.get_item_text(id)
	GameManager.establecer_usuario_activo(nombre_user)
	GameManager.iniciar_nueva_partida()


	# Sirve para ocultar el Menu
	if has_node("CanvasLayer"):
		$CanvasLayer.visible = false
	
	label_jugar.position.y = 30
	
	var hud = get_tree().get_first_node_in_group("HUD")
	if hud:
		hud.show() # Muestra el nodo raíz
		# BUSCAMOS EL CANVASLAYER DEL HUD Y LO ENCENDEMOS:
		if hud.has_node("CanvasLayer"):
			hud.get_node("CanvasLayer").visible = true
		else:
			# Si no lo encuentra por nombre, intentamos buscar cualquier CanvasLayer hijo
			for child in hud.get_children():
				if child is CanvasLayer:
					child.visible = true
			
	

	# ACTIVAR CÁMARA Y PLAYER
	# Usamos el grupo "Activos" que mencionaste en tu código
	var nodos = get_tree().get_nodes_in_group("Activos")
	for n in nodos:
		if "start_game" in n:
			n.start_game = true
		if "juego_iniciado" in n: # Por si el Player usa este nombre
			n.juego_iniciado = true
			
	var cam = get_viewport().get_camera_3d()
	if cam: cam.set("start_game", true)

func _on_button_conf_pressed():
	# Aquí abrirás tu panel de configuración cuando lo tengas listo
	print("Abriendo configuración...")


func _on_button_jugar_button_down() -> void:
	label_jugar.position.y += 15


func _on_button_jugar_button_up() -> void:
	label_jugar.position.y = 0


func _on_button_conf_button_down() -> void:
	label_conf.position.y += 15


func _on_button_conf_button_up() -> void:
	label_conf.position.y = 15
