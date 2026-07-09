extends BaseAbility
class_name MeleeAttackAbility

@export var damage: int = 20

func _ready() -> void:
	ability_id = "melee"
	super._ready()

func on_pressed(is_player: bool) -> void:
	if "is_attacking" in body:
		body.is_attacking = true
		
	var hitbox = Area2D.new()
	var coll = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(40, 40)
	coll.shape = shape
	coll.position = Vector2(body.facing_dir * 40, 0)
	hitbox.add_child(coll)
	body.add_child(hitbox)
	
	hitbox.body_entered.connect(_on_hitbox_entered)
	
	await get_tree().create_timer(0.3).timeout
	hitbox.queue_free()
	
	if "is_attacking" in body:
		body.is_attacking = false

func _on_hitbox_entered(other: Node2D) -> void:
	if other != body and other.has_method("take_damage"):
		other.take_damage(damage * body.damage_multiplier)
