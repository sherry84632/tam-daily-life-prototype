extends StaticBody3D

@export var npc_name: String = "Cám"
@export var dialogue_lines: Array[String] = [
	"Chị Tấm ơi, chị lặn lội cả ngày bắt được nhiều tép quá!",
	"Đầu chị lấm bùn rồi kìa, chị ngụp lặn gội đầu cho sạch đi kẻo mẹ mắng.",
	"Để giỏ tép lên bàn rồi đi tắm đi chị!"
]
@export_color_no_alpha var shirt_color: Color = Color("#2f7a6d")
@export_color_no_alpha var skirt_color: Color = Color("#2e3d4c")
@export_color_no_alpha var hair_color: Color = Color("#17110e")

var dialogue_ui = null
var current_player = null
var is_stealing = false

func _ready():
	_apply_visual_style()
	var root = get_tree().root
	var map = root.get_node_or_null("Map")
	if map and map.has_node("DialogueUI"):
		dialogue_ui = map.get_node("DialogueUI")
		if not dialogue_ui.dialogue_finished.is_connected(_on_dialogue_finished):
			dialogue_ui.dialogue_finished.connect(_on_dialogue_finished)

func _apply_visual_style():
	var visual = get_node_or_null("CharacterVisual")
	if visual == null:
		return
	_set_mesh_color(visual.get_node_or_null("Body"), shirt_color)
	_set_mesh_color(visual.get_node_or_null("ArmLeft"), shirt_color)
	_set_mesh_color(visual.get_node_or_null("ArmRight"), shirt_color)
	_set_mesh_color(visual.get_node_or_null("Skirt"), skirt_color)
	for hair_part in ["HairCap", "HairBack", "Bun"]:
		_set_mesh_color(visual.get_node_or_null(hair_part), hair_color)

func _set_mesh_color(mesh_instance, color_value: Color):
	if mesh_instance == null:
		return
	var material = StandardMaterial3D.new()
	material.albedo_color = color_value
	material.roughness = 0.95
	mesh_instance.material_override = material

func interact(player):
	if is_stealing:
		return
		
	if dialogue_ui == null:
		var root = get_tree().root
		var map = root.get_node_or_null("Map")
		if map and map.has_node("DialogueUI"):
			dialogue_ui = map.get_node("DialogueUI")
			if not dialogue_ui.dialogue_finished.is_connected(_on_dialogue_finished):
				dialogue_ui.dialogue_finished.connect(_on_dialogue_finished)
	
	if dialogue_ui:
		current_player = player
		if player.inventory.get("tep", 0) >= 100:
			dialogue_ui.start_dialogue(dialogue_lines, npc_name, player)
		else:
			dialogue_ui.start_dialogue(["Chị Tấm cố bắt cho đủ 100 con tép đi nhé!"], npc_name, player)

func _on_dialogue_finished():
	if is_stealing:
		return
	if current_player and current_player.inventory.get("tep", 0) >= 100:
		var root = get_tree().root
		var map = root.get_node_or_null("Map")
		if map and map.has_node("Table"):
			map.get_node("Table").can_place = true

func steal_basket(table):
	is_stealing = true
	var tween = create_tween()
	tween.tween_property(self, "global_position", table.global_position, 1.5)
	tween.tween_callback(_on_reached_table.bind(table))

func _on_reached_table(table):
	if table.has_node("BasketMesh"):
		table.get_node("BasketMesh").visible = false
		
	var root = get_tree().root
	var map = root.get_node_or_null("Map")
	if map and map.has_node("Stepmother"):
		var stepmother = map.get_node("Stepmother")
		var tween = create_tween()
		tween.tween_property(self, "global_position", stepmother.global_position, 2.0)
		tween.tween_callback(_finish_stealing)
	else:
		_finish_stealing()

func _finish_stealing():
		
	if dialogue_ui:
		dialogue_ui.start_dialogue(["Cám đã trút sạch giỏ tép của bạn và mang về cho mẹ!"], "Hệ thống", current_player)
	
	queue_free()
