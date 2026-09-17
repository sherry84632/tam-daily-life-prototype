extends Button

var tween: Tween

func _ready() -> void:
	await get_tree().process_frame
	pivot_offset = size / 2.0

	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	button_down.connect(_on_button_down)
	button_up.connect(_on_button_up)


func _on_mouse_entered() -> void:
	animate_scale(Vector2(1.08, 1.08))


func _on_mouse_exited() -> void:
	animate_scale(Vector2.ONE)


func _on_button_down() -> void:
	animate_scale(Vector2(0.94, 0.94))


func _on_button_up() -> void:
	animate_scale(Vector2(1.08, 1.08))


func animate_scale(target_scale: Vector2) -> void:
	if tween:
		tween.kill()

	tween = create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", target_scale, 0.12)
