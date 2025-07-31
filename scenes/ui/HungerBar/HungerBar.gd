extends Node2D

@onready var sprite := $Sprite2D

@export var max_hunger: float = 100.0
var current_hunger: float = 100.0

func _ready():
	update_bar()

func set_hunger(value: float):
	current_hunger = clamp(value, 0, max_hunger)
	update_bar()

func update_bar():
	var percent := current_hunger / max_hunger * 100
	print("Porcentaje de hambre:", percent)

	if percent >= 100:
		print("Sprite al 100%")
		sprite.texture = preload("res://assets/sprites/ui/Barra_Hambre_1010.png")
	elif percent >= 50:
		print("Sprite al 50%")
		sprite.texture = preload("res://assets/sprites/ui/Barra_Hambre_0910.png")
	else:
		print("Sprite al 0%")
		sprite.texture = preload("res://assets/sprites/ui/Barra_Hambre_0010.png")
