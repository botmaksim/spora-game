extends EnemyTemplate
class_name ant

var is_dashing: bool = false

func _physics_process(delta: float) -> void:
	if current_state == BodyState.NORMAL:
		receive_movement(facing_dir, 0, false, false)
		if randf() < 0.01:
			trigger_ability("dash", 0, false)
			
	#проверка активности рывка для отрисовки и тд 
	if abilities.has("dash"):
		is_dashing = abilities["dash"].get("is_active", false)
	
	super._physics_process(delta)
	update_ant_visuals()

func update_ant_visuals() -> void:
	if not sprite: return
	#ниже перечисленны все моменты когда надо менять текстуры
	# 1. Труп / Смерть
	if not is_alive or current_state == BodyState.CORPSE:
		if tex_corpse: apply_texture(tex_corpse)
		return
		
	# 2. Атака (Dash)
	if is_dashing:
		if tex_attack: apply_texture(tex_attack)
	# 3. Воздух / Прыжок
	elif not is_on_floor():
		if tex_jump: apply_texture(tex_jump)
	# 4. Движение
	elif abs(velocity.x) > 1.0:
		if tex_move: apply_texture(tex_move)
	# 5. Покой
	else:
		if tex_idle: apply_texture(tex_idle)
