extends Control

@onready var game_over_panel = $GameOverPanel
@onready var new_game_btn = $GameOverPanel/NewGameBtn

func _ready():
	# Hide panel at start
	game_over_panel.hide()

func show_game_over():
	# Show panel with final score
	game_over_panel.show()
	
func hide_game_over():
	game_over_panel.hide()
