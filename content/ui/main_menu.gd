extends Control

func _ready() -> void:
	$VBox/BtnLevels.pressed.connect(_on_levels)

func _on_levels() -> void:
	get_tree().change_scene_to_file("res://ui/LevelsMenu.tscn")
