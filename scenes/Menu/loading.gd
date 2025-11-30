extends CanvasLayer

@onready var loading_label := $LoadingLabel
@onready var progress_bar := $ProgressBar

func _ready() -> void:
	play_loading_sequence()

func play_loading_sequence() -> void:
	var tween_in = create_tween()
	tween_in.set_parallel(true) 
	tween_in.tween_property(loading_label, "modulate:a", 1.0, 0.5)
	tween_in.tween_property(progress_bar, "modulate:a", 1.0, 0.5)
	await tween_in.finished
	
	var tween_progress = create_tween()
	tween_progress.tween_property(progress_bar, "value", 100, 2.0)
	await tween_progress.finished
	
	var tween_out = create_tween()
	tween_out.set_parallel(true)
	tween_out.tween_property(loading_label, "modulate:a", 0.0, 0.5)
	tween_out.tween_property(progress_bar, "modulate:a", 0.0, 0.5)
	await tween_out.finished
	
	get_tree().change_scene_to_file("res://scenes/Menu/menu.tscn")
