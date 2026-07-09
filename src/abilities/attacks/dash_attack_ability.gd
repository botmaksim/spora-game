extends BaseAbility
class_name DashAttackAbility

@export var dash_speed: float = 800.0
@export var dash_duration: float = 0.2
@export var damage: int = 15

var is_dashing = false
var dash_timer = 0.0
var hitbox: Area2D = null

func _ready() -> void:
	ability_id = "dash"
	super._ready()

func on_pressed(is_player: bool) -> void:
	if not is_dashing and body:
		is_dashing = true
		dash_timer = dash_duration
		body.velocity.x = body.facing_dir * dash_speed
		body.velocity.y = 0
		
		if "is_attacking" in body:
			body.is_attacking = true
			
		hitbox = Area2D.new()
		var coll = CollisionShape2D.new()
		var shape = RectangleShape2D.new()
		shape.size = Vector2(80, 60)
		coll.shape = shape
		coll.position = Vector2(body.facing_dir * 40, 0)
		hitbox.add_child(coll)
		body.add_child(hitbox)
		hitbox.body_entered.connect(_on_hitbox_entered)

func physics_update(delta: float) -> void:
	if is_dashing:
		dash_timer -= delta
		body.velocity.y = 0
		if dash_timer <= 0:
			is_dashing = false
			if "is_attacking" in body:
				body.is_attacking = false
			if is_instance_valid(hitbox):
				hitbox.queue_free()

func _on_hitbox_entered(other: Node2D) -> void:
	if is_dashing and other != body and other.has_method("take_damage"):
		other.take_damage(damage * body.damage_multiplier)
