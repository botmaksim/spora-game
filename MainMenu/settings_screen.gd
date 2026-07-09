extends Control

@onready var master_slider = $VBoxContainer/MasterSlider
@onready var music_slider = $VBoxContainer/MusicSlider
@onready var sfx_slider = $VBoxContainer/SFXSlider
@onready var close_btn = $VBoxContainer/CloseBtn

func _ready() -> void:
	master_slider.value = SoundManager.master_volume
	music_slider.value = SoundManager.music_volume
	sfx_slider.value = SoundManager.sfx_volume
	
	master_slider.value_changed.connect(_on_master_changed)
	music_slider.value_changed.connect(_on_music_changed)
	sfx_slider.value_changed.connect(_on_sfx_changed)
	
	close_btn.pressed.connect(queue_free)

func _on_master_changed(value: float) -> void:
	SoundManager.set_master_volume(value)

func _on_music_changed(value: float) -> void:
	SoundManager.set_music_volume(value)

func _on_sfx_changed(value: float) -> void:
	SoundManager.set_sfx_volume(value)
