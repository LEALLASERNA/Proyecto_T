extends Node2D

# Referencias UI
@onready var player_sprite := $PlayerSide/PlayerSprite
@onready var enemy_sprite := $EnemySide/EnemySprite
@onready var player_health_sprite := $PlayerSide/PlayerHealthSprite
@onready var player_stats_label := $PlayerSide/PlayerStatsLabel
@onready var enemy_health_sprite := $EnemySide/EnemyHealthSprite
@onready var enemy_stats_label := $EnemySide/EnemyStatsLabel

@onready var strength_button := $ActionButtons/StrengthButton
@onready var defense_button := $ActionButtons/DefenseButton
@onready var evasion_button := $ActionButtons/EvasionButton

@onready var result_label := $ResultLabel
@onready var back_button := $CanvasLayer/BackButton
@onready var start_button := $CanvasLayer/StartButton
@onready var instruction_board := $InstructionBoard
@onready var fight_label := $FightLabel
@onready var congratulation_label := $CongratulationLabel

# Referencias de proyectiles
@onready var player_projectile := $PlayerProjectile
@onready var player_projectile_sprite := $PlayerProjectile/AnimatedSprite2D
@onready var enemy_projectile := $EnemyProjectile
@onready var enemy_projectile_sprite := $EnemyProjectile/AnimatedSprite2D

@onready var cloud_movement := $CloudMovement
@onready var cloud1 := $CloudMovement/Cloud1
@onready var cloud2 := $CloudMovement/Cloud2

# Stats del Player
var player_strength: int = 0
var player_defense: int = 0
var player_evasion: int = 0
var player_hp: int = 10

# Stats del Enemy
var enemy_strength: int = 0
var enemy_defense: int = 0
var enemy_evasion: int = 0
var enemy_hp: int = 10

# Control del combate
var battle_active: bool = false

# Variables de proyectiles
var projectiles_moving: bool = false
var projectile_speed: float = 150.0
var player_projectile_start_pos: Vector2
var enemy_projectile_start_pos: Vector2
var combat_result: String = ""

#Variables de nubes
var cloud_speed: float = 200.0
var cloud_spacing: float = 400.0

# Enum para las acciones
enum Action { STRENGTH, DEFENSE, EVASION }

func _ready() -> void:

	player_strength = GameData.strength
	player_defense = GameData.defense
	player_evasion = GameData.evasion
	
	generate_enemy()
	setup_player_sprite()
	
	enemy_sprite.play("standing")
	
	update_ui()
	
	strength_button.visible = false
	defense_button.visible = false
	evasion_button.visible = false
	
	instruction_board.visible = true
	fight_label.visible = false
	result_label.visible = false
	congratulation_label.visible = false
	
	player_projectile_start_pos = player_projectile.position
	enemy_projectile_start_pos = enemy_projectile.position

	randomize_cloud_types()

	battle_active = false

func _process(delta: float) -> void:
	cloud_movement.position.x -= cloud_speed * delta
	loop_clouds()
	
	if not projectiles_moving:
		return

	if player_projectile.visible:
		player_projectile.position.x += projectile_speed * delta
	
	if enemy_projectile.visible:
		enemy_projectile.position.x -= projectile_speed * delta

func generate_enemy() -> void:
	# Generar enemy con stats aleatorias
	enemy_strength = randi_range(5, 15)
	enemy_defense = randi_range(5, 15)
	enemy_evasion = randi_range(5, 15)
	enemy_hp = 10
	
	print("👾 Enemy generado:")
	print("   Fuerza:", enemy_strength)
	print("   Defensa:", enemy_defense)
	print("   Evasión:", enemy_evasion)

func update_ui() -> void:
	# Actualizar sprites de HP en lugar de labels
	update_health_sprite(player_health_sprite, player_hp)
	update_health_sprite(enemy_health_sprite, enemy_hp)
	
	# Actualizar stats (esto sigue igual)
	player_stats_label.text = "F:" + str(player_strength) + " D:" + str(player_defense) + " E:" + str(player_evasion)
	enemy_stats_label.text = "F:" + str(enemy_strength) + " D:" + str(enemy_defense) + " E:" + str(enemy_evasion)

func _on_start_button_pressed() -> void:
	
	start_button.visible = false
	
	strength_button.visible = true
	defense_button.visible = true
	evasion_button.visible = true
	
	instruction_board.visible = false
	fight_label.visible = true
	fight_label.text = "FIGHT!"
	
	battle_active = true

func _on_strength_button_pressed() -> void:
	if battle_active:
		player_turn(Action.STRENGTH)

func _on_defense_button_pressed() -> void:
	if battle_active:
		player_turn(Action.DEFENSE)

func _on_evasion_button_pressed() -> void:
	if battle_active:
		player_turn(Action.EVASION)

func player_turn(player_action: Action) -> void:
	set_buttons_enabled(false)
	
	var enemy_action: Action = randi_range(0, 2) as Action
	
	combat_result = determine_winner(player_action, enemy_action)
	
	launch_projectiles(player_action, enemy_action)
	
	while projectiles_moving or player_projectile.visible or enemy_projectile.visible:
		await get_tree().process_frame
	
	resolve_turn_damage(player_action, enemy_action)
	
	await get_tree().create_timer(1.5).timeout
	
	player_sprite.play("standing")
	enemy_sprite.play("standing")
	
	if player_hp <= 0 or enemy_hp <= 0:
		end_battle()
	else:
		result_label.visible = false
		fight_label.visible = true
		fight_label.text = "FIGHT!"
		
		set_buttons_enabled(true)

func launch_projectiles(player_action: Action, enemy_action: Action) -> void:
	# Resetear a posiciones iniciales
	player_projectile.position = player_projectile_start_pos
	enemy_projectile.position = enemy_projectile_start_pos
	
	var player_anim = get_action_animation(player_action)
	var enemy_anim = get_action_animation(enemy_action)

	player_projectile_sprite.play(player_anim)
	enemy_projectile_sprite.play(enemy_anim)
	
	player_projectile.visible = true
	enemy_projectile.visible = true
	
	player_sprite.play("fight")
	enemy_sprite.play("fight")
	
	projectiles_moving = true

func _on_player_projectile_area_entered(area: Area2D) -> void:
	if area == enemy_projectile and projectiles_moving:
		projectiles_moving = false
		handle_projectile_collision()

func _on_enemy_projectile_area_entered(area: Area2D) -> void:
	if area == player_projectile and projectiles_moving:
		projectiles_moving = false
		handle_projectile_collision()

func handle_projectile_collision() -> void:
	
	if combat_result == "player":
		enemy_projectile.visible = false
		continue_projectile_to_target("player")
		
	elif combat_result == "enemy":
		player_projectile.visible = false
		continue_projectile_to_target("enemy")
		
	else:
		hide_projectiles()

func continue_projectile_to_target(winner: String) -> void:
	projectiles_moving = true
	
	if winner == "player":
		var target_pos = enemy_projectile_start_pos
		
		while player_projectile.visible and player_projectile.position.x < target_pos.x:
			player_projectile.position.x += projectile_speed * get_process_delta_time()
			await get_tree().process_frame
		
		player_sprite.play("happy")
		enemy_sprite.play("angry")
		
		player_projectile.visible = false
		
	else:
		var target_pos = player_projectile_start_pos
		
		while enemy_projectile.visible and enemy_projectile.position.x > target_pos.x:
			enemy_projectile.position.x -= projectile_speed * get_process_delta_time()
			await get_tree().process_frame
			
		player_sprite.play("angry")
		enemy_sprite.play("happy")
		enemy_projectile.visible = false
	
	projectiles_moving = false

func resolve_turn_damage(player_action: Action, enemy_action: Action) -> void:
	var player_stat = get_stat_value(player_action, true)
	var enemy_stat = get_stat_value(enemy_action, false)
	
	if combat_result == "player":
		var damage = calculate_damage(player_stat, enemy_stat)
		enemy_hp -= damage
		enemy_hp = max(enemy_hp, 0)
		
		fight_label.visible = false
		result_label.visible = true
		result_label.text = "Player: " + str(damage) + " damage"
	
	elif combat_result == "enemy":
		var damage = calculate_damage(enemy_stat, player_stat)
		player_hp -= damage
		player_hp = max(player_hp, 0)
		
		fight_label.visible = false
		result_label.visible = true
		result_label.text = "Enemy " + str(damage) + " damage"
		
		
	else:
		var damage = calculate_damage_draw(player_stat, enemy_stat)
		enemy_hp -= damage
		enemy_hp = max(enemy_hp, 0)
		
		fight_label.visible = false
		result_label.visible = true
		result_label.text = "Draw"
	
	update_ui()

func determine_winner(player_action: Action, enemy_action: Action) -> String:
	if player_action == enemy_action:
		return "draw"
	
	# Fuerza gana a Evasión
	if player_action == Action.STRENGTH and enemy_action == Action.EVASION:
		return "player"
	if enemy_action == Action.STRENGTH and player_action == Action.EVASION:
		return "enemy"
	
	# Defensa gana a Fuerza
	if player_action == Action.DEFENSE and enemy_action == Action.STRENGTH:
		return "player"
	if enemy_action == Action.DEFENSE and player_action == Action.STRENGTH:
		return "enemy"
	
	# Evasión gana a Defensa
	if player_action == Action.EVASION and enemy_action == Action.DEFENSE:
		return "player"
	if enemy_action == Action.EVASION and player_action == Action.DEFENSE:
		return "enemy"
	
	return "draw"

func calculate_damage(winner_stat: int, loser_stat: int) -> int:
	if winner_stat > loser_stat:
		return 3
	elif winner_stat == loser_stat:
		return 3
	else:
		return 3

func calculate_damage_draw(winner_stat: int, loser_stat: int) -> int:
	if winner_stat > loser_stat:
		return 2
	elif winner_stat == loser_stat:
		return 1
	else:
		return 0

func get_stat_value(action: Action, is_player: bool) -> int:
	if is_player:
		match action:
			Action.STRENGTH: return player_strength
			Action.DEFENSE: return player_defense
			Action.EVASION: return player_evasion
	else:
		match action:
			Action.STRENGTH: return enemy_strength
			Action.DEFENSE: return enemy_defense
			Action.EVASION: return enemy_evasion
	return 0

func get_action_name(action: Action) -> String:
	match action:
		Action.STRENGTH: return "Fuerza"
		Action.DEFENSE: return "Defensa"
		Action.EVASION: return "Evasión"
	return ""

func get_action_animation(action: Action) -> String:
	match action:
		Action.STRENGTH: return "strength"
		Action.DEFENSE: return "defense"
		Action.EVASION: return "evasion"
	return "strength"

func set_buttons_enabled(enabled: bool) -> void:
	strength_button.disabled = not enabled
	defense_button.disabled = not enabled
	evasion_button.disabled = not enabled

func hide_projectiles() -> void:
	player_projectile.visible = false
	enemy_projectile.visible = false
	projectiles_moving = false
	
	player_sprite.play("fight")
	enemy_sprite.play("fight")
	
	await get_tree().create_timer(0.5).timeout

func end_battle() -> void:
	battle_active = false
	
	set_buttons_enabled(false)
	strength_button.visible = false
	defense_button.visible = false
	evasion_button.visible = false
	
	fight_label.visible = false
	result_label.visible = false
	
	if player_hp <= 0:
		player_sprite.play("angry")
		enemy_sprite.play("happy")
		
		congratulation_label.visible = true
		congratulation_label.text = "ENEMY WINS"
		
	else:
		player_sprite.play("happy")
		enemy_sprite.play("angry")
		
		congratulation_label.visible = true
		congratulation_label.text = " YOU WIN !"
		
	await get_tree().create_timer(3.0).timeout
	
	back_button.visible = true

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func update_health_sprite(health_sprite: AnimatedSprite2D, hp: int) -> void:
	var animation_name = "0" + str(hp)
	
	if health_sprite.sprite_frames.has_animation(animation_name):
		health_sprite.play(animation_name)
		print("HP:", animation_name)
	else:
		print("Animación no encontrada: update_health_sprite()", animation_name)

func setup_player_sprite() -> void:
	var sprite_path = GameData.get_sprite_frames_path()
	
	if FileAccess.file_exists(sprite_path):
		player_sprite.sprite_frames = load(sprite_path)
		player_sprite.play("standing")
	else:
		player_sprite.play("standing")
		
## FUNCIONES DEL MOVIMIENTO DE LAS NUVES ##
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
