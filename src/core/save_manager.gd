extends Node

const SAVE_DIR = "user://saves"

var current_slot: int = 1

func _ready() -> void:
	if not DirAccess.dir_exists_absolute(SAVE_DIR):
		DirAccess.make_dir_absolute(SAVE_DIR)

func get_save_path(slot: int) -> String:
	return SAVE_DIR + "/save_slot_" + str(slot) + ".json"

func get_save_info(slot: int) -> Dictionary:
	var path = get_save_path(slot)
	if not FileAccess.file_exists(path):
		return {}
		
	var file = FileAccess.open(path, FileAccess.READ)
	if file:
		var content = file.get_as_text()
		file.close()
		var json = JSON.new()
		var error = json.parse(content)
		if error == OK:
			var data = json.get_data()
			if data is Dictionary:
				return data
	return {}

func find_empty_slot() -> int:
	for i in range(1, 4):
		if get_save_info(i).is_empty():
			return i
	return -1

func save_game(room_path: String, player_pos_x: float, player_pos_y: float) -> void:
	var path = get_save_path(current_slot)
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file:
		var corpses_data = []
		var pos_mgr = get_node_or_null("/root/PossessionManager")
		if pos_mgr:
			for c in pos_mgr.corpses:
				if not is_instance_valid(c): continue
				var decay = 0.0
				var decay_mgr = c.get_node_or_null("DecayManager")
				if decay_mgr:
					decay = decay_mgr.current_decay
				
				corpses_data.append({
					"scene_file_path": c.scene_file_path,
					"pos_x": c.global_position.x,
					"pos_y": c.global_position.y,
					"decay": decay
				})
				
		var data = {
			"current_room": room_path,
			"slime_position_x": player_pos_x,
			"slime_position_y": player_pos_y,
			"corpses": corpses_data
		}
		file.store_string(JSON.stringify(data, "\t"))
		file.close()

func load_game(slot: int) -> void:
	current_slot = slot
	var data = get_save_info(slot)
	if data.is_empty():
		return
		
	var room_path = data.get("current_room", "")
	if room_path != "":
		# We transition to the room
		get_tree().change_scene_to_file(room_path)
		
		# We need to set the player position after the scene loads
		await get_tree().process_frame
		
		# Wait a bit for nodes to enter the tree
		await get_tree().create_timer(0.1).timeout
		
		var root = get_tree().root
		var current_scene = root.get_child(root.get_child_count() - 1)
		
		var player_controller = _find_player_controller(current_scene)
		if player_controller and player_controller.get_parent():
			var player_body = player_controller.get_parent() as Node2D
			player_body.global_position = Vector2(data.get("slime_position_x", 0), data.get("slime_position_y", 0))
			
		# Load corpses
		if data.has("corpses"):
			for c_data in data["corpses"]:
				var scene_path = c_data.get("scene_file_path", "")
				if scene_path == "": continue
				
				var scene = load(scene_path) as PackedScene
				if scene:
					var inst = scene.instantiate()
					current_scene.add_child(inst)
					inst.global_position = Vector2(c_data.get("pos_x", 0), c_data.get("pos_y", 0))
					
					# Force to corpse state
					if inst.has_method("set_state"):
						inst.set_state(inst.BodyState.CORPSE)
						
					var decay_mgr = inst.get_node_or_null("DecayManager")
					if decay_mgr:
						decay_mgr.current_decay = c_data.get("decay", 0.0)

func _find_player_controller(node: Node) -> Node:
	if node.name == "PlayerController":
		return node
	for child in node.get_children():
		var result = _find_player_controller(child)
		if result:
			return result
	return null

func start_new_game(slot: int) -> void:
	current_slot = slot
	# Overwrite save with empty/default
	save_game("res://src/levels/TestLevel.tscn", 25, -25)
	load_game(slot)
