extends BossTemplate
var phase = 1
func _physics_process(delta: float) -> void:
	if current_hp < max_hp * 0.5 and phase == 1:
		phase = 2
		print("[SYSTEM] Gatekeeper detached from fence!")
	super._physics_process(delta)
