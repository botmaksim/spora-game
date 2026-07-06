extends EnemyTemplate

func _physics_process(delta: float) -> void:
	if current_state == BodyState.NORMAL:
		receive_movement(facing_dir * 0.5, 0, false, false)
		if current_hp < max_hp / 2:
			trigger_ability("hide", 1, false)
	super._physics_process(delta)
