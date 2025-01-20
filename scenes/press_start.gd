extends Control

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass

func _on_back_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_texture_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/level1.tscn")

func _on_texture_button_2_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/level_2.tscn")
	pass # Replace with function body.

func _on_texture_button_3_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/level_3.tscn")
	pass # Replace with function body.
