extends CharacterBody2D

signal evolution_triggered  # ← AÑADIDO: Señal de evolución

# Acceso al HUD
@onready var ui_player := get_tree().get_current_scene().get_node("UIPlayer")
@onready var animated_sprite := $AnimatedSprite2D  # ← AÑADIDO: Referencia al sprite
@onready var battle_alert := $BattleAlert
@onready var alert_button := $BattleAlert/AlertButton

# Sistema de movimiento
var game_paused: bool = false

# Sistema de hambre
var hunger: int = 100
var max_hunger: int = 100
var hunger_timer: Timer
var food_amount: int = 20  

# Sistema de felicidad
var happiness: int = 100
var max_happiness: int = 100
var happiness_from_food: int = 15

# Sistema de stats de combate
var strength: int = 9    
var defence: int = 9  
var evasion: int = 9    
var luck: int = 9  
	   
# Sistema de evolución
var evolution_checked_this_session: bool = false

# Sistema de alarma de combate
var battle_timer: Timer
var min_battle_interval: float = 30  
var max_battle_interval: float = 31  
var alert_offset_y: float = -100.0 
var battle_alert_visible: bool = false

func _ready() -> void:
	print("👤 Player inicializado")
	
	# Cargar stats desde GameData
	strength = GameData.strength
	defence = GameData.defense
	evasion = GameData.evasion
	luck = GameData.luck
	hunger = GameData.hunger
	happiness = GameData.happiness
	
	# Esperar un frame para asegurar que todo está cargado
	await get_tree().process_frame
	
	# Cargar sprite según etapa evolutiva
	load_sprite_for_current_stage()
	
	# Verificar evolución
	check_for_evolution()
	
	# Actualizar barras de UI
	update_hunger_bar()
	update_happiness_bar()
	
	# Conectar señal de alimentación
	if ui_player:
		ui_player.connect("feed_button_pressed", Callable(self, "feed"))
	
	# Iniciar timer de hambre
	hunger_timer = utils.create_timer(self, 0.5, Callable(self, "_on_hunger_timer_timeout"))
	
	# Configurar sistema de batallas
	setup_battle_system()

#func _physics_process(delta: float) -> void:
	#pass

## ========== SISTEMA DE HAMBRE Y FELICIDAD ========== ##
func _on_hunger_timer_timeout() -> void:
	hunger -= 1
	hunger = clamp(hunger, 0, max_hunger)
	update_hunger_bar()
	
	if hunger == 10:
		happiness -= 20
		update_happiness_bar()
	elif hunger == 20:
		happiness -= 20
		update_happiness_bar()
	elif hunger == 30:
		happiness -= 10
		update_happiness_bar()
	elif hunger == 40:
		happiness -= 10
		update_happiness_bar()
	elif hunger == 50:
		happiness -= 10
		update_happiness_bar()
	
	happiness = clamp(happiness, 0, max_happiness)
	
	GameData.set_hunger(hunger)
	GameData.set_happiness(happiness)

func update_hunger_bar() -> void:
	if ui_player:
		ui_player.set_hunger(hunger)

func update_happiness_bar() -> void:
	if ui_player:
		ui_player.set_happiness(happiness)

func feed() -> void:
	hunger += food_amount
	hunger = clamp(hunger, 0, max_hunger)
	
	happiness += happiness_from_food
	happiness = clamp(happiness, 0, max_happiness)
	
	GameData.set_hunger(hunger)
	GameData.set_happiness(happiness)
	
	update_hunger_bar()
	update_happiness_bar()

## ========== SISTEMA DE ESTADISTICAS ========== ##
func get_strength() -> int:
	return strength

func get_defence() -> int:
	return defence

func get_evasion() -> int:
	return evasion

func get_luck() -> int:
	return luck

func get_all_stats() -> Dictionary:
	return {
		"strength": strength,
		"defence": defence,
		"evasion": evasion,
		"luck": luck
	}

func print_stats() -> void:
	print("=== STATS DEL PLAYER ===")
	print("Fuerza:", strength)
	print("Defensa:", defence)
	print("Esquivar:", evasion, "%")
	print("Suerte:", luck, "%")
	print("========================")

func modify_stat(stat_name: String, amount: int) -> void:
	match stat_name:
		"strength":
			strength += amount
			strength = max(strength, 0)
		"defence":
			defence += amount
			defence = max(defence, 0)
		"evasion":
			evasion += amount
			evasion = clamp(evasion, 0, 100)
		"luck":
			luck += amount
			luck = clamp(luck, 0, 100)
		_:
			print("Stat no reconocida: modify_stat()", stat_name)
	
	print("OK", stat_name, "modificada en", amount, "(Nueva:", get(stat_name), ")")

func set_stat(stat_name: String, value: int) -> void:
	match stat_name:
		"strength":
			strength = max(value, 0)
		"defense":
			defence = max(value, 0)
		"evasion":
			evasion = clamp(value, 0, 100)
		"luck":
			luck = clamp(value, 0, 100)
		_:
			print("Stat no reconocida:", stat_name)
	
	print("OK", stat_name, "establecida en", value)

func level_up(strength_bonus: int, defence_bonus: int, evasion_bonus: int, luck_bonus: int) -> void:
	strength += strength_bonus
	defence += defence_bonus
	evasion = clamp(evasion + evasion_bonus, 0, 100)
	luck = clamp(luck + luck_bonus, 0, 100)
	print_stats()

## ========== SISTEMA TRIGGER BATALLA ========== ##
func setup_battle_system() -> void:
	battle_alert.visible = false

	var interval = get_random_battle_interval()
	battle_timer = utils.create_timer(self, interval, Callable(self, "_on_battle_timer_timeout"))

func get_random_battle_interval() -> float:
	return randf_range(min_battle_interval, max_battle_interval)

func _on_battle_timer_timeout() -> void:
	if not battle_alert_visible:
		show_battle_alert()

func show_battle_alert() -> void:
	battle_alert.visible = true
	battle_alert_visible = true
	
	animated_sprite.play("standing")
	
	if ui_player:
		ui_player.pause_ground()
	
	animate_alert_bounce()

func hide_battle_alert() -> void:
	battle_alert.visible = false
	battle_alert_visible = false
	game_paused = false
	
	animated_sprite.play("walk")
	
	if ui_player:
		ui_player.resume_ground()
		
	# Reiniciar timer para próxima batalla
	var interval = get_random_battle_interval()
	battle_timer.wait_time = interval
	battle_timer.start()

func _on_alert_button_pressed() -> void:
	hide_battle_alert()
	
	get_tree().change_scene_to_file("res://scenes/Battle/battle.tscn")

func animate_alert_bounce() -> void:
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(battle_alert, "position:y", alert_offset_y - 100, 1)
	tween.tween_property(battle_alert, "position:y", alert_offset_y - 50, 1)

## ========== SISTEMA DE EVOLUCION ========== ##

func load_sprite_for_current_stage() -> void:
	var sprite_path = GameData.get_sprite_frames_path()
	animated_sprite.sprite_frames = load(sprite_path)
	animated_sprite.play("walk")
	
	print("Sprite cargado para etapa: load_sprite_for_current_stage()", GameData.evolution_stage)

func check_for_evolution() -> void:
	if evolution_checked_this_session:
		return
	
	evolution_checked_this_session = true
	
	if GameData.check_evolution_conditions():
		await get_tree().create_timer(0.5).timeout
		
		start_evolution_animation()

func start_evolution_animation() -> void:
	emit_signal("evolution_triggered")
	
	set_physics_process(false)
	
	await play_evolution_sequence()
	
	GameData.evolve_to("young")
	load_sprite_for_current_stage()
	
	# Reactivar movimiento
	set_physics_process(true)

func play_evolution_sequence() -> void:
	animated_sprite.play("standing")
	await get_tree().create_timer(1.0).timeout
	
	await get_tree().create_timer(2.0).timeout
	
	animated_sprite.play("happy")
	await get_tree().create_timer(1.5).timeout
