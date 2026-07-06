extends BaseAbility
class_name GroundSlamAbility

func on_pressed(is_player: bool) -> void:
	if not body.is_on_floor():
		body.velocity.y = 1000.0
