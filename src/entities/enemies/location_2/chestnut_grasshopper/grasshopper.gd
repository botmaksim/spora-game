extends EnemyTemplate
var jump_timer = 2.0
func _physics_process(delta: float) -> void:
	if current_state == BodyState.NORMAL:
		jump_timer -= delta
		if jump_timer <= 0:
			receive_movement(facing_dir, 0, true, false)
			jump_timer = 2.0
			await get_tree().create_timer(0.5).timeout
			trigger_ability("slam", 0, false)
	super._physics_process(delta)
