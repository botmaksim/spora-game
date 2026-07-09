extends Control

@onready var slot1_btn = $VBoxContainer/Slot1Btn
@onready var slot2_btn = $VBoxContainer/Slot2Btn
@onready var slot3_btn = $VBoxContainer/Slot3Btn
@onready var close_btn = $VBoxContainer/CloseBtn

var is_new_game_mode: bool = false

func _ready() -> void:
	_update_slot_labels()
	
	slot1_btn.pressed.connect(_on_slot_pressed.bind(1))
	slot2_btn.pressed.connect(_on_slot_pressed.bind(2))
	slot3_btn.pressed.connect(_on_slot_pressed.bind(3))
	close_btn.pressed.connect(queue_free)

func _update_slot_labels() -> void:
	var btns = [slot1_btn, slot2_btn, slot3_btn]
	for i in range(1, 4):
		var info = SaveManager.get_save_info(i)
		if info.is_empty():
			btns[i-1].text = "Slot %d: Empty" % i
		else:
			var room = info.get("current_room", "Unknown Room")
			# Try to make room path prettier
			var room_name = room.get_file().get_basename()
			btns[i-1].text = "Slot %d: %s" % [i, room_name]

func _on_slot_pressed(slot: int) -> void:
	var info = SaveManager.get_save_info(slot)
	
	if is_new_game_mode:
		# If it's new game mode, we overwrite/create new game regardless
		SaveManager.start_new_game(slot)
	else:
		if info.is_empty():
			# If opening normally and slot is empty, start a new game
			SaveManager.start_new_game(slot)
		else:
			# If opening normally and slot exists, load it
			SaveManager.load_game(slot)
