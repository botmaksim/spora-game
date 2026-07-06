extends BaseAbility
class_name WallClimbAbility

func physics_update(delta: float) -> void:
	if body.is_on_wall() and body.input_dir.x != 0:
		body.velocity.y = min(body.velocity.y, 50.0)
