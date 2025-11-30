extends Node2D

@onready var player := $Player
@onready var ui_player := $UIPlayer

func _ready() -> void:
	
	if player:
		player.evolution_triggered.connect(_on_player_evolution_triggered)
	else:
		print("No se encontró el nodo Player _ready()")

func _on_player_evolution_triggered() -> void:
	if ui_player:
		ui_player.pause_ground()
	
	await get_tree().create_timer(5.0).timeout
	
	if ui_player:
		ui_player.resume_ground()
