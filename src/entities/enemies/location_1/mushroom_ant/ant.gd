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
	
	var target_tex: Texture2D = null
	var base_offset := Vector2.ZERO
	
	if not is_alive or current_state == BodyState.CORPSE:
		target_tex = tex_corpse
		base_offset = Vector2(1, 1)
	elif is_dashing:
		target_tex = tex_attack
		base_offset = Vector2(18, 0)
	elif not is_on_floor():
		target_tex = tex_jump
		base_offset = Vector2(-4, -45)
	elif abs(velocity.x) > 1.0:
		target_tex = tex_move
		base_offset = Vector2(-4, -45)
	else:
		target_tex = tex_idle
		base_offset = Vector2(96.5, 0)
		
	if target_tex:
		apply_texture(target_tex)
		sprite.offset = Vector2(base_offset.x * facing_dir, base_offset.y)
