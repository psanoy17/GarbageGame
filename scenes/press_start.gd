extends Control

@onready var click_sound = $ClickSound

func _on_back_btn_pressed() -> void:
	click_sound.play() 
	await click_sound.finished 
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func _on_texture_button_2_pressed() -> void:
	click_sound.play() 
	await click_sound.finished 
	get_tree().change_scene_to_file("res://scenes/level_2.tscn")

func _on_texture_button_3_pressed() -> void:
	click_sound.play() 
	await click_sound.finished 
	get_tree().change_scene_to_file("res://scenes/level_3.tscn")

func _on_trash_rookie_btn_pressed() -> void:
	click_sound.play() 
	await click_sound.finished 
	get_tree().change_scene_to_file("res://scenes/level1.tscn")
	pass # Replace with function body.
