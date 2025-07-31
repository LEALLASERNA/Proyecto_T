extends CanvasLayer

@onready var hunger_bar := $HungerBar

func set_hunger(value: float) -> void:
	if not hunger_bar:
		print("No se encontró el nodo HungerBar")
		return

	# Clamp para asegurar que está entre 0 y 100
	value = clamp(value, 0, 100)
	hunger_bar.value = value

	# Determinar en qué decena estamos (redondeamos hacia abajo al múltiplo de 10)
	var percent := int(value / 10) * 10

	# Ocultar todos los nodos Sprite2D dentro de HungerBar
	for child in hunger_bar.get_children():
		if child is Sprite2D:
			child.visible = false

	# Mostrar el nodo correspondiente
	var nombreNodo := "Barra_Hambre_%02d" % percent
	var target_node := hunger_bar.get_node_or_null(nombreNodo) 

	if target_node and target_node is Sprite2D:
		target_node.visible = true
	else:
		print("No se encontró el nodo Sprite2D correspondiente:", nombreNodo)



  ##PARA BARRA PROGRESIVA##
	# Construir ruta a la textura correspondiente
	var texture_path := "res://assets/sprites/ui/Barra_Hambre_%02d.png" % percent
	# Intentar cargar la textura
	var tex := load(texture_path)
	if tex:
		hunger_bar.texture_progress = tex
	else:
		print("No se pudo cargar la textura:", texture_path)
