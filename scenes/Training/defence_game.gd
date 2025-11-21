extends Node2D

# Referencias UI
@onready var score_label := $CanvasLayer/ScoreLabel
@onready var block_button := $CanvasLayer/BlockButton
@onready var result_label := $CanvasLayer/ResultLabel
@onready var back_button := $CanvasLayer/BackButton
@onready var start_button := $CanvasLayer/StartButton
@onready var instruction_label := $CanvasLayer/InstructionLabel

@onready var player_sprite := $PlayerSprite/AnimatedSprite2D
@onready var player_area := $PlayerSprite
@onready var projectile := $Projectile
@onready var projectile_sprite := $Projectile/AnimatedSprite2D
@onready var hitbox_far := $HitboxFar
@onready var hitbox_mid := $HitboxMid
@onready var hitbox_near := $HitboxNear

@onready var cloud_movement := $CloudMovement
@onready var cloud1 := $CloudMovement/Cloud1
@onready var cloud2 := $CloudMovement/Cloud2

# Variables del juego
var score: int = 0
var time_remaining: float = 60.0
var game_active: bool = false
var projectile_speed: float = 200.0
var projectile_start_x: float = 900.0
var projectile_moving: bool = false
var game_timer: Timer

# Variables de nubes
var cloud_speed: float = 200.0
var cloud_spacing: float = 400.0

# Variable para saber en qué zona está el proyectil
var current_zone: String = "none"

func _ready() -> void:
	
	setup_player_sprite()
	
	result_label.visible = false
	back_button.visible = false
	block_button.visible = false
	projectile.visible = false
	score_label.visible = false
	
	instruction_label.visible = true
	instruction_label.text += "Defend the projectile\n" 
	instruction_label.text += "before hitting the T"
	
	game_timer = utils.create_timer(self, 0.1, Callable(self, "_on_game_timer_tick"))
	game_timer.stop()
	
	randomize_cloud_types()

func _process(delta: float) -> void:
	cloud_movement.position.x -= cloud_speed * delta
	loop_clouds()
	
	if not game_active or not projectile_moving:
		return
	
	projectile.position.x -= projectile_speed * delta
	
	# Si el proyectil pasó más allá del Player sin ser bloqueado
	var player_x = player_area.global_position.x
	if projectile.position.x < player_x - 100:
		end_game()

func _on_start_button_pressed() -> void:
	start_button.visible = false
	instruction_label.visible = false
	block_button.visible = true
	
	start_game()

func start_game() -> void:
	score = 0
	time_remaining = 20.0
	game_active = true
	
	score_label.visible = true
	
	update_ui()
	spawn_projectile()

func spawn_projectile() -> void:
	projectile.position.x = projectile_start_x
	projectile.visible = true
	projectile_moving = true
	current_zone = "none"
	projectile_sprite.play()

func _on_game_timer_tick() -> void:
	if not game_active:
		return
	
	if time_remaining <= 0:
		end_game()

## Detectar cuando el proyectil entra en una zona ##
func _on_projectile_area_entered(area: Area2D) -> void:
	if area == player_area:
		end_game()
		return
	
	if area == hitbox_near:
		current_zone = "near"
	elif area == hitbox_mid:
		current_zone = "mid"
	elif area == hitbox_far:
		current_zone = "far"

## Detectar cuando el proyectil sale de una zona ##
func _on_block_button_pressed() -> void:
	if not game_active or not projectile_moving:
		return
	
	play_player_fight_animation()
	
	var points_earned = get_points_for_zone(current_zone) # Verificar en qué zona está el proyectil
	
	if current_zone != "none":
		if points_earned > 0:
			score += points_earned
			update_ui()
			
			projectile_speed += 10.0
			
			projectile.visible = false
			current_zone = "none"
			projectile_moving = false
			
			await get_tree().create_timer(0.1).timeout
			if game_active:
				spawn_projectile()
		else:
			projectile_speed += 10.0
			
			projectile.visible = false
			current_zone = "none"
			projectile_moving = false
			
			await get_tree().create_timer(0.3).timeout
			if game_active:
				spawn_projectile()
	else:
		print("No hay proyectil en zona de bloqueo _on_block_button_pressed()")

func get_points_for_zone(zone: String) -> int:
	match zone:
		"near":
			return 3
		"mid":
			return 2
		"far":
			return 1
		_:
			return 0

func update_ui() -> void:
	score_label.text = "Score: " + str(score)

func end_game() -> void:
	game_active = false
	projectile_moving = false
	score_label.visible = false
	game_timer.stop()
	
	projectile.visible = false
	block_button.visible = false
	result_label.visible = true
	
	result_label.text = " \n"
	result_label.text = "FINISH !!!"
	
	player_sprite.play("fight")
	await get_tree().create_timer(2.0).timeout
	
	if player_sprite.sprite_frames.has_animation("happy"):
		player_sprite.play("happy")
	else:
		player_sprite.play("standing")
		
	var defense_gain = calculate_defense_gain(score)
	
	result_label.text = "Score: " + str(score) + "\n"
	result_label.text += "Defence gain: +" + str(defense_gain)
	result_label.visible = true
	
	await get_tree().create_timer(2.0).timeout
	
	back_button.visible = true
	
	GameData.add_defense(defense_gain)

func calculate_defense_gain(final_score: int) -> int:
	if final_score >= 40:
		return 5
	elif final_score >= 30:
		return 4
	elif final_score >= 20:
		return 3
	elif final_score >= 10:
		return 2
	elif final_score >= 5:
		return 1
	else:
		return 0

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Training/training.tscn")

## FUNCIONES DE ANIMACIÓN DE SPRITES DEL PLAYER ##
func setup_player_sprite() -> void:
	var sprite_path = GameData.get_sprite_frames_path()
	
	if FileAccess.file_exists(sprite_path):
		player_sprite.sprite_frames = load(sprite_path)
		player_sprite.play("standing")
	else:
		var player_scene = load("res://scenes/Player/player.tscn")
		var player_instance = player_scene.instantiate()
		var player_animated_sprite = player_instance.get_node("AnimatedSprite2D")
		player_sprite.sprite_frames = player_animated_sprite.sprite_frames
		player_sprite.play("standing")
		player_instance.queue_free()

func play_player_fight_animation() -> void:
	player_sprite.play("fight")
	
	await player_sprite.animation_finished
	
	player_sprite.play("standing")

## FUNCIONES DE ANIMACION DE NUBE ##
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
