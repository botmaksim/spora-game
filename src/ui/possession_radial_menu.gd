extends Node2D
class_name PossessionRadialMenu

var corpses: Array = []
var selected_corpse: Node = null

var inner_radius: float = 30.0
var outer_radius: float = 130.0
var hover_color = Color(0.8, 1.0, 0.8, 0.6)
var default_color = Color(0.1, 0.1, 0.1, 0.7)
var line_color = Color(1.0, 1.0, 1.0, 0.8)

var current_hover_index: int = -1

func setup(_corpses: Array) -> void:
	corpses = _corpses
	z_index = 100
	queue_redraw()

func _process(_delta: float) -> void:
	if corpses.is_empty(): return
	
	var mouse_pos = get_local_mouse_position()
	var dist = mouse_pos.length()
	var angle = mouse_pos.angle()
	if angle < 0:
		angle += PI * 2
		
	if dist >= inner_radius:
		var segment_angle = (PI * 2) / max(1, corpses.size())
		var idx = int(angle / segment_angle)
		if idx != current_hover_index:
			current_hover_index = idx
			selected_corpse = corpses[idx] if idx < corpses.size() else null
			queue_redraw()
	else:
		if current_hover_index != -1:
			current_hover_index = -1
			selected_corpse = null
			queue_redraw()

func _draw() -> void:
	# Обводка рисуется всегда, чтобы игрок видел, что меню работает
	draw_arc(Vector2.ZERO, inner_radius, 0, PI*2, 32, line_color, 2.0)
	draw_arc(Vector2.ZERO, outer_radius, 0, PI*2, 64, line_color, 2.0)

	if corpses.is_empty(): return
	
	var num_segments = corpses.size()
	var segment_angle = (PI * 2) / num_segments
	
	for i in range(num_segments):
		var start_angle = i * segment_angle
		var end_angle = (i + 1) * segment_angle
		
		var points = PackedVector2Array()
		var color = hover_color if i == current_hover_index else default_color
		
		var num_points_arc = 16
		for j in range(num_points_arc + 1):
			var a = start_angle + j * (segment_angle / num_points_arc)
			points.append(Vector2(cos(a), sin(a)) * inner_radius)
			
		for j in range(num_points_arc, -1, -1):
			var a = start_angle + j * (segment_angle / num_points_arc)
			points.append(Vector2(cos(a), sin(a)) * outer_radius)
			
		draw_polygon(points, PackedColorArray([color]))
		
		# Разделительные линии
		draw_line(Vector2(cos(start_angle), sin(start_angle)) * inner_radius, 
				  Vector2(cos(start_angle), sin(start_angle)) * outer_radius, 
				  line_color, 2.0)
				  
		# Иконки
		var mid_angle = start_angle + segment_angle / 2.0
		var icon_dist = (inner_radius + outer_radius) / 2.0
		var icon_pos = Vector2(cos(mid_angle), sin(mid_angle)) * icon_dist
		
		var corpse = corpses[i]
		if is_instance_valid(corpse):
			var sprite = corpse.get_node_or_null("Sprite2D")
			if sprite and sprite.texture:
				var tex = sprite.texture
				var sz = tex.get_size()
				
				# Пытаемся взять область текстуры (регион) если есть
				if sprite.region_enabled:
					sz = sprite.region_rect.size
					
				var icon_size = Vector2(48, 48)
				draw_texture_rect(tex, Rect2(icon_pos - icon_size / 2.0, icon_size), false, Color.WHITE)
