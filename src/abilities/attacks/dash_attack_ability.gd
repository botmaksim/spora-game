extends BaseAbility
class_name DashAttackAbility

@export var dash_speed: float = 800.0
@export var dash_duration: float = 0.2
var is_dashing = false
var dash_timer = 0.0

func on_pressed(is_player: bool) -> void:
	if not is_dashing and body:
		is_dashing = true
		dash_timer = dash_duration
		body.velocity.x = body.facing_dir * dash_speed
		body.velocity.y = 0

func physics_update(delta: float) -> void:
	if is_dashing:
		dash_timer -= delta
		body.velocity.y = 0
		if dash_timer <= 0:
			is_dashing = false
