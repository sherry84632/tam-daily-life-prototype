extends Control


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		toggle_pause()
		get_viewport().set_input_as_handled()


func toggle_pause() -> void:
	if get_tree().paused:
		resume_game()
	else:
		pause_game()


func pause_game() -> void:
	show()
	get_tree().paused = true

	# Thả chuột để bấm menu
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func resume_game() -> void:
	hide()
	get_tree().paused = false

	# Khóa chuột lại cho gameplay
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _on_resume_button_pressed() -> void:
	resume_game()


func _on_quit_button_pressed() -> void:
	get_tree().quit()
