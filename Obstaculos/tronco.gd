extends AnimatableBody3D

@onready var luces = [$OmniLight3D, $OmniLight3D2]

var _vel: float = 0.0
var _dir: int = 0

func _ready():
	add_to_group("Troncos")
	
	if GameManager.clima_actual in ["tarde", "atardecer", "noche"]:
		encender_balizas()

func configurar(v: float, d: int):
	_vel = v
	_dir = d

func _physics_process(delta):
	# Movimiento constante en el eje Z GLOBAL
	global_position.z += _vel * _dir * delta
	
	# Si se sale mucho del área de juego, se borra
	if abs(global_position.z) > 100.0:
		queue_free()

func encender_balizas():
	for luz in luces:
		luz.visible = true
