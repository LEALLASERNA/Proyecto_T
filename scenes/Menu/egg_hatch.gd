extends CanvasLayer

@onready var egg_sprite := $EggSprite
@onready var cracked_egg_sprite := $CrackedEggSprite
@onready var instruction_label := $InstructionLabel

# Variables de clicks
var clicks_done: int = 0
var clicks_needed: int = 10

# Variables de animación de balanceo
var shake_angle: float = 15.0  # Grados de inclinación
var shake_duration: float = 0.1  # Duración de cada balanceo

# Control de input
var can_click: bool = true

func _ready() -> void:
	load_selected_egg()

func load_selected_egg() -> void:
	var egg_number = GameData.selected_egg
	
	if egg_number == 1:
		egg_sprite.texture = load("res://assets/sprites/T/#0000/TamaiEgg0.png")
		cracked_egg_sprite.texture = load("res://assets/sprites/T/#0000/TamaiCrackedEgg0.png")
	else:
		egg_sprite.texture = load("res://assets/sprites/T/#1000/TamaiEgg1.png")
		cracked_egg_sprite.texture = load("res://assets/sprites/T/#1000/TamaiCrackedEgg1.png")

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if can_click:
				on_egg_clicked()

func on_egg_clicked() -> void:
	clicks_done += 1
	print("Click", clicks_done, "/", clicks_needed)
	
	await shake_egg()
	
	if clicks_done >= clicks_needed:
		hatch_egg()


func shake_egg() -> void:
	can_click = false
	
	# Calcular ángulo de balanceo (alterna izquierda/derecha)
	var target_angle = shake_angle if clicks_done % 2 == 0 else -shake_angle
	
	# Animación: girar a un lado
	var tween = create_tween()
	tween.tween_property(egg_sprite, "rotation_degrees", target_angle, shake_duration)
	await tween.finished
	
	# Animación: volver al centro
	var tween2 = create_tween()
	tween2.tween_property(egg_sprite, "rotation_degrees", 0, shake_duration)
	await tween2.finished
	
	# Reactivar clicks
	can_click = true

func hatch_egg() -> void:

	# Desactivar clicks
	can_click = false
	
	# Ocultar instrucciones
	instruction_label.visible = false
	
	# Última animación de balanceo fuerte
	await strong_shake()
	
	# Cambiar a sprite roto
	egg_sprite.visible = false
	cracked_egg_sprite.visible = true
	
	# Fade out
	var tween = create_tween()
	tween.tween_property(cracked_egg_sprite, "modulate:a", 0.0, 1.0)
	await tween.finished
	
	# Esperar un momento
	await get_tree().create_timer(3.0).timeout
	
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func strong_shake() -> void:
	# Balanceo fuerte antes de eclosionar
	for i in range(4):
		var angle = shake_angle * 1.5 if i % 2 == 0 else -shake_angle * 1.5
		var tween = create_tween()
		tween.tween_property(egg_sprite, "rotation_degrees", angle, 0.1)
		await tween.finished
	
	# Volver al centro
	var tween_final = create_tween()
	tween_final.tween_property(egg_sprite, "rotation_degrees", 0, 0.1)
	await tween_final.finished
