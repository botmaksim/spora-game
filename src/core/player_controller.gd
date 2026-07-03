extends Node

var target_body: CharacterBody2D

func _ready() -> void:
	update_target_body()

func update_target_body() -> void:
	var parent = get_parent()
	if parent is CharacterBody2D:
		target_body = parent
	else:
		target_body = null

func _physics_process(_delta: float) -> void:
	if not is_instance_valid(target_body) or target_body.current_state == target_body.BodyState.CORPSE:
		return
		
	var move_dir := Input.get_axis("ui_left", "ui_right")
	var jump_just_pressed := Input.is_action_just_pressed("ui_accept")
	var jump_released := Input.is_action_just_released("ui_accept")
	
	if target_body.has_method("receive_movement"):
		target_body.receive_movement(move_dir, 0, jump_just_pressed, jump_released)
		
	if Input.is_action_just_pressed("ui_focus_next"):
		attempt_possession()

func attempt_possession() -> void:
	var pos_mgr = get_node_or_null("/root/PossessionManager")
	if pos_mgr:
		var best = pos_mgr.get_best_corpse(target_body.global_position, 200.0, 100.0)
		if best:
			target_body.set_state(target_body.BodyState.CORPSE)
			get_parent().remove_child(self)
			best.add_child(self)
			best.set_state(best.BodyState.POSSESSED)
			update_target_body()
