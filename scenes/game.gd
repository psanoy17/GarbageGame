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
	props.shuffle()
	populate_placeholder()
	populate_sorting_tray()
	update_arrow_position()
	$PowerBarIndicator.position.x = power_bar_range.x
	$ScoreLabel.text = "Score: 0"
	$TimerLabel.text = "Time: 60"
	# Set initial position of placeholder
	$PlaceholderAsset.position = Vector2(950, 950)  # Adjust these coordinates as needed
	throw_start_pos = $PlaceholderAsset.position

func _process(delta: float) -> void:
	if game_active:
		update_timer(delta)
		update_indicator(delta)
		if throwing:
			update_throw_animation(delta)

func update_timer(delta: float) -> void:
	time_left -= delta
	$TimerLabel.text = "Time: " + str(ceil(time_left))
	
	if time_left <= 0:
		game_active = false
		$GameOverControl.show_game_over(score)
		# Hide the old game over label if it exists
		if has_node("GameOverLabel"):
			$GameOverLabel.hide()

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
			# Enhanced arc animation
			var t = throw_progress
			var pos = Vector2()
			
			# Horizontal position
			pos.x = lerp(throw_start_pos.x, throw_target_pos.x, t)
			
			# Vertical position with enhanced arc
			var start_y = throw_start_pos.y
			var end_y = throw_target_pos.y
			var control_y = min(start_y, end_y) - 300  # Arc height
			pos.y = pow(1 - t, 2) * start_y + \
					2 * (1 - t) * t * control_y + \
					pow(t, 2) * end_y
			
			# Update position of the temporary garbage sprite
			var garbage_sprite = get_node("TemporaryGarbage")
			garbage_sprite.position = pos
			
			# Add rotation effect
			garbage_sprite.rotation = t * 10  # Rotate while throwing

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
		start_throw_animation(true)  # Pass power accuracy
	else:
		# Wrong power, either weak or strong throw
		if current_pos < green_zone_start:
			start_weak_throw_animation()
		else:
			start_strong_throw_animation()

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
	garbage_sprite.rotation = 0
	garbage_sprite.name = "TemporaryGarbage"
	add_child(garbage_sprite)
	
	var bins = $Bins.get_children()
	throw_target_pos = bins[selected_bin].position
	
	# Store the power accuracy for scoring
	garbage_sprite.set_meta("good_power", is_good_power)

func start_weak_throw_animation() -> void:
	throwing = true
	throw_progress = 0.0
	throw_start_pos = $PlaceholderAsset.position
	
	for child in $PlaceholderAsset.get_children():
		child.queue_free()
		
	var garbage_sprite = Sprite2D.new()
	garbage_sprite.texture = props[current_index]["texture"]
	garbage_sprite.position = throw_start_pos
	garbage_sprite.rotation = 0
	garbage_sprite.name = "TemporaryGarbage"
	add_child(garbage_sprite)
	
	throw_target_pos = Vector2(-100, throw_start_pos.y)
	garbage_sprite.set_meta("good_power", false)

func start_strong_throw_animation() -> void:
	throwing = true
	throw_progress = 0.0
	throw_start_pos = $PlaceholderAsset.position
	
	for child in $PlaceholderAsset.get_children():
		child.queue_free()
		
	var garbage_sprite = Sprite2D.new()
	garbage_sprite.texture = props[current_index]["texture"]
	garbage_sprite.position = throw_start_pos
	garbage_sprite.rotation = 0
	garbage_sprite.name = "TemporaryGarbage"
	add_child(garbage_sprite)
	
	throw_target_pos = Vector2(1500, throw_start_pos.y)
	garbage_sprite.set_meta("good_power", false)

func complete_throw() -> void:
	var prop_category = props[current_index]["category"]
	var garbage_sprite = get_node("TemporaryGarbage")
	var is_good_power = garbage_sprite.get_meta("good_power")
	
	if is_good_power:
		if selected_bin == prop_category:
			# Right bin, right power
			score += 10
		else:
			# Wrong bin, right power
			score -= 5
	else:
		# Wrong power, regardless of bin
		score += 0
	
	$ScoreLabel.text = "Score: " + str(score)
	
	current_index += 1
	if current_index < props.size():
		if has_node("TemporaryGarbage"):
			get_node("TemporaryGarbage").queue_free()
		
		populate_placeholder()
		populate_sorting_tray()
	else:
		game_active = false
		$GameOverLabel.text = "You Win!\nFinal Score: " + str(score)
		$GameOverLabel.show()

func update_arrow_position() -> void:
	var bins = $Bins.get_children()
	if selected_bin < bins.size():
		$Control/Arrow.global_position = bins[selected_bin].global_position + Vector2(0, 280)

func populate_placeholder() -> void:
	for child in $PlaceholderAsset.get_children():
		child.queue_free()
	if current_index < props.size():
		var sprite = Sprite2D.new()
		sprite.texture = props[current_index]["texture"]
		$PlaceholderAsset.add_child(sprite)

func populate_sorting_tray() -> void:
	for child in $SortingTrayAsset.get_children():
		child.queue_free()
	
	var spacing = 200
	var start_x = -195
	
	for i in range(current_index + 1, min(current_index + 4, props.size())):
		var sprite = Sprite2D.new()
		sprite.texture = props[i]["texture"]
		var relative_index = i - (current_index + 1)
		sprite.position = Vector2(start_x + (spacing * relative_index), 0)
		sprite.scale = Vector2(0.7, 0.7)
		$SortingTrayAsset.add_child(sprite)


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
	
	# Reset props and game elements
	props.shuffle()
	populate_placeholder()
	populate_sorting_tray()
	update_arrow_position()
	
	# Hide game over panel
	$GameOverControl.hide_game_over()
	
	# Reset power bar
	$PowerBarIndicator.position.x = power_bar_range.x
	indicator_moving = false
	can_throw = true
