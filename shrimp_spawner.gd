extends Node3D

@export var shrimp_scene: PackedScene
@export var amount: int = 100
@export var spawn_area: Vector3 = Vector3(8, 0, 8)

func _ready():
	if not shrimp_scene:
		return
		
	for i in range(amount):
		var shrimp = shrimp_scene.instantiate()
		add_child(shrimp)
		
		var x = randf_range(-spawn_area.x / 2, spawn_area.x / 2)
		var z = randf_range(-spawn_area.z / 2, spawn_area.z / 2)
		shrimp.position = Vector3(x, 1.0, z)
