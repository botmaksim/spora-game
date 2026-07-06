extends Node

var corpses = []

func register_corpse(corpse: Node) -> void:
	corpses.append(corpse)

func unregister_corpse(corpse: Node) -> void:
	corpses.erase(corpse)

func get_best_corpse(player_pos: Vector2, max_dist_x: float, max_dist_y: float) -> Node:
	var best_corpse = null
	var min_decay = 999.0
	
	for c in corpses:
		var dx = abs(c.global_position.x - player_pos.x)
		var dy = abs(c.global_position.y - player_pos.y)
		if dx <= max_dist_x and dy <= max_dist_y:
			var decay = 0.0
			var decay_mgr = c.get_node_or_null("DecayManager")
			if decay_mgr:
				decay = decay_mgr.current_decay
			
			if decay < min_decay:
				min_decay = decay
				best_corpse = c
	return best_corpse
