extends CharacterBody2D

# Referencias a nodos de UI
@onready var hunger_bar := get_node("../UI/HungerBar")
@onready var feed_button := get_node("../UI/FeedButton")

# Sistema de movimiento
var speed = 100 #Velocidad normal
var direction: int = -1 #Direccion: 1 = derecha, -1 = izquierda
var gravity: float = 600.0 #Gravedad
var jump_force: float = 300.0 #Fuerza del salto

# Sistema de hambre
var hunger: int = 100 #Hambre total
var hunger_decrease_rate: int = 5 #Ratio de decrecimiento
var feed_amount: int = 20 #Cantidad de alimento

func _ready() -> void:
	$AnimatedSprite2D.play("walk")

func _physics_process(delta):
	
	# Gravedad
	if is_on_floor():
		velocity.y = 0  # Detener caída si está en el suelo
		print("Está en el suelo:", is_on_floor())
		if Input.is_action_pressed("ui_accept"):# Saltar solo si está en el suelo y se presiona la tecla
			velocity.y = -jump_force
	else:
		velocity.y += gravity * delta
		print("Está en el suelo:", is_on_floor())

	#Movimineto horizontal
	velocity.x = direction * speed
	move_and_slide()

	#Detectar bordes de la pantalla para cambiar dirección
	var screen_size = get_viewport_rect().size #Reconoce el tamaño de la pantalla y lo convierte en Vector2
	var position_in_screen = global_position.x

	if position_in_screen <= 100:
		direction = 1
		$AnimatedSprite2D.play("walk")
		$AnimatedSprite2D.flip_h = true

	elif position_in_screen >= screen_size.x -100:
		direction = -1
		$AnimatedSprite2D.play("walk")
		$AnimatedSprite2D.flip_h = false

# Funcion integrada que se ejecuta en cada frame. DELTA: según el valor del tiempo no del frame
func _process(delta: float) -> void:
	# Reducir hambre con el tiempo
	hunger -= hunger_decrease_rate * delta
	hunger = clamp(hunger, 0, 100)
	#hunger_bar.value = hunger

	if hunger == 0:
		print("¡Tu Tamagotchi tiene hambre!")
		# Aquí puedes poner animación de tristeza o Game Over

# Funcion _on_<NombreDelNodo>_<NombreDeLaSeñal>()
func _on_feed_pressed() -> void:
	hunger += feed_amount
	hunger = clamp(hunger, 0, 100)
	#hunger_bar.value = hunger
	print("¡Alimentado! Hunger ahora:", hunger)

func _on_area_entered(area: CharacterBody2D) -> void:
	print("choque con un enemigo")
	area.queue_free()
