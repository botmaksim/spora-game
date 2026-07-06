extends BaseAbility
class_name HideTurtleAbility

func on_pressed(is_player: bool) -> void:
	body.is_invulnerable = true
	body.speed_multiplier = 0.0
	print("[SYSTEM] Hiding in shell...")

func on_released(is_player: bool) -> void:
	body.is_invulnerable = false
	body.speed_multiplier = 1.0
