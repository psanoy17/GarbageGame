extends Node

var is_muted := false 

func _ready():
	load_volume_state()

func toggle_volume():
	is_muted = !is_muted
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), is_muted)
	save_volume_state()

func save_volume_state():
	var config = ConfigFile.new()  # Instantiate ConfigFile properly
	config.set_value("audio", "muted", is_muted)
	config.save("user://settings.cfg")

func load_volume_state():
	var config = ConfigFile.new()  # Instantiate ConfigFile properly
	if config.load("user://settings.cfg") == OK:
		is_muted = config.get_value("audio", "muted", false)  # Default to false
	else:
		is_muted = false  # Default if config file doesn't exist

	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), is_muted)
