extends Control

# Add a reference to the AudioStreamPlayer2D
@onready var click_sound = $ClickSound

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass

func _on_press_start_pressed() -> void:
	click_sound.play() 
	await click_sound.finished  
	get_tree().change_scene_to_file("res://scenes/press_start.tscn")

func _on_about_game_pressed() -> void:
	click_sound.play()
	await click_sound.finished
	get_tree().change_scene_to_file("res://scenes/aboutgame.tscn")

func _on_exit_pressed() -> void:
	click_sound.play()
	await click_sound.finished
	get_tree().quit()
