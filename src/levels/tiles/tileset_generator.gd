@tool
extends Node
class_name TilesetGenerator

@export var generate_tileset: bool = false:
	set(value):
		if value:
			_generate()
			generate_tileset = false

func _generate() -> void:
	print("[SYSTEM] Generating Placeholder Texture and TileSet...")
	
	var img = Image.create(256, 64, false, Image.FORMAT_RGBA8)
	
	img.fill_rect(Rect2i(0, 0, 64, 64), Color(0.6, 0.3, 0.2))
	img.fill_rect(Rect2i(64, 0, 64, 64), Color(0.4, 0.3, 0.4))
	img.fill_rect(Rect2i(128, 0, 64, 64), Color(0.2, 0.5, 0.2))
	img.fill_rect(Rect2i(192, 0, 64, 64), Color(0.2, 0.4, 0.8))
	
	img.save_png("res://src/levels/tiles/placeholder_tiles.png")
	
	var ts = TileSet.new()
	ts.tile_size = Vector2i(64, 64)
	
	ts.add_terrain_set()
	ts.set_terrain_set_mode(0, TileSet.TERRAIN_MODE_MATCH_CORNERS_AND_SIDES)
	
	ts.add_terrain(0)
	ts.set_terrain_name(0, 0, "Location 1 (Fungus)")
	ts.set_terrain_color(0, 0, Color(0.6, 0.3, 0.2))
	
	ts.add_terrain(0)
	ts.set_terrain_name(0, 1, "Location 2 (Caves)")
	ts.set_terrain_color(0, 1, Color(0.4, 0.3, 0.4))
	
	ts.add_terrain(0)
	ts.set_terrain_name(0, 2, "Location 3 (Moss)")
	ts.set_terrain_color(0, 2, Color(0.2, 0.5, 0.2))
	
	ts.add_terrain(0)
	ts.set_terrain_name(0, 3, "Water")
	ts.set_terrain_color(0, 3, Color(0.2, 0.4, 0.8))
	
	var err = ResourceSaver.save(ts, "res://src/levels/tiles/world_tileset.tres")
	if err == OK:
		print("[SYSTEM] TileSet and placeholder successfully generated at res://src/levels/tiles/")
		print("[SYSTEM] To set up peering bits (for borders/coasts):")
		print("[SYSTEM] 1. Double click world_tileset.tres to open it in the bottom panel.")
		print("[SYSTEM] 2. Drag placeholder_tiles.png into the TileSet window to create an Atlas.")
		print("[SYSTEM] 3. In the Atlas Setup, click the 'Paint' section, select 'Terrains'.")
		print("[SYSTEM] 4. Paint the center and peering bits of your tiles so Godot knows how they connect.")
	else:
		printerr("Failed to save TileSet.")
