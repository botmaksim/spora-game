extends Node

const SETTINGS_PATH = "user://settings.json"

var master_volume: float = 1.0
var music_volume: float = 1.0
var sfx_volume: float = 1.0

func _ready() -> void:
	load_settings()

func apply_volumes() -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(master_volume))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(music_volume))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(sfx_volume))

func set_master_volume(value: float) -> void:
	master_volume = clamp(value, 0.0, 1.0)
	apply_volumes()
	save_settings()

func set_music_volume(value: float) -> void:
	music_volume = clamp(value, 0.0, 1.0)
	apply_volumes()
	save_settings()

func set_sfx_volume(value: float) -> void:
	sfx_volume = clamp(value, 0.0, 1.0)
	apply_volumes()
	save_settings()

func play_sound(sound_name: String) -> void:
	pass

func save_settings() -> void:
	var file = FileAccess.open(SETTINGS_PATH, FileAccess.WRITE)
	if file:
		var data = {
			"master_volume": master_volume,
			"music_volume": music_volume,
			"sfx_volume": sfx_volume
		}
		file.store_string(JSON.stringify(data))
		file.close()

func load_settings() -> void:
	if not FileAccess.file_exists(SETTINGS_PATH):
		apply_volumes()
		return
		
	var file = FileAccess.open(SETTINGS_PATH, FileAccess.READ)
	if file:
		var content = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var error = json.parse(content)
		if error == OK:
			var data = json.get_data()
			if data is Dictionary:
				master_volume = data.get("master_volume", 1.0)
				music_volume = data.get("music_volume", 1.0)
				sfx_volume = data.get("sfx_volume", 1.0)
	apply_volumes()
