extends AnimatableBody3D

var velocidad: float = 0.0
var direccion: int = 1 # 1: Derecha, -1: Izquierda

@onready var luces_frontales = []
@onready var luz_ambiente = []

func configurar(v: float, d: int):
	velocidad = v
	direccion = d
	
	# Rotamos el modelo según la dirección
	# Si d = 1 mira a un lado, si d = -1 al opuesto
	if direccion == 1:
		rotation_degrees.y = -90
	else:
		rotation_degrees.y = 90

func _ready():
	add_to_group("Vehiculos")
	
	for hijo in get_children():
		if hijo is SpotLight3D:
			luces_frontales.append(hijo)
		elif hijo is OmniLight3D:
			luz_ambiente.append(hijo)
	
	# Verificamos el clima inicial
	if "clima_actual" in GameManager:
		actualizar_luces_segun_clima(GameManager.clima_actual)

func _physics_process(delta):
	# Movimiento constante
	global_position.z += velocidad * direccion * delta
	
	# Auto-eliminación para optimizar
	if abs(global_position.z) > 80:
		queue_free()

func actualizar_luces_segun_clima(estado: String):
	var energia: float = 0.0
	
	match estado:
		"mañana": energia = 0.0   # Luces muy tenues
		"dia": energia = 0.0      # Luces apagadas
		"tarde": energia = 0.0    # Luces de posición
		"atardecer": energia = 10.0 # Luces encendiéndose
		"noche": energia = 20.0    # Luces a máxima potencia
	
	_aplicar_energia(energia)

func _aplicar_energia(valor: float):
	# Aplicamos a los faros (SpotLights)
	for luz in luces_frontales:
		if luz:
			luz.light_energy = valor
			luz.visible = valor > 0
	
	# Aplicamos a la luz de relleno (OmniLight)
	for luz in luz_ambiente:
		if is_instance_valid(luz):
			luz.light_energy = valor * 0.2 
			luz.visible = valor > 0
