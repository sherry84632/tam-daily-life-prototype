extends Node3D

@export var next_scene_path: String = "res://map.tscn"

@onready var player = $Player
@onready var dialogue_ui = $DialogueUI
@onready var quest_label = $HUD/QuestPanel/MarginContainer/VBoxContainer/QuestText
@onready var fade_overlay = $HUD/FadeOverlay

var total_trash_piles: int = 3
var cleaned_trash_piles: int = 0
var is_quest_completed: bool = false
var is_transitioning: bool = false

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	fade_overlay.color = Color(0, 0, 0, 1.0)
	fade_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Connect to dialogue finished
	if dialogue_ui and not dialogue_ui.dialogue_finished.is_connected(_on_dialogue_finished):
		dialogue_ui.dialogue_finished.connect(_on_dialogue_finished)
		
	# Connect all trash piles
	var piles_container = get_node_or_null("TrashPiles")
	if piles_container:
		var piles = piles_container.get_children()
		total_trash_piles = piles.size()
		for pile in piles:
			if pile.has_signal("cleaned"):
				pile.cleaned.connect(_on_trash_pile_cleaned)
	
	_update_quest_ui()
	
	# Fade in from black
	var tween = create_tween()
	tween.tween_property(fade_overlay, "color:a", 0.0, 0.8).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	# Trigger intro dialogue after a brief moment
	await get_tree().create_timer(1.0).timeout
	_start_intro_dialogue()


func _start_intro_dialogue() -> void:
	if dialogue_ui and player:
		dialogue_ui.start_dialogue([
			"Tấm đâu rồi! Mau quét sạch 3 đống rác ngoài sân cho ta!",
			"Quét cho sạch sẽ tinh tươm rồi mới được mang giỏ ra đồng bắt tép nghe chưa!"
		], "Mẹ ghẻ", player)


func _on_trash_pile_cleaned(_pile) -> void:
	cleaned_trash_piles += 1
	_update_quest_ui()
	
	if cleaned_trash_piles >= total_trash_piles and not is_quest_completed:
		is_quest_completed = true
		_on_all_trash_cleaned()


func _update_quest_ui() -> void:
	if not quest_label:
		return
	if cleaned_trash_piles < total_trash_piles:
		quest_label.text = "Quét sạch các đống rác trong sân: %d/%d" % [cleaned_trash_piles, total_trash_piles]
	else:
		quest_label.text = "[Hoàn thành] Đã quét sạch sân nhà! Ra đồng bắt tép."


func _on_all_trash_cleaned() -> void:
	# Give short pause before mother dialogue
	await get_tree().create_timer(0.6).timeout
	if dialogue_ui and player:
		dialogue_ui.start_dialogue([
			"Ừ, quét dọn thế này coi như tạm được.",
			"Bây giờ mau xách giỏ ra đồng mò cua bắt tép đi!",
			"Hôm nay mà không bắt đầy giỏ thì đừng có trách ta!"
		], "Mẹ ghẻ", player)


func _on_dialogue_finished() -> void:
	if is_quest_completed and not is_transitioning:
		is_transitioning = true
		_transition_to_level_2()


func _transition_to_level_2() -> void:
	# Fade to black and switch scene to map.tscn
	fade_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	var tween = create_tween()
	tween.tween_property(fade_overlay, "color:a", 1.0, 1.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	tween.tween_callback(func():
		get_tree().change_scene_to_file(next_scene_path)
	)
