extends CanvasLayer

signal feed_button_pressed 

@onready var hunger_bar := $HungerBar
@onready var happiness_bar := $HappinessBar

@onready var ground_movement := $GroundMovement
@onready var ground1 := $GroundMovement/Ground1
@onready var ground2 := $GroundMovement/Ground2
@onready var bush_movement := $BushMovement
@onready var bush1 := $BushMovement/Bush1
@onready var bush2 := $BushMovement/Bush2
@onready var bush3 := $BushMovement/Bush3
@onready var cloud_movement := $CloudMovement
@onready var cloud1 := $CloudMovement/Cloud1
@onready var cloud2 := $CloudMovement/Cloud2

# Velocidades de Paradox
var ground_speed: float = 120.0   
var bush_speed: float = 100.0
var cloud_speed: float = 200.0

# Anchos para bucle
var ground_width: float = 720.0
var bush_spacing: float = 150.0  
var cloud_spacing: float = 100.0 

# Posicion iniciales del Paradox
var ground1_initial_x: float = 0.0       
var ground2_initial_x: float = 720.0
var ground_paused: bool = false

# Tamaño de la pantalla
var screen_left: float = -100.0
var screen_right: float = 1252.0

func _ready() -> void:
	randomize_bush_types()
	randomize_cloud_types()

func _process(delta: float) -> void:
	if not ground_paused:
		ground_movement.position.x -= ground_speed * delta
	loop_ground()
	
	if not ground_paused:
		bush_movement.position.x -= bush_speed * delta
	loop_bushes()
	
	cloud_movement.position.x -= cloud_speed * delta
	loop_clouds()

func loop_ground() -> void:
	if ground1.global_position.x < -ground_width / 2:
		ground1.position.x = max(ground2.position.x, ground1.position.x) + ground_width
	if ground2.global_position.x < -ground_width / 2:
		ground2.position.x = max(ground1.position.x, ground2.position.x) + ground_width

func loop_bushes() -> void:
	var bushes = [bush1, bush2, bush3]
	
	for bush in bushes:
		if bush.global_position.x < -100:
			var rightmost_x = get_rightmost_bush_x(bushes)
			bush.position.x = rightmost_x + bush_spacing
			
			randomize_single_bush(bush)

func loop_clouds() -> void:
	var clouds = [cloud1, cloud2]
	
	for cloud in clouds:
		if cloud.global_position.x < -100:
			var rightmost_x = get_rightmost_cloud_x(clouds)
			cloud.position.x = rightmost_x + cloud_spacing
			
			randomize_single_cloud(cloud)

func get_rightmost_bush_x(bushes: Array) -> float:
	var max_x = -999999.0
	for bush in bushes:
		if bush.position.x > max_x:
			max_x = bush.position.x
	return max_x

func get_rightmost_cloud_x(clouds: Array) -> float:
	var max_x = -999999.0
	for cloud in clouds:
		if cloud.position.x > max_x:
			max_x = cloud.position.x
	return max_x

func randomize_bush_types() -> void:
	randomize_single_bush(bush1)
	randomize_single_bush(bush2)
	randomize_single_bush(bush3)  # ← CORREGIDO: Añadido bush3

func randomize_single_bush(bush: Node2D) -> void:
	if bush is Sprite2D:
		var bush_textures = [
			preload("res://assets/sprites/ui/bushs/bush_01.png"),
			preload("res://assets/sprites/ui/bushs/bush_02.png"),
			preload("res://assets/sprites/ui/bushs/bush_03.png")
		]
		bush.texture = bush_textures[randi() % 3]
	
	elif bush is AnimatedSprite2D:
		var animations = ["bush_1", "bush_2", "bush_3"] 
		bush.play(animations[randi() % 3]) 

func randomize_cloud_types() -> void:
	randomize_single_cloud(cloud1)
	randomize_single_cloud(cloud2)

func randomize_single_cloud(cloud: Node2D) -> void:
	if cloud is Sprite2D:
		var cloud_textures = [
			preload("res://assets/sprites/ui/clouds/cloud_01.png"),
			preload("res://assets/sprites/ui/clouds/cloud_02.png")
		]
		cloud.texture = cloud_textures[randi() % 2]

### SISTEMA DE BARA Y BOTONES ### 
func set_hunger(value: float) -> void:
	if not hunger_bar:
		return

	value = clamp(value, 0, 100)
	hunger_bar.value = value

func set_happiness(value: float) -> void:
	if not happiness_bar:
		return
	
	value = clamp(value, 0, 100)
	happiness_bar.value = value

func _on_feed_button_pressed() -> void:
	emit_signal("feed_button_pressed")

func _on_trainer_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Training/training.tscn")

func pause_ground() -> void:
	ground_paused = true

func resume_ground() -> void:
	ground_paused = false
