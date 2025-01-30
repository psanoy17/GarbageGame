extends Control

# Reference to all panels
@onready var mechanics_panel = $MechanicsPanel
@onready var mechanics_panel2 = $MechanicsPanel2  
@onready var mechanics_panel3 = $MechanicsPanel3
@onready var control_panel = $ControlPanel
@onready var points_panel = $PointsPanel
@onready var trash_panel = $TrashPanel
@onready var trash_panel2 = $TrashPanel2

# Reference to all buttons
@onready var mechanics_btn = $MechanicsBtn
@onready var control_btn = $ControlBtn
@onready var points_btn = $PointsBtn
@onready var trash_btn = $TrashBtn

@onready var click_sound = $ClickSound

# Store current active button
var current_button: TextureButton = null

func _ready() -> void:
	# Hide all panels first
	hide_all_panels()
   
	# Set mechanics as default active
	mechanics_panel.show()
	mechanics_btn.button_pressed = true
	current_button = mechanics_btn

func _process(delta: float) -> void:
	pass

func hide_all_panels() -> void:
	mechanics_panel.hide()
	mechanics_panel2.hide()
	mechanics_panel3.hide()
	control_panel.hide()
	points_panel.hide()
	trash_panel.hide()
	trash_panel2.hide()

func _on_back_btn_pressed() -> void:
	click_sound.play()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_mechanics_btn_pressed() -> void:
	click_sound.play()
	hide_all_panels()
	mechanics_panel.show()
   
	# Update button states
	if current_button:
		current_button.button_pressed = false
	mechanics_btn.button_pressed = true
	current_button = mechanics_btn

func _on_mechanics_next_btn_pressed() -> void:
	click_sound.play()
	mechanics_panel.hide()
	mechanics_panel2.show()

func _on_mechanics_prev_btn_pressed() -> void:
	click_sound.play()
	mechanics_panel2.hide()
	mechanics_panel.show()

func _on_control_btn_pressed() -> void:
	click_sound.play()
	hide_all_panels()
	control_panel.show()
   
	# Update button states
	if current_button:
		current_button.button_pressed = false
	control_btn.button_pressed = true
	current_button = control_btn

func _on_points_btn_pressed() -> void:
	click_sound.play()
	hide_all_panels()
	points_panel.show()
   
	# Update button states
	if current_button:
		current_button.button_pressed = false
	points_btn.button_pressed = true
	current_button = points_btn

func _on_trash_btn_pressed() -> void:
	click_sound.play()
	hide_all_panels()
	trash_panel.show()
   
	# Update button states
	if current_button:
		current_button.button_pressed = false
	trash_btn.button_pressed = true
	current_button = trash_btn

func _on_mechanics_next_btn_2_pressed() -> void:
	click_sound.play()
	mechanics_panel2.hide()
	mechanics_panel3.show()

func _on_mechanics_prev_btn_2_pressed() -> void:
	click_sound.play()
	mechanics_panel3.hide()
	mechanics_panel2.show()

func _on_trash_next_btn_pressed() -> void:
	click_sound.play()
	trash_panel.hide()
	trash_panel2.show()

func _on_trash_prev_btn_pressed() -> void:
	click_sound.play()
	trash_panel2.hide()
	trash_panel.show()
