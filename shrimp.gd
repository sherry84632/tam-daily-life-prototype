extends CharacterBody3D

const SPEED = 2.0
var move_direction = Vector3.ZERO
var timer = 0.0
var change_dir_time = 2.0

func _ready():
	randomize_direction()

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= 9.8 * delta
		
	timer += delta
	if timer >= change_dir_time:
		randomize_direction()
		timer = 0.0
		change_dir_time = randf_range(1.0, 3.0)
		
	velocity.x = move_direction.x * SPEED
	velocity.z = move_direction.z * SPEED
	
	move_and_slide()
	
	if move_direction.length() > 0.1:
		var target_pos = global_position + Vector3(move_direction.x, 0, move_direction.z)
		if global_position.distance_to(target_pos) > 0.01:
			var current_transform = global_transform
			var target_transform = current_transform.looking_at(target_pos, Vector3.UP)
			# Xoay mượt mà với slerp
			global_transform.basis = current_transform.basis.slerp(target_transform.basis, 5.0 * delta)

func randomize_direction():
	var angle = randf() * PI * 2
	move_direction = Vector3(cos(angle), 0, sin(angle)).normalized()

func interact(player):
	if "has_basket" in player and player.has_basket:
		player.add_item("tep", 1)
		queue_free()
	else:
		var root = get_tree().root
		var map = root.get_node_or_null("Map")
		if map and map.has_node("DialogueUI"):
			map.get_node("DialogueUI").start_dialogue(["Mình cần tìm một cái rổ để đựng tép!"], "Hệ thống", player)
