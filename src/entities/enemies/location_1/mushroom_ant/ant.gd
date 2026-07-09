extends EnemyTemplate
class_name ant

var is_dashing: bool = false

func _physics_process(delta: float) -> void:
	if current_state == BodyState.NORMAL:
		receive_movement(facing_dir, 0, false, false)
		if is_on_wall():
			facing_dir = -facing_dir
		if randf() < 0.01:
			trigger_ability("dash", 0, false)
			
	if abilities.has("dash"):
		var dash_ability = abilities["dash"]
		is_dashing = dash_ability.is_dashing if "is_dashing" in dash_ability else false
	
	super._physics_process(delta)
	update_ant_visuals()

func update_ant_visuals() -> void:
	if not sprite: return
	if not is_alive or current_state == BodyState.CORPSE:
		if tex_corpse: apply_texture(tex_corpse)
		return
		
	if is_dashing:
		if tex_attack: apply_texture(tex_attack)
	elif not is_on_floor():
		if tex_jump: apply_texture(tex_jump)
	elif abs(velocity.x) > 1.0:
		if tex_move: apply_texture(tex_move)
	else:
		if tex_idle: apply_texture(tex_idle)
