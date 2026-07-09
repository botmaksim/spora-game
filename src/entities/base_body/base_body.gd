@tool
extends CharacterBody2D
class_name BaseBody

signal hp_changed(current_hp: int, max_hp: int)
signal took_damage(amount: int)
signal died(body: Node2D)

@export_group("Movement")
@export var max_speed: float = 300.0
@export var acceleration: float = 2000.0
@export var friction: float = 1500.0

@export_group("Jumping")
@export var jump_velocity: float = -450.0
@export var jump_cut_multiplier: float = 0.5 
@export var coyote_time: float = 0.15 
@export var jump_buffer_time: float = 0.1 

@export_group("Gravity")
@export var gravity_scale: float = 1.0 
@export var gravity_multiplier_fall: float = 1.5 
@export var max_fall_speed: float = 800.0 

@export_group("Stats")
@export var max_hp: int = 100

@export_group("Combat")
@export var invulnerability_time: float = 0.5 

#добавил шнягу для экспорта текстур
@export_group("Visuals & Textures")
@export var tex_idle: Texture2D
@export var tex_move: Texture2D
@export var tex_jump: Texture2D
@export var tex_attack: Texture2D
@export var tex_corpse: Texture2D
@export var tex_possession: Texture2D #тупо для споры

@export_group("Editor Tools")
@export var sync_shape_to_sprite: bool = false:
	set(value):
		if value: _sync_shape()
		sync_shape_to_sprite = false

var current_hp: int
var is_alive: bool = true
var is_invulnerable: bool = false

enum BodyState { NORMAL, CORPSE, POSSESSED }
var current_state: BodyState = BodyState.NORMAL
#ниже переменная для хранение теккстуры захваченного тела
var possessed_texture: Texture2D = null

#переменные для сохранения базовых текстур споры для возвращения при выходе их тела
var default_tex_idle: Texture2D
var default_tex_move: Texture2D
var default_tex_jump: Texture2D
var default_tex_attack: Texture2D
var default_tex_corpse: Texture2D
var default_tex_possession: Texture2D

var speed_multiplier: float = 1.0
var damage_multiplier: float = 1.0

var input_dir: Vector2 = Vector2.ZERO
var facing_dir: int = 1
var jump_cut: bool = false
var was_on_floor: bool = false

var abilities: Dictionary = {}

@onready var coyote_timer: Timer = $CoyoteTimer
@onready var jump_buffer_timer: Timer = $JumpBufferTimer
@onready var invuln_timer: Timer = Timer.new()
@onready var base_gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity") * gravity_scale
@onready var sprite: Sprite2D = get_node_or_null("Sprite2D")

func _ready() -> void:
	if Engine.is_editor_hint(): return
	
	#сохранение родных текстур споры при запуске
	default_tex_idle = tex_idle
	default_tex_move = tex_move
	default_tex_jump = tex_jump
	default_tex_attack = tex_attack
	default_tex_corpse = tex_corpse
	default_tex_possession = tex_possession
	
	current_hp = max_hp
	was_on_floor = is_on_floor()
	
	coyote_timer.wait_time = coyote_time
	coyote_timer.one_shot = true
	jump_buffer_timer.wait_time = jump_buffer_time
	jump_buffer_timer.one_shot = true
	
	add_child(invuln_timer)
	invuln_timer.one_shot = true
	invuln_timer.wait_time = invulnerability_time
	invuln_timer.timeout.connect(func(): is_invulnerable = false)
	
	var abilities_node = get_node_or_null("Abilities")
	if abilities_node:
		for child in abilities_node.get_children():
			if child is BaseAbility:
				abilities[child.ability_id] = child

	# Первичный запуск камеры при старте игры
	if has_node("PlayerController") or current_state == BodyState.POSSESSED:
		_check_and_create_camera()

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	
	apply_gravity(delta)
	handle_movement(delta)
	handle_jump()
	
	for ability in abilities.values():
		ability.physics_update(delta)
	
	was_on_floor = is_on_floor()
	move_and_slide()
	
	if was_on_floor and not is_on_floor() and velocity.y >= 0:
		coyote_timer.start()

func receive_movement(dir_x: float, dir_y: float, jump_pressed: bool, jump_released: bool) -> void:
	if not is_alive: return 
		
	input_dir = Vector2(dir_x, dir_y)
	
	if jump_pressed:
		jump_buffer_timer.start()
	if jump_released:
		jump_cut = true

func trigger_ability(ability_id: String, action_state: int, is_player: bool) -> void:
	if not is_alive: return
	
	if abilities.has(ability_id):
		var ability = abilities[ability_id]
		match action_state:
			0: ability.on_pressed(is_player)
			1: ability.on_held(is_player)
			2: ability.on_released(is_player)

func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		var current_gravity = base_gravity
		if velocity.y > 0: current_gravity *= gravity_multiplier_fall
		velocity.y += current_gravity * delta
		if velocity.y > max_fall_speed: velocity.y = max_fall_speed

func handle_movement(delta: float) -> void:
	if input_dir.x != 0:
		facing_dir = sign(input_dir.x)
		if sprite: sprite.flip_h = (facing_dir < 0)
		
		var target_speed = input_dir.x * (max_speed * speed_multiplier)
		velocity.x = move_toward(velocity.x, target_speed, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, friction * delta)

func handle_jump() -> void:
	if is_on_floor(): jump_cut = false
	
	var can_jump = is_on_floor() or not coyote_timer.is_stopped()
	var has_jump_input = not jump_buffer_timer.is_stopped()
	
	if can_jump and has_jump_input:
		velocity.y = jump_velocity
		coyote_timer.stop()
		jump_buffer_timer.stop()
		jump_cut = false 
		
	if jump_cut and velocity.y < 0:
		velocity.y *= jump_cut_multiplier
		jump_cut = false

func take_damage(amount: int) -> void:
	if not is_alive or is_invulnerable: return
	current_hp -= amount
	is_invulnerable = true
	invuln_timer.start()
	hp_changed.emit(current_hp, max_hp)
	took_damage.emit(amount)
	
	if current_hp <= 0: die()

func die() -> void:
	is_alive = false
	current_hp = 0
	hp_changed.emit(current_hp, max_hp)
	input_dir = Vector2.ZERO
	
	var ai_controller = get_node_or_null("AIController")
	if ai_controller: ai_controller.queue_free()
	
	set_state(BodyState.CORPSE)
	died.emit(self)

func set_state(new_state: BodyState, source_body: BaseBody = null) -> void:
	current_state = new_state
	
	# ЗАЩИТА: проверяем, что мы в игре, а не в редакторе Godot
	var in_game = not Engine.is_editor_hint() and is_inside_tree()
	
	match current_state:
		BodyState.NORMAL:
			is_alive = true
			possessed_texture = null #сбрасываем текстуру челика из которого вышли
			# Возвращаем родные текстуры Споры при выходе из тела
			tex_idle = default_tex_idle
			tex_move = default_tex_move
			tex_jump = default_tex_jump
			tex_attack = default_tex_attack
			tex_corpse = default_tex_corpse
			tex_possession = default_tex_possession
			if sprite and tex_idle:
				sprite.texture = tex_idle
			if sprite:
				sprite.modulate = Color(1, 1, 1, 1)
		BodyState.CORPSE:
			is_alive = false
			
			# Удаляем камеру у трупа
			if has_node("DynamicCamera"):
				get_node("DynamicCamera").queue_free()
				
			if in_game and get_node_or_null("/root/PossessionManager"):
				get_node("/root/PossessionManager").register_corpse(self)
		BodyState.POSSESSED:
			is_alive = true
			current_hp = max_hp
			hp_changed.emit(current_hp, max_hp)
			
			if in_game and get_node_or_null("/root/PossessionManager"):
				get_node("/root/PossessionManager").unregister_corpse(self)
			#копирование и вставка текстур жмурика после захвата тела на игрока
			if source_body:
				copy_textures_from(source_body)
				if sprite and source_body.sprite:
					sprite.texture = source_body.sprite.texture
					possessed_texture = source_body.sprite.texture # Сохраняем актуальную текстуру
				_sync_shape() #синхронизация коллизии под размер нового спрайта врага
			if sprite:
				sprite.modulate = Color(0.2, 1.0, 0.2, 1.0)
			
			# Включаем камеру при вселении
			_check_and_create_camera()

#функция смены текстуры для дочерних классов
func apply_texture(new_texture: Texture2D) -> void:
	if not sprite: return
	if sprite.texture != new_texture:
		sprite.texture = new_texture 

#функция для копирования всего набора текстур захваченного тела спорой
func copy_textures_from(source_body: BaseBody) -> void:
	if not source_body: return
	tex_idle = source_body.tex_idle
	tex_move = source_body.tex_move
	tex_jump = source_body.tex_jump
	tex_attack = source_body.tex_attack
	tex_corpse = source_body.tex_corpse
	tex_possession = source_body.tex_possession

func _sync_shape() -> void:
	if not Engine.is_editor_hint(): return
	var sp: Sprite2D = get_node_or_null("Sprite2D")
	var col: CollisionShape2D = get_node_or_null("CollisionShape2D")
	if sp and sp.texture and col and col.shape is RectangleShape2D:
		col.shape = col.shape.duplicate() 
		col.shape.size = sp.texture.get_size() * sp.scale

func _notification(what: int) -> void:
	if Engine.is_editor_hint(): return
	
	if what == NOTIFICATION_ENTER_TREE:
		if has_node("PlayerController") or current_state == BodyState.POSSESSED:
			_check_and_create_camera.call_deferred()

func _check_and_create_camera() -> void:
	if Engine.is_editor_hint(): return
	
	var camera = get_node_or_null("DynamicCamera") as Camera2D
	if not camera:
		camera = Camera2D.new()
		camera.name = "DynamicCamera"
		add_child(camera)
		
		camera.position_smoothing_enabled = true
		camera.position_smoothing_speed = 6.0
		
		camera.drag_horizontal_enabled = true
		camera.drag_vertical_enabled = true
		camera.drag_left_margin = 0.25
		camera.drag_right_margin = 0.25
		camera.drag_top_margin = 0.2
		camera.drag_bottom_margin = 0.2
	
	camera.make_current()

