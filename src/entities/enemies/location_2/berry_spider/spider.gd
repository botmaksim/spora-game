extends EnemyTemplate

func _physics_process(delta: float) -> void:
	if current_state == BodyState.NORMAL:
		if randf() < 0.02:
			trigger_ability("shoot", 0, false)
	super._physics_process(delta)
