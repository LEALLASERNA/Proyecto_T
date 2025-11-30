extends Node2D

# Referencias a nodos
@onready var left_button := $CanvasLayer/LeftButton
@onready var right_button := $CanvasLayer/RightButton
@onready var score_label := $CanvasLayer/ScoreLabel
@onready var time_label := $CanvasLayer/TimeLabel
@onready var seconds_label := $CanvasLayer/SecondsLabel
@onready var result_label := $CanvasLayer/ResultLabel
@onready var back_button := $CanvasLayer/BackButton
@onready var button_effect := $CanvasLayer/BangEffect
@onready var puchingbag_effect := $CanvasLayer/PunchingBag
@onready var instruction_label := $CanvasLayer/Instruction
@onready var player_sprite := $PlayerSprite
@onready var instruction_board:= $CanvasLayer/InstructionBoard

@onready var cloud_movement := $CloudMovement
@onready var cloud1 := $CloudMovement/Cloud1
@onready var cloud2 := $CloudMovement/Cloud2

# Variables del juego
var score: int = 0
var time_remaining: float = 10.0
var game_active: bool = false
var next_button: String = "left"
var game_timer: Timer

# Variables de nubes
var cloud_speed: float = 200.0
var cloud_spacing: float = 400.0

func _ready() -> void:
	setup_player_sprite()
	instruction_effect()
	
	result_label.visible = false
	back_button.visible = false
	instruction_label.visible = true
	seconds_label.visible = false
	score_label.visible = false
	
	game_timer = utils.create_timer(self, 0.1, Callable(self, "_on_game_timer_tick"))
	game_timer.stop()
	
	randomize_cloud_types()
	prepare_game()

func _process(delta: float) -> void:
	cloud_movement.position.x -= cloud_speed * delta
	loop_clouds()

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

func prepare_game() -> void:
	# Preparar variables iniciales
	score = 0
	time_remaining = 10.0
	game_active = false 
	next_button = "left"
	
	seconds_label.text = str(int(time_remaining))
	
	highlight_next_button()

func start_game() -> void:
	game_active = true
	
	game_timer.start()
	
	time_label.visible = true
	seconds_label.visible = true
	seconds_label.text = str(int(time_remaining))

func _on_game_timer_tick() -> void:
	if not game_active:
		return
	
	time_remaining -= 0.1
	
	time_label.text = "Time remaining: "
	seconds_label.text = str(int(time_remaining))

	if time_remaining <= 0:
		end_game()

func instruction_effect() -> void:
	instruction_board.frame = 0
	instruction_board.visible = true
	instruction_board.play()

func _on_left_button_pressed() -> void:
	if not game_active and next_button == "left":
		instruction_label.visible = false
		start_game()  # ← Iniciar el juego
		instruction_board.visible = false
	if not game_active:
		return
	
	if next_button == "left":
		play_button_effect()
		play_punching_bag_effect()
		play_player_fight_animation()
		
		score += 1
		next_button = "right"
		highlight_next_button()
	else:
		print("¡Error! Debes pulsar el botón DERECHO")

func _on_right_button_pressed() -> void:
	if not game_active:
		return
	
	if next_button == "right":
		play_button_effect()
		play_punching_bag_effect()
		play_player_fight_animation()
		
		score += 1
		next_button = "left"
		highlight_next_button()
	else:
		print("¡Error! Debes pulsar el botón IZQUIERDO")

func play_button_effect() -> void:
	button_effect.frame = 0
	button_effect.visible = true
	button_effect.play()

func play_punching_bag_effect() -> void:
	puchingbag_effect.frame = 0
	puchingbag_effect.visible = true
	puchingbag_effect.play()

func highlight_next_button() -> void:
	if next_button == "left":
		left_button.modulate = Color(1, 1, 0)  
		right_button.modulate = Color(1, 1, 1)  
	else:
		left_button.modulate = Color(1, 1, 1) 
		right_button.modulate = Color(1, 1, 0)

func end_game() -> void:
	game_active = false
	game_timer.stop()
	
	left_button.visible = false
	right_button.visible = false
	time_label.visible = false
	seconds_label.visible = false
	
	player_sprite.play("happy")
	
	await get_tree().create_timer(2.0).timeout
	
	var strength_gain = calculate_strength_gain(score)

	score_label.visible = true
	result_label.text += "Score: " + str(score) + "\n"
	result_label.text += "Strength gained: +" + str(strength_gain)
	result_label.visible = true
	back_button.visible = true
	
	apply_strength_gain(strength_gain)
	
	GameData.add_strength(strength_gain)

func calculate_strength_gain(final_score: int) -> int:
	if final_score >= 50:
		return 5
	elif final_score >= 40:
		return 4
	elif final_score >= 30:
		return 3
	elif final_score >= 20:
		return 2
	elif final_score >= 10:
		return 1
	else:
		return 0

func apply_strength_gain(amount: int) -> void:
	print("Se debería aumentar la fuerza en:", amount)
	# TODO: Implementar sistema de guardado de stats

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Training/training.tscn")

func setup_player_sprite() -> void:
	player_sprite.sprite_frames = GameData.get_sprite_frames()
	player_sprite.play("standing")
	print("🎨 Sprite del Player configurado:", GameData.evolution_stage)

func play_player_fight_animation() -> void:
	player_sprite.play("fight")
	await player_sprite.animation_finished
	player_sprite.play("standing")
