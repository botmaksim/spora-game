extends BaseBody
class_name Spora

#для корректной отрисовки текстур
var is_possessing: bool = false

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	update_spora_visuals()

func update_spora_visuals() -> void:
	if not sprite: return
	
	#для правильного направления текстур и анимаий(как-нибудь потом)
	sprite.flip_h = (facing_dir > 0)
	#текстуры для действий ниже:
	
	# 1. Захват тела 
	if is_possessing:
		if tex_possession: apply_texture(tex_possession)
		#позже для сброса анимации захвата надо будет добавить гдето в логике захвата
		#is_possessing = false
		#иначе блеб будет останется выглядеть по дебыльному
		
	# 2. Атака (на свою кнопку атаки)
	elif is_attacking:
		if tex_attack: apply_texture(tex_attack)
		
	# 3. Воздуханство / Прыжок
	elif not is_on_floor():
		if tex_jump: apply_texture(tex_jump)
		
	# 4. Движение
	elif abs(velocity.x) > 1.0:
		if tex_move: apply_texture(tex_move)
		
	# 5. Стояк
	else:
		if tex_idle: apply_texture(tex_idle)
