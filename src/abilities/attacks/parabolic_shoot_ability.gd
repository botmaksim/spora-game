extends BaseAbility
class_name ParabolicShootAbility

@export var projectile_scene: PackedScene

func on_pressed(is_player: bool) -> void:
	print("[SYSTEM] Shot parabolic projectile!")
