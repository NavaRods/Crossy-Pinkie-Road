extends Node3D

@onready var label = $Label3D

func configurar(metros: int, usuario: String):
	# Posicionamos la línea en el eje X (cada metro es una unidad en Godot)
	global_position.x = metros * 7
	label.text = str(metros) + " m por " + usuario
