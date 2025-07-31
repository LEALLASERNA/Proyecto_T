extends CharacterBody2D

# Referencias a nodos de UI
@onready var hunger_bar := get_tree().get_current_scene().get_node("HungerBar")

# Sistema de movimiento
var speed: float = 100.0
var direction: int = -1 # Dirección inicial (izquierda)
var gravity: float = 600.0
var jump_force: float = 300.0

# Sistema de hambre
var hunger: float = 100.0
var max_hunger: float = 100.0
var hunger_decrease_rate: float = 10.0  # Cantidad por segundo

func _ready() -> void:
	print("Buscando barra de hambre:", hunger_bar)
	$AnimatedSprite2D.play("walk")
	update_hunger_bar()

func _physics_process(delta: float) -> void:
	# Movimiento vertical (salto y gravedad)
	if is_on_floor():
		velocity.y = 0
		if Input.is_action_pressed("ui_accept"):
			velocity.y = -jump_force
	else:
		velocity.y += gravity * delta

	# Movimiento horizontal automático
	velocity.x = direction * speed
	move_and_slide()

	# Cambiar dirección al llegar a los bordes de la pantalla
	var screen_size = get_viewport_rect().size
	var position_in_screen = global_position.x

	if position_in_screen <= 100:
		direction = 1
		$AnimatedSprite2D.play("walk")
		$AnimatedSprite2D.flip_h = true
	elif position_in_screen >= screen_size.x - 100:
		direction = -1
		$AnimatedSprite2D.play("walk")
		$AnimatedSprite2D.flip_h = false

func _process(delta: float) -> void:
	# Disminuir hambre con el tiempo
	hunger -= hunger_decrease_rate * delta
	hunger = clamp(hunger, 0, max_hunger)
	update_hunger_bar()

	if hunger == 0:
		print("¡Tu Tamagotchi tiene hambre!")
		# Aquí puedes añadir animación de tristeza, sonido, etc.

func update_hunger_bar() -> void:
	if hunger_bar:
		print("Actualizando barra con hambre:", hunger)
		hunger_bar.set_hunger(hunger)
	else:
		print("NO SE ENCONTRÓ el nodo HungerBar")
