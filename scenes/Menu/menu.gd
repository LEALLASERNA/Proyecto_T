extends CanvasLayer

@onready var logo_label := $LogoLabel
@onready var button_container := $ButtonContainer
@onready var new_game_button := $ButtonContainer/NewGameButton
@onready var continue_button := $ButtonContainer/ContinueButton
@onready var exit_button := $ButtonContainer/ExitButton

func _ready() -> void:
	new_game_button.pressed.connect(_on_new_game_pressed)
	continue_button.pressed.connect(_on_continue_pressed)
	exit_button.pressed.connect(_on_exit_pressed)
	
	check_save_file()
	
	fade_in_menu()

func check_save_file() -> void:
	if GameData.save_file_exists():
		continue_button.disabled = false
	else:
		continue_button.disabled = true
		print("No hay partida guardada")

func fade_in_menu() -> void:
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(logo_label, "modulate:a", 1.0, 1.0)
	tween.tween_property(button_container, "modulate:a", 1.0, 1.0)
	await tween.finished

func fade_out_menu() -> void:

	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(logo_label, "modulate:a", 0.0, 0.5)
	tween.tween_property(button_container, "modulate:a", 0.0, 0.5)
	await tween.finished

func _on_new_game_pressed() -> void:
	GameData.reset_game()
	await fade_out_menu()
	get_tree().change_scene_to_file("res://scenes/Menu/egg_selection.tscn")

func _on_continue_pressed() -> void:
	GameData.load_game()
	await fade_out_menu()
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_exit_pressed() -> void:
	await fade_out_menu()
	get_tree().quit()
