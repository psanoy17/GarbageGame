extends Node2D

var selected_bin = 0
var current_index = 0
var props = [
	{ "texture": preload("res://assets/Props-Objects/Batteries_Trash.PNG"), "category": 2 },
	{ "texture": preload("res://assets/Props-Objects/Box_Trash.PNG"), "category": 0 },
	{ "texture": preload("res://assets/Props-Objects/CandyWrapper_Trash.PNG"), "category": 1 },
	{ "texture": preload("res://assets/Props-Objects/Ceramics_Trash.PNG"), "category": 1 },
	{ "texture": preload("res://assets/Props-Objects/CleaningSupplies_Trash.PNG"), "category": 2 },
	{ "texture": preload("res://assets/Props-Objects/Diaper_Trash.PNG"), "category": 1 },
	{ "texture": preload("res://assets/Props-Objects/Glass_Trash.PNG"), "category": 0 },
	{ "texture": preload("res://assets/Props-Objects/LeftoverFood_Trash.PNG"), "category": 1 },
	{ "texture": preload("res://assets/Props-Objects/LeftoverFood2_Trash.PNG"), "category": 1 },
	{ "texture": preload("res://assets/Props-Objects/Oil_Trash.PNG"), "category": 2 },
	{ "texture": preload("res://assets/Props-Objects/Paint_Trash.PNG"), "category": 2 },
	{ "texture": preload("res://assets/Props-Objects/Papers_Trash.PNG"), "category": 0 },
	{ "texture": preload("res://assets/Props-Objects/PlasticBottle_Trash.PNG"), "category": 0 },
	{ "texture": preload("res://assets/Props-Objects/PlasticCup_Trash.PNG"), "category": 0 },
	{ "texture": preload("res://assets/Props-Objects/SanitaryNapkin_Trahs.PNG"), "category": 1 },
	{ "texture": preload("res://assets/Props-Objects/ScrapMetals_Trash.PNG"), "category": 0 },
	{ "texture": preload("res://assets/Props-Objects/SprayCannister_Trash.PNG"), "category": 2 },
	{ "texture": preload("res://assets/Props-Objects/Styrofoam_Trash.PNG"), "category": 1 },
	{ "texture": preload("res://assets/Props-Objects/Thinners_Trash.PNG"), "category": 2 },
	{ "texture": preload("res://assets/Props-Objects/TinCan2_Trash.PNG"), "category": 0 },
	{ "texture": preload("res://assets/Props-Objects/TinCans_Trash.PNG"), "category": 0 },
	{ "texture": preload("res://assets/Props-Objects/WornOutRug_Trash.PNG"), "category": 1 }
]

# Power bar variables
var indicator_moving = false
var indicator_direction = 1
var indicator_speed = 300
var power_bar_range = Vector2(300, 780)
var green_zone_start = 460
var green_zone_end = 640
var can_throw = true

# Game state variables
var score = 0
var time_left = 60  # 60 seconds game time
var game_active = true
var throwing = false
var throw_start_pos = Vector2.ZERO
var throw_target_pos = Vector2.ZERO
var throw_progress = 0.0
var throw_duration = 0.8  # Increased for smoother animation

func _ready() -> void:
	randomize_next_item()  # Shuffle items at the start
	populate_placeholder()
	populate_sorting_tray()
	update_arrow_position()
	$PowerBarIndicator.position.x = power_bar_range.x
	$ScoreLabel.text = "Score: 0"
	$TimerLabel.text = "Time: 60"
	# Set initial position of placeholder
	$PlaceholderAsset.position = Vector2(950, 950)
	throw_start_pos = $PlaceholderAsset.position

func _process(delta: float) -> void:
	if game_active:
		update_timer(delta)
		update_indicator(delta)
		if throwing:
			update_throw_animation(delta)

func update_timer(delta: float) -> void:
	time_left -= delta
	if time_left <= 0:
		time_left = 0
		game_active = false
		$GameOverControl.show_game_over(score)
		if has_node("GameOverLabel"):
			$GameOverLabel.hide()
	$TimerLabel.text = "Time: " + str(int(time_left))

func update_indicator(delta: float) -> void:
	if indicator_moving:
		$PowerBarIndicator.position.x += indicator_speed * indicator_direction * delta
		if $PowerBarIndicator.position.x >= power_bar_range.y:
			$PowerBarIndicator.position.x = power_bar_range.y
			indicator_direction = -1
		elif $PowerBarIndicator.position.x <= power_bar_range.x:
			$PowerBarIndicator.position.x = power_bar_range.x
			indicator_direction = 1

func update_throw_animation(delta: float) -> void:
	if throwing:
		throw_progress += delta / throw_duration
		if throw_progress >= 1.0:
			throwing = false
			throw_progress = 0.0
			complete_throw()
		else:
			var t = throw_progress
			var pos = Vector2()
			pos.x = lerp(throw_start_pos.x, throw_target_pos.x, t)
			var start_y = throw_start_pos.y
			var end_y = throw_target_pos.y
			var control_y = min(start_y, end_y) - 300
			pos.y = pow(1 - t, 2) * start_y + 2 * (1 - t) * t * control_y + pow(t, 2) * end_y
			var garbage_sprite = get_node("TemporaryGarbage")
			garbage_sprite.position = pos
			garbage_sprite.rotation = t * 10

func _input(event: InputEvent) -> void:
	if not game_active:
		return
	if event.is_action_pressed("ui_left"):
		selected_bin = max(selected_bin - 1, 0)
		update_arrow_position()
	elif event.is_action_pressed("ui_right"):
		selected_bin = min(selected_bin + 1, 2)
		update_arrow_position()
	if event.is_action_pressed("ui_accept") and can_throw and not throwing:
		indicator_moving = true
	elif event.is_action_released("ui_accept") and indicator_moving:
		indicator_moving = false
		check_throw_success()

func check_throw_success() -> void:
	var current_pos = $PowerBarIndicator.position.x
	var is_good_power = current_pos >= green_zone_start and current_pos <= green_zone_end
	if is_good_power:
		start_throw_animation(true)
	else:
		start_weak_throw_animation() if current_pos < green_zone_start else start_strong_throw_animation()
	$PowerBarIndicator.position.x = power_bar_range.x
	can_throw = true

func start_throw_animation(is_good_power: bool) -> void:
	throwing = true
	throw_progress = 0.0
	throw_start_pos = $PlaceholderAsset.position
	for child in $PlaceholderAsset.get_children():
		child.queue_free()
	var garbage_sprite = Sprite2D.new()
	garbage_sprite.texture = props[current_index]["texture"]
	garbage_sprite.position = throw_start_pos
	garbage_sprite.name = "TemporaryGarbage"
	add_child(garbage_sprite)
	var bins = $Bins.get_children()
	throw_target_pos = bins[selected_bin].position
	garbage_sprite.set_meta("good_power", is_good_power)

func start_weak_throw_animation() -> void:
	start_throw_animation(false)
	throw_target_pos = Vector2(-100, throw_start_pos.y)

func start_strong_throw_animation() -> void:
	start_throw_animation(false)
	throw_target_pos = Vector2(1500, throw_start_pos.y)

func complete_throw() -> void:
	var prop_category = props[current_index]["category"]
	var garbage_sprite = get_node("TemporaryGarbage")
	var is_good_power = garbage_sprite.get_meta("good_power")
	if is_good_power and selected_bin == prop_category:
		score += 10
	elif is_good_power and score >= 5:
		score -= 5
	score = max(score, 0)
	$ScoreLabel.text = "Score: " + str(score)
	if score >= 20:
		game_active = false
		if has_node("GameOverLabel"):
			$GameOverLabel.hide()
		$YouWinControl.show()
		return
	if has_node("TemporaryGarbage"):
		get_node("TemporaryGarbage").queue_free()
	move_to_next_item()

func move_to_next_item() -> void:
	current_index = (current_index + 1) % props.size()
	populate_placeholder()
	populate_sorting_tray()

func randomize_next_item() -> void:
	props.shuffle()

func populate_placeholder() -> void:
	for child in $PlaceholderAsset.get_children():
		child.queue_free()
	var sprite = Sprite2D.new()
	sprite.texture = props[current_index]["texture"]
	$PlaceholderAsset.add_child(sprite)

func populate_sorting_tray() -> void:
	for child in $SortingTrayAsset.get_children():
		child.queue_free()
	var spacing = 200
	var start_x = -195
	for i in range(3):
		var next_index = (current_index + i + 1) % props.size()
		var sprite = Sprite2D.new()
		sprite.texture = props[next_index]["texture"]
		sprite.position = Vector2(start_x + (spacing * i), 0)
		sprite.scale = Vector2(0.7, 0.7)
		$SortingTrayAsset.add_child(sprite)

func update_arrow_position() -> void:
	var bins = $Bins.get_children()
	$Control/Arrow.position.x = bins[selected_bin].position.x

func _on_back_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/press_start.tscn")
	pass # Replace with function body.


func _on_new_game_btn_pressed() -> void:
	# Reset game state
	score = 0
	time_left = 60
	game_active = true
	current_index = 0
	
	# Reset UI
	$ScoreLabel.text = "Score: 0"
	$TimerLabel.text = "Time: 60"
	
	# Clean up any existing temporary garbage sprite
	if has_node("TemporaryGarbage"):
		get_node("TemporaryGarbage").queue_free()
	
	# Clean up placeholder before populating new items
	for child in $PlaceholderAsset.get_children():
		child.queue_free()
		
	# Reset props and game elements
	randomize_next_item()
	
	populate_placeholder()
	populate_sorting_tray()
	update_arrow_position()
	
	# Hide game over panel
	$GameOverControl.hide_game_over()
	$YouWinControl.hide()
	
	# Reset power bar
	$PowerBarIndicator.position.x = power_bar_range.x
	indicator_moving = false
	can_throw = true
