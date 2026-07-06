extends Node
class_name BaseAbility

@export var ability_id: String = "default"

var body: BaseBody

func _ready() -> void:
	var parent_body = get_parent().get_parent()
	if parent_body is BaseBody:
		body = parent_body
	else:
		printerr("Абилка ", name, " не нашла BaseBody!")

func on_pressed(is_player: bool) -> void: pass
func on_held(is_player: bool) -> void: pass
func on_released(is_player: bool) -> void: pass
func physics_update(delta: float) -> void: pass
