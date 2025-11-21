extends CanvasLayer

func _ready() -> void:
	print("Pantalla de entrenamiento cargada")

func _on_strength_button_pressed() -> void:
	print("Iniciando entrenamiento de FUERZA")
	get_tree().change_scene_to_file("res://scenes/Training/strength_game.tscn")

func _on_defence_button_pressed() -> void:
	print("Iniciando entrenamiento de DEFENSA")
	get_tree().change_scene_to_file("res://scenes/Training/defence_game.tscn")

func _on_evasion_button_pressed() -> void:
	print("Iniciando entrenamiento de EVASIÓN")
	get_tree().change_scene_to_file("res://scenes/Training/evasion_game.tscn")

func _on_back_button_pressed() -> void:
	print("Volviendo a pantalla principal...")
	get_tree().change_scene_to_file("res://scenes/Main.tscn")
