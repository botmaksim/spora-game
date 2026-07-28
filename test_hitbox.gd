extends SceneTree

func _init():
    var ant = load("res://src/entities/enemies/location_1/mushroom_ant/Ant.tscn").instantiate()
    print("Initial hitbox size: ", ant.get_node("CollisionShape2D").shape.size)
    ant.update_ant_visuals()
    print("Hitbox size after visual update: ", ant.get_node("CollisionShape2D").shape.size)
    quit()
