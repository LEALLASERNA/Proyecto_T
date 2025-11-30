extends CanvasLayer

@onready var title_label := $TitleLabel
@onready var creator_label = $CreatorLabel

func _ready() -> void:
	play_splash_sequence()

func play_splash_sequence() -> void:
	var tween_in = create_tween()
	tween_in.tween_property(title_label, "modulate:a", 1.0, 1.0)
	tween_in.tween_property(creator_label, "modulate:a", 1.0, 1.0)
	await tween_in.finished
	
	await get_tree().create_timer(2.0).timeout
	
	var tween_out = create_tween()
	tween_out.tween_property(title_label, "modulate:a", 0.0, 1.0)
	tween_out.tween_property(creator_label, "modulate:a", 0.0, 1.0)
	await tween_out.finished
	
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file("res://scenes/Menu/loading.tscn")
