extends Node

# ========== STATS DE COMBATE ==========
var strength: int = 0
var defense: int = 0
var evasion: int = 0
var luck: int = 10

# ========== STATS DE CUIDADO ==========
var hunger: int = 100
var happiness: int = 100

# ========== SISTEMA DE EVOLUCION ==========
var player_sprite_frames: SpriteFrames = null
var current_animation: String = "walk"     
var current_form: String = "base"

var evolution_stage: String = "baby"
var has_evolved_to_young: bool = false

# Umbrales de evolución (configurables)
const EVOLUTION_THRESHOLDS = {
	"young": {"strength": 10, "defense": 10, "evasion": 10},
	"adult": {"strength": 25, "defense": 25, "evasion": 25},
	"elite": {"strength": 50, "defense": 50, "evasion": 50}
}

# ========== DATOS DE GUARDADO ==========
const SAVE_PATH = "user://save_data.json"

# ========== FUNCIONES DE INICIO ==========
func _ready() -> void:
	load_game()
	print("   Etapa evolutiva:", evolution_stage)

# ========== FUNCIONES PARA MODIFICAR STATS ==========
func add_strength(amount: int) -> void:
	strength += amount
	check_evolution_conditions()  # Verificar evolución
	save_game()  # Guardar automáticamente

func add_defense(amount: int) -> void:
	defense += amount
	check_evolution_conditions()  # Verificar evolución
	save_game()

func add_evasion(amount: int) -> void:
	evasion += amount
	check_evolution_conditions()  # Verificar evolución
	save_game()

func set_hunger(value: int) -> void:
	hunger = clamp(value, 0, 100)
	save_game()

func set_happiness(value: int) -> void:
	happiness = clamp(value, 0, 100)
	save_game()

func get_all_stats() -> Dictionary:
	return {
		"strength": strength,
		"defense": defense,
		"evasion": evasion,
		"luck": luck,
		"hunger": hunger,
		"happiness": happiness,
		"current_form": current_form,
		"evolution_stage": evolution_stage
	}

# ========== SISTEMA DE EVOLUCIÓN ========== #

## Verifica si el Player cumple condiciones para evolucionar
func check_evolution_conditions() -> bool:
	if has_evolved_to_young:
		return false
	
	if evolution_stage == "baby":
		var threshold = EVOLUTION_THRESHOLDS["young"]
		if strength >= threshold["strength"] and \
		   defense >= threshold["defense"] and \
		   evasion >= threshold["evasion"]:
			print("Condiciones de evolución a JOVEN cumplidas")
			print("   Fuerza: ", strength, "/", threshold["strength"])
			print("   Defensa: ", defense, "/", threshold["defense"])
			print("   Evasión: ", evasion, "/", threshold["evasion"])
			return true
	
	# En el futuro aqui añadiré la verificación para "adult" y "elite"
	
	return false

## Ejecuta la evolución a una nueva etapa
func evolve_to(new_stage: String) -> void:
	evolution_stage = new_stage
	
	if new_stage == "young":
		has_evolved_to_young = true
	
	print("🌟 ¡Evolución completada! Nueva etapa:", evolution_stage)
	save_game()

## Obtiene el path del SpriteFrames según la etapa evolutiva
func get_sprite_frames_path() -> String:
	match evolution_stage:
		"baby":
			return "res://resources/player_sprite_frames_baby.tres"
		"young":
			return "res://resources/player_sprite_frames_young.tres"
		"adult":
			return "res://resources/player_sprite_frames_adult.tres"
		"elite":
			return "res://resources/player_sprite_frames_elite.tres"
		_:
			return "res://assets/sprites/player/player_sprite_frames_baby.tres"

## Resetea el flag de evolución (útil si quiero permitir re-evolucionar)
func reset_evolution_flag() -> void:
	has_evolved_to_young = false
	save_game()

# ========== SISTEMA DE GUARDADO ========== #

## Guarda los datos en disco
func save_game() -> void:
	var save_data = {
		"strength": strength,
		"defense": defense,
		"evasion": evasion,
		"luck": luck,
		"hunger": hunger,
		"happiness": happiness,
		"current_form": current_form,
		"evolution_stage": evolution_stage,
		"has_evolved_to_young": has_evolved_to_young
	}
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		var json_string = JSON.stringify(save_data)
		file.store_string(json_string)
		file.close()
		#print("💾 Juego guardado")
	else:
		print("Error al guardar en funcion save_data()")

## Carga los datos desde disco
func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		print("Error no hay guardado previo funcion load_game()")
		return
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		
		if parse_result == OK:
			var data = json.data
			
			strength = data.get("strength", 10)
			defense = data.get("defense", 10)
			evasion = data.get("evasion", 10)
			luck = data.get("luck", 10)
			hunger = data.get("hunger", 100)
			happiness = data.get("happiness", 100)
			current_form = data.get("current_form", "base")
			evolution_stage = data.get("evolution_stage", "baby")
			has_evolved_to_young = data.get("has_evolved_to_young", false)
			
			print("📂 Juego cargado:")
			print("   Fuerza:", strength)
			print("   Defensa:", defense)
			print("   Evasión:", evasion)
			print("   Etapa evolutiva:", evolution_stage)
		else:
			print("Error del JSON load_game()")
	else:
		print("Error de la carga de archivo archivo load_game()")

## Resetea todos los datos que de momento no utilizo
func reset_game() -> void:
	strength = 10
	defense = 10
	evasion = 10
	luck = 10
	hunger = 100
	happiness = 100
	current_form = "base"
	evolution_stage = "baby"
	has_evolved_to_young = false
	save_game()
	print("🔄 Datos reseteados")
