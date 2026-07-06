extends EnemyTemplate

func _physics_process(delta: float) -> void:
	if current_state == BodyState.NORMAL:
		receive_movement(facing_dir * 1.5, 0, false, false)
	super._physics_process(delta)
