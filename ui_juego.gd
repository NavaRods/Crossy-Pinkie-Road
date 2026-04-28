extends Control

# Referencias a los Labels (Ajusta la ruta si tus nombres son distintos)
@onready var label_manzanas = $CanvasLayer/PanelContainer/HBoxContainer/Label
@onready var label_metros = $CanvasLayer/PanelContainer2/Label # Asumiendo que es el segundo Panel

func _ready():
	# Nos aseguramos de que el HUD empiece oculto si el menú de inicio está activo
	# O visible si el juego ya empezó.
	pass

func _process(_delta):
	if not is_visible_in_tree(): return
	
	# Mostrar Metros
	label_metros.text = str(GameManager.score_actual) + " m"
	
	# Mostrar Manzanas
	# Leemos directamente la variable del GameManager que se actualiza al recoger una
	var visual_manzanas = GameManager.manzanas_totales + GameManager.manzanas_recolectadas
	label_manzanas.text = str(visual_manzanas)
