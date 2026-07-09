extends Node

var target_body

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
		
	var attack_pressed = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	if attack_pressed and not get_meta("attack_pressed_last_frame", false):
		target_body.trigger_ability("melee", 0, true)
		target_body.trigger_ability("dash", 0, true)
	set_meta("attack_pressed_last_frame", attack_pressed)

var radial_menu: Node2D = null
var is_transitioning: bool = false

func _input(event: InputEvent) -> void:
	if not is_instance_valid(target_body) or target_body.current_state == target_body.BodyState.CORPSE:
		return
	if is_transitioning: return
		
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		if target_body is Spora:
			if event.pressed:
				open_radial_menu()
			else:
				close_radial_menu_and_possess()
		else:
			if event.pressed:
				eject_from_host()

func open_radial_menu() -> void:
	if is_instance_valid(radial_menu):
		radial_menu.queue_free()
		radial_menu = null
		
	var pos_mgr = get_node_or_null("/root/PossessionManager")
	if not pos_mgr: return
	
	var corpses = pos_mgr.get_corpses_in_radius(target_body.global_position, 800.0) 
	
	var script = load("res://src/ui/possession_radial_menu.gd")
	if not script: return
	
	radial_menu = script.new()
	target_body.add_child(radial_menu)
	radial_menu.setup(corpses)
	
	Engine.time_scale = 0.1

func close_radial_menu_and_possess() -> void:
	Engine.time_scale = 1.0
	
	if not is_instance_valid(radial_menu): return
	
	var selected_corpse = radial_menu.selected_corpse
	
	if not is_instance_valid(selected_corpse) and not radial_menu.corpses.is_empty():
		selected_corpse = radial_menu.corpses[0]
		
	radial_menu.queue_free()
	radial_menu = null
	
	if is_instance_valid(selected_corpse):
		perform_possession(selected_corpse)

func eject_from_host() -> void:
	if not is_instance_valid(target_body): return
	is_transitioning = true
	
	var host = target_body
	
	var spora_scene = load("res://src/entities/spora/Spora.tscn")
	var spora = spora_scene.instantiate()
	
	host.get_parent().add_child(spora)
	spora.global_position = host.global_position + Vector2(0, -40)
	
	host.remove_child(self)
	spora.add_child(self)
	
	host.set_state(host.BodyState.CORPSE)
	update_target_body()
	spora._check_and_create_camera()
	is_transitioning = false

func perform_possession(best: Node) -> void:
	is_transitioning = true
	if "is_possessing" in target_body:
		target_body.is_possessing = true
	
	await get_tree().create_timer(0.3).timeout
	
	if is_instance_valid(target_body) and is_instance_valid(best):
		var old_body = target_body
		if "is_possessing" in old_body:
			old_body.is_possessing = false
		
		
		
		if old_body is Spora:
			
			pass
		else:
			old_body.set_state(old_body.BodyState.CORPSE)
			
		var parent = old_body.get_parent()
		if parent:
			old_body.remove_child(self)
			best.add_child(self)
			best.set_state(best.BodyState.POSSESSED, old_body)
			update_target_body()
			
			if old_body is Spora:
				old_body.queue_free()
	
	is_transitioning = false
