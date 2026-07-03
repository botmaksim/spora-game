extends BaseAbility
class_name EjectJumpAbility

func on_pressed(is_player: bool) -> void:
	if is_player and body.current_state == body.BodyState.POSSESSED:
		body.die()
		print("[SYSTEM] Ejected from shell!")
