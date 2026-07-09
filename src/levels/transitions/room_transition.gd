extends Area2D
class_name RoomTransition

@export_file("*.tscn") var target_scene_path: String
@export var spawn_point_id: String = "default"

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if target_scene_path == "":
		push_warning("[SYSTEM]  файловой системе и открой саму сцену твоего персонажа (например, PlayerController.tscn или BaseBody.tscn, смотря где у тебя наRoomTransition: target_scene_path пустой!")
		return
		
	if body.has_node("PlayerController"):
		print("[SYSTEM] Игрок зашел в триггер. Переходим в: ", target_scene_path)
		# Блокируем триггер, чтобы не вызвать смену сцены дважды
		set_deferred("monitoring", false)
		call_deferred("_safe_transition", body)

func _safe_transition(player: Node2D) -> void:
	# 1. Загружаем новую сцену в память
	var next_scene_resource = load(target_scene_path) as PackedScene
	if not next_scene_resource:
		push_error("[SYSTEM] Не удалось загрузить сцену: " + target_scene_path)
		return
		
	# 2. Отсоединяем игрока от старого уровня (чтобы он не удалился)
	if player.get_parent():
		player.get_parent().remove_child(player)
		
	# 3. Создаем экземпляр нового уровня
	var next_scene_instance = next_scene_resource.instantiate()
	
	# 4. Закидываем игрока внутрь нового уровня
	next_scene_instance.add_child(player)
	
	# 5. Перемещаем игрока на маркер спавна
	var target_marker_name = "Spawn_" + spawn_point_id
	if next_scene_instance.has_node(target_marker_name):
		var marker = next_scene_instance.get_node(target_marker_name) as Marker2D
		player.global_position = marker.global_position
		print("[SYSTEM] Игрок успешно перемещен на маркер: ", target_marker_name)
	else:
		push_warning("[SYSTEM] Предупреждение: маркер " + target_marker_name + " не найден в новой сцене!")

	# 6. БЕЗОПАСНАЯ ПОДМЕНА СЦЕНЫ ЧЕРЕЗ ROOT (без использования current_scene)
	var root = get_tree().root
	
	# Находим старую сцену (она всегда первая в корне при тесте через F6)
	var current_scene = root.get_child(root.get_child_count() - 1)
	
	root.remove_child(current_scene)
	current_scene.queue_free()
	
	root.add_child(next_scene_instance)
