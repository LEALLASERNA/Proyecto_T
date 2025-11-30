extends Node2D

# Referencias UI
@onready var score_label := $CanvasLayer/ScoreLabel
@onready var speed_label := $CanvasLayer/SpeedLabel
@onready var result_label := $CanvasLayer/ResultLabel
@onready var start_button := $CanvasLayer/StartButton
@onready var jump_button := $CanvasLayer/JumpButton
@onready var back_button := $CanvasLayer/BackButton
@onready var instructions := $CanvasLayer/Instructions

@onready var player := $Player
@onready var player_sprite := $Player/AnimatedSprite2D
@onready var world_movement := $WorldMovement
@onready var ground := $WorldMovement/Ground
@onready var ground2 := $WorldMovement/Ground2
@onready var obstacle_spawner := $WorldMovement/ObstacleSpawner
@onready var obstacle_template := $WorldMovement/ObstacleTemplate

@onready var cloud_movement := $CloudMovement
@onready var cloud1 := $CloudMovement/Cloud1
@onready var cloud2 := $CloudMovement/Cloud2

# Variables del juego
var score: int = 0
var game_active: bool = false
var world_speed: float = 100.0
var speed_increase: float = 20.0

# Variables de física del player
var gravity: float = 980.0
var jump_force: float = -800.0
var fall_gravity: float = 2000.0
var was_in_air: bool = false

# Variables de obstáculos
var spawn_timer: Timer
var initial_spawn_interval: float = 2.0
var min_spawn_interval: float = 0.8
var player_ground_y: float = 0.0
var obstacle_spawn_x: float = 1000
var obstacle_desspawn_x: float = -200
var max_spawn_interval: float = 6.0
var min_random_spawn: float = 3.0

# Variables de nubes
var cloud_speed: float = 200.0
var cloud_spacing: float = 400.0

# Ancho del suelo para el bucle
var ground_width: float = 720.0

func _ready() -> void:
	setup_player_sprite()
	result_label.visible = false
	back_button.visible = false
	obstacle_template.visible = false
	jump_button.visible = false
	instructions.visible = true
	
	instructions.text = "Jump over the obstacles"

	player_ground_y = player.global_position.y
	
	spawn_timer = utils.create_timer(self, initial_spawn_interval, Callable(self, "_on_spawn_timer_timeout"))
	spawn_timer.stop()
	
	randomize_cloud_types()

func _process(delta: float) -> void:
	cloud_movement.position.x -= cloud_speed * delta
	loop_clouds()

func _on_start_button_pressed() -> void:

	start_button.visible = false
	jump_button.visible = true
	
	# Iniciar juego
	start_game()

func start_game() -> void:
	score = 0
	world_speed = 300.0
	game_active = true
	
	instructions.visible = false
	
	player_sprite.play("walk")
	world_movement.position = Vector2.ZERO
	
	player.velocity = Vector2.ZERO
	
	for obstacle in obstacle_spawner.get_children():
		obstacle.queue_free()
	
	update_ui()
	
	spawn_timer.start()
	

func _physics_process(delta: float) -> void:
	if not game_active:
		return
	
	## FISICA DEL JUGADOR ##
	if not player.is_on_floor():
		if player.velocity.y < 0:
			player.velocity.y += gravity * delta
		else:
			player.velocity.y += fall_gravity * delta
	elif player.velocity.y > 0:
		player.velocity.y = 0
	
	player.move_and_slide()
	
	if player.is_on_floor() and player_sprite.animation == "standing":
		player_sprite.play("walk")
	
	## MOVIMIENTO DEL MUNDO ##
	world_movement.position.x -= world_speed * delta
	
	## GESTIÓN DE OBSTÁCULOS ##
	for obstacle in obstacle_spawner.get_children():
		if obstacle.global_position.x < player.global_position.x - 20:
			if not obstacle.has_meta("passed"):
				obstacle.set_meta("passed", true)
				obstacle_passed()
		if obstacle.global_position.x < obstacle_desspawn_x:
			obstacle.queue_free()
	
	loop_ground()
	
	loop_ground()

func loop_ground() -> void:
	if ground.global_position.x < -ground_width / 2:
		ground.position.x = max(ground2.position.x, ground.position.x) + ground_width
	if ground2.global_position.x < -ground_width / 2:
		ground2.position.x = max(ground.position.x, ground2.position.x) + ground_width

func _on_jump_button_pressed() -> void:
	if not game_active:
		return
	if player.is_on_floor():
		player.velocity.y = jump_force
		player_sprite.play("standing")
	else:
		print("No está en el suelo")

func _on_spawn_timer_timeout() -> void:
	if not game_active:
		return
	
	spawn_obstacle()
	
	var random_interval = randf_range(min_random_spawn, max_spawn_interval)
	spawn_timer.wait_time = random_interval

func spawn_obstacle() -> void:
	var obstacle = obstacle_template.duplicate(15)
	obstacle.visible = true
	
	# Usar Y fija guardada
	var target_global = Vector2(player.global_position.x + obstacle_spawn_x, player_ground_y - player_ground_y) # sustituir por 0.0
	var local_position = target_global - world_movement.global_position
	obstacle.position = local_position
	
	for child in obstacle.get_children():
		child.visible = true

	obstacle_spawner.add_child(obstacle)

func _on_obstacle_template_body_entered(body: Node2D):
	if body == player:  # Comparación directa 
		game_over()

func obstacle_passed() -> void:
	score += 1
	world_speed += speed_increase
	
	# Reducir intervalo de spawn (hacer más difícil)
	var new_interval = max(initial_spawn_interval - (score * 0.1), min_spawn_interval)
	spawn_timer.wait_time = new_interval
	
	update_ui()

func update_ui() -> void:
	score_label.text = "Obstáculos: " + str(score)
	speed_label.text = "Velocidad: " + str(int(world_speed))

func game_over() -> void:
	if not game_active:
		return
	
	game_active = false
	spawn_timer.stop()
	
	jump_button.visible = false
	speed_label.visible = false
	score_label.visible = false
	speed_label.visible = false
	result_label.visible = true
	
	result_label.text = " \n"
	result_label.text = "FINISH !!!"
	
	player_sprite.play("fight")
	await get_tree().create_timer(2.0).timeout
	
	if player_sprite.sprite_frames.has_animation("happy"):
		player_sprite.play("happy")
	else:
		player_sprite.play("standing")
	
	var evasion_gain = calculate_evasion_gain(score)
	
	# Mostrar resultado
	result_label.text = "Obstacles overcome: " + str(score) + "\n"
	result_label.text += "Evasion earned: +" + str(evasion_gain)
	
	back_button.visible = true
	
	GameData.add_evasion(evasion_gain)

func calculate_evasion_gain(final_score: int) -> int:
	if final_score >= 20:
		return 5
	elif final_score >= 15:
		return 4
	elif final_score >= 10:
		return 3
	elif final_score >= 5:
		return 2
	elif final_score >= 3:
		return 1
	else:
		return 0

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Training/training.tscn")

func setup_player_sprite() -> void:
	player_sprite.sprite_frames = GameData.get_sprite_frames()  # ← CAMBIAR
	player_sprite.play("standing")
	print("🎨 Sprite del Player configurado:", GameData.evolution_stage)
	
## Para detectar el ancho de la paantalla(Suelo) automaticamente ##
#func detect_ground_width() -> void:
	## Intentar obtener el CollisionShape2D del primer suelo
	#var ground_collision = ground.get_node_or_null("CollisionShape2D")
	#
	#if ground_collision and ground_collision.shape:
		## Si tiene un RectangleShape2D
		#if ground_collision.shape is RectangleShape2D:
			#var shape = ground_collision.shape as RectangleShape2D
			#ground_width = shape.size.x
			#print("Ancho del suelo detectado automáticamente:", ground_width, "px")
		#else:
			#print("El suelo no tiene RectangleShape2D, usando valor por defecto")
			#ground_width = 720.0
	#else:
		#print("No se encontró CollisionShape2D, usando valor por defecto")
		#ground_width = 720.0
	#
	## Verificar que el ancho sea válido
	#if ground_width <= 0:
		#ground_width = 720.0

# FUNCIONES DE MOVER LAS NUVES
func loop_clouds() -> void:
	var clouds = [cloud1, cloud2]
	
	for cloud in clouds:
		if cloud.global_position.x < -100:
			var rightmost_x = get_rightmost_cloud_x(clouds)
			cloud.position.x = rightmost_x + cloud_spacing
			randomize_single_cloud(cloud)

func get_rightmost_cloud_x(clouds: Array) -> float:
	var max_x = -999999.0
	for cloud in clouds:
		if cloud.position.x > max_x:
			max_x = cloud.position.x
	return max_x

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
