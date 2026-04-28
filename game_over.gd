extends Control

@onready var btn_reintentar = $CanvasLayer/PanelContainer/VBoxContainer/HBoxContainer/Reintentar

func _ready():
	btn_reintentar.pressed.connect(_on_reintentar)

func _on_reintentar():
	GameManager.iniciar_nueva_partida()
	get_tree().reload_current_scene()
