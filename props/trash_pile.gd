extends StaticBody3D

signal cleaned(pile)

@export var pile_name: String = "Đống rác"
var is_cleaned: bool = false

@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var visual_root: Node3D = $Visual
@onready var hint_label: Label3D = $Label3D

func _ready() -> void:
	collision_layer = 3 # Layers 1 and 2 (player raycast checks layer 2)
	collision_mask = 0
	if hint_label:
		hint_label.text = "[F] Quét rác"

func interact(player) -> void:
	if is_cleaned:
		return
	is_cleaned = true
	
	# Disable further collision
	if collision_shape:
		collision_shape.set_deferred("disabled", true)
	if hint_label:
		hint_label.visible = false
		
	# Notify listener (e.g. Level1 manager)
	cleaned.emit(self)
	
	# Animate sweep: bounce slightly and shrink down smoothly
	var tween = create_tween().set_parallel(true)
	tween.tween_property(visual_root, "scale", Vector3.ZERO, 0.45).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.tween_property(visual_root, "position:y", visual_root.position.y + 0.25, 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.chain().tween_callback(queue_free)
