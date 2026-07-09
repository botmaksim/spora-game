extends Node

@export var max_decay: float = 100.0
@export var decay_rate: float = 2.0 # 50 seconds to fully decay
var current_decay: float = 0.0

var body: Node = null

func _ready() -> void:
	body = get_parent()

func _process(delta: float) -> void:
	if not is_instance_valid(body): return
	
	if "current_state" in body and body.current_state == body.BodyState.CORPSE:
		if current_decay < max_decay:
			current_decay += decay_rate * delta
			current_decay = min(current_decay, max_decay)
