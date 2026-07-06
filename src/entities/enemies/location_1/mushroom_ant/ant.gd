extends EnemyTemplate

func _physics_process(delta: float) -> void:
	if current_state == BodyState.NORMAL:
		receive_movement(facing_dir, 0, false, false)
		if randf() < 0.01:
			trigger_ability("dash", 0, false)
	super._physics_process(delta)
