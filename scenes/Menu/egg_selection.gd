extends CanvasLayer

@onready var egg1_button := $Egg1Button
@onready var egg2_button := $Egg2Button

# Escalas
var normal_scale := Vector2(5.0, 5.0)
var hover_scale := Vector2(8, 8)

# Duración de animación
var animation_duration := 0.3

func _ready() -> void:
	egg1_button.mouse_entered.connect(_on_egg1_mouse_entered)
	egg1_button.mouse_exited.connect(_on_egg1_mouse_exited)
	egg1_button.pressed.connect(_on_egg1_pressed)
	
	egg2_button.mouse_entered.connect(_on_egg2_mouse_entered)
	egg2_button.mouse_exited.connect(_on_egg2_mouse_exited)
	egg2_button.pressed.connect(_on_egg2_pressed)
	
	# Aqui hay un fallo de tamaño pero no encuentro centrarlo bien.
	egg1_button.pivot_offset = egg1_button.size / 2
	egg2_button.pivot_offset = egg2_button.size / 2

## Huevo 1: Mouse entra
func _on_egg1_mouse_entered() -> void:
	animate_scale(egg1_button, hover_scale)
	animate_scale(egg2_button, normal_scale)

## Huevo 1: Mouse sale
func _on_egg1_mouse_exited() -> void:
	animate_scale(egg1_button, normal_scale)

## Huevo 1: Click
func _on_egg1_pressed() -> void:
	GameData.selected_egg = 1
	go_to_hatch_scene()

## Huevo 2: Mouse entra
func _on_egg2_mouse_entered() -> void:
	animate_scale(egg2_button, hover_scale)
	animate_scale(egg1_button, normal_scale)

## Huevo 2: Mouse sale
func _on_egg2_mouse_exited() -> void:
	animate_scale(egg2_button, normal_scale)

## Huevo 2: Click
func _on_egg2_pressed() -> void:
	GameData.selected_egg = 2
	go_to_hatch_scene()

## Animar escala de un botón
func animate_scale(button: TextureButton, target_scale: Vector2) -> void:
	var tween = create_tween()
	tween.tween_property(button, "scale", target_scale, animation_duration)

## Ir a escena de eclosión (más tarde)
func go_to_hatch_scene() -> void:
	get_tree().change_scene_to_file("res://scenes/Menu/egg_hatch.tscn")
