extends SceneTree

var map
var player
var frame_count := 0

func _initialize() -> void:
	var packed_scene = load("res://map.tscn")
	map = packed_scene.instantiate()
	root.add_child(map)
	player = map.get_node("Player")
	player.set_physics_process(false)


func _process(_delta: float) -> bool:
	frame_count += 1
	var capture_dir = OS.get_environment("CODEX_CAPTURE_DIR")
	if frame_count == 3:
		player.global_position = Vector3(7.0, 0.0, 1.8)
		player.look_at(Vector3(10.0, 0.0, 10.0), Vector3.UP)
	elif frame_count == 8:
		RenderingServer.force_draw(false, 0.0)
		root.get_texture().get_image().save_png(capture_dir.path_join("pond_view.png"))
		player.global_position = Vector3(3.0, 0.0, -1.0)
		player.look_at(Vector3(-7.0, 1.0, -6.8), Vector3.UP)
	elif frame_count == 13:
		RenderingServer.force_draw(false, 0.0)
		root.get_texture().get_image().save_png(capture_dir.path_join("field_view.png"))
		player.equip_basket()
		player.global_position = Vector3(7.0, 0.0, 1.8)
		player.look_at(Vector3(10.0, 0.0, 10.0), Vector3.UP)
	elif frame_count == 18:
		RenderingServer.force_draw(false, 0.0)
		root.get_texture().get_image().save_png(capture_dir.path_join("basket_view.png"))
		quit()
	return false
