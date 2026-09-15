extends CanvasLayer

signal dialogue_finished

@onready var name_label = $Control/Panel/NameLabel
@onready var text_label = $Control/Panel/TextLabel
@onready var control = $Control

var dialogue_queue = []
var player = null

var current_text = ""
var is_typing = false
var type_timer = 0.0
var char_delay = 0.03 # Tốc độ hiện chữ

func _ready():
	control.visible = false

func _process(delta):
	if is_typing:
		type_timer += delta
		if type_timer >= char_delay:
			type_timer = 0.0
			text_label.visible_characters += 1
			if text_label.visible_characters >= current_text.length():
				is_typing = false

func start_dialogue(dialogue_list, npc_name, p_player):
	player = p_player
	if player:
		player.is_in_dialogue = true
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
	dialogue_queue = dialogue_list.duplicate()
	name_label.text = npc_name
	
	control.visible = true
	show_next_line()

func show_next_line():
	if is_typing:
		# Nếu đang chạy chữ mà bấm tiếp thì hiện hết luôn
		text_label.visible_characters = -1
		is_typing = false
		return
		
	if dialogue_queue.is_empty():
		end_dialogue()
		return
		
	current_text = dialogue_queue.pop_front()
	text_label.text = current_text
	text_label.visible_characters = 0
	is_typing = true
	type_timer = 0.0

func end_dialogue():
	control.visible = false
	if player:
		player.is_in_dialogue = false
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	dialogue_finished.emit()

func _unhandled_input(event):
	if not control.visible:
		return
		
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_F or event.keycode == KEY_SPACE or event.keycode == KEY_ENTER:
			show_next_line()
			# Consume event
			get_viewport().set_input_as_handled()
	
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		show_next_line()
		get_viewport().set_input_as_handled()
