extends BaseBody
class_name Spora

var is_possessing: bool = false

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	update_spora_visuals()

func update_spora_visuals() -> void:
	if not sprite: return
	
	sprite.flip_h = (facing_dir > 0)
	
	if is_possessing:
		if tex_possession: apply_texture(tex_possession)
		

	elif is_attacking:
		if tex_attack: apply_texture(tex_attack)
		
	elif not is_on_floor():
		if tex_jump: apply_texture(tex_jump)
		
	elif abs(velocity.x) > 1.0:
		if tex_move: apply_texture(tex_move)
		
	else:
		if tex_idle: apply_texture(tex_idle)
