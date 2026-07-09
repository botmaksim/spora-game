extends Control

@onready var new_game_btn = $VBoxContainer/NewGameBtn
@onready var save_slots_btn = $VBoxContainer/SaveSlotsBtn
@onready var settings_btn = $VBoxContainer/SettingsBtn

var save_slots_scene = preload("res://MainMenu/SaveSlotsScreen.tscn")
var settings_scene = preload("res://MainMenu/SettingsScreen.tscn")

func _ready() -> void:
	new_game_btn.pressed.connect(_on_new_game_pressed)
	save_slots_btn.pressed.connect(_on_save_slots_pressed)
	settings_btn.pressed.connect(_on_settings_pressed)

func _on_new_game_pressed() -> void:
	var empty_slot = SaveManager.find_empty_slot()
	if empty_slot != -1:
		SaveManager.start_new_game(empty_slot)
	else:
		_open_save_slots(true)

func _on_save_slots_pressed() -> void:
	_open_save_slots(false)

func _open_save_slots(new_game_mode: bool) -> void:
	var slots = save_slots_scene.instantiate()
	slots.is_new_game_mode = new_game_mode
	add_child(slots)

func _on_settings_pressed() -> void:
	var settings = settings_scene.instantiate()
	add_child(settings)
