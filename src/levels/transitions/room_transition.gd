extends Area2D
class_name RoomTransition

@export_file("*.tscn") var target_scene_path: String
@export var spawn_point_id: String = "default"

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if target_scene_path == "":
		push_warning("[SYSTEM] RoomTransition: target_scene_path is empty!")
		return
		
	if body.has_node("PlayerController"):
		print("[SYSTEM] Transitioning to: ", target_scene_path)
		
		call_deferred("_load_scene")

func _load_scene() -> void:
	get_tree().change_scene_to_file(target_scene_path)
