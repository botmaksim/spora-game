extends EnemyTemplate

var timer = 2.0
func _physics_process(delta: float) -> void:
	if current_state == BodyState.NORMAL:
		timer -= delta
		if timer <= 0:
			facing_dir *= -1
			timer = 2.0
		receive_movement(facing_dir, 0, false, false)
	super._physics_process(delta)
