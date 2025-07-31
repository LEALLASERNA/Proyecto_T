extends CharacterBody2D

# Sistema de movimiento
var speed: float = 100.0
var direction: int = -1 # Dirección inicial (izquierda)
var gravity: float = 600.0
var jump_force: float = 300.0


func _ready() -> void:
	$AnimatedSprite2D.play("walk")

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
