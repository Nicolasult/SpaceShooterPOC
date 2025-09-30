extends Control

func _ready() -> void:
	$VBox/BtnLevels.pressed.connect(_on_levels)
	$VBox/BtnShips.pressed.connect(_on_ships)

func _on_levels() -> void:
	get_tree().change_scene_to_file("res://content/ui/levels_menu.tscn")

func _on_ships() -> void:
	get_tree().change_scene_to_file("res://content/ui/ships_menu.tscn")
