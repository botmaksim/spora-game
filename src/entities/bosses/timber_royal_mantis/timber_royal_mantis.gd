extends BossTemplate
var phase = 1
func _physics_process(delta: float) -> void:
	if current_hp < max_hp * 0.5 and phase == 1:
		phase = 2
		print("[SYSTEM] Mantis entered Phase 2!")
	super._physics_process(delta)
