extends Node3D

# Decorative rural set dressing. These meshes deliberately have no collision,
# so the prototype's existing routes and interaction flow remain unchanged.

var grass_mat: StandardMaterial3D
var grass_light_mat: StandardMaterial3D
var earth_mat: StandardMaterial3D
var path_mat: StandardMaterial3D
var wood_mat: StandardMaterial3D
var dark_wood_mat: StandardMaterial3D
var plaster_mat: StandardMaterial3D
var roof_mat: StandardMaterial3D
var leaf_mat: StandardMaterial3D
var leaf_light_mat: StandardMaterial3D
var rice_mat: StandardMaterial3D
var stone_mat: StandardMaterial3D
var flower_mat: StandardMaterial3D
var water_detail_mat: StandardMaterial3D


func _ready() -> void:
	_create_materials()
	_build_ground_details()
	_build_field_shelter()
	_build_rice_fields()
	_build_pond_details()
	_build_fences()
	_build_trees()
	_build_distant_hills()


func _create_materials() -> void:
	grass_mat = _material(Color("#4f793e"), 1.0)
	grass_light_mat = _material(Color("#73954d"), 1.0)
	earth_mat = _material(Color("#65452f"), 1.0)
	path_mat = _material(Color("#a67b52"), 1.0)
	wood_mat = _material(Color("#825638"), 0.9)
	dark_wood_mat = _material(Color("#4c3228"), 0.95)
	plaster_mat = _material(Color("#ded2b0"), 1.0)
	roof_mat = _material(Color("#8d3f31"), 0.9)
	leaf_mat = _material(Color("#2f653b"), 1.0)
	leaf_light_mat = _material(Color("#568345"), 1.0)
	rice_mat = _material(Color("#b3a83c"), 1.0)
	stone_mat = _material(Color("#87877a"), 1.0)
	flower_mat = _material(Color("#e8b34f"), 0.85)
	water_detail_mat = _material(Color(0.38, 0.68, 0.58, 0.92), 0.35)
	water_detail_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA


func _build_ground_details() -> void:
	_box("Meadow", Vector3(-1.0, 0.115, -1.5), Vector3(25.0, 0.04, 18.0), grass_light_mat)
	_box("ShelterPath", Vector3(-3.4, 0.145, -2.0), Vector3(2.2, 0.06, 13.0), path_mat, Vector3(0.0, -12.0, 0.0))
	_box("PondPath", Vector3(6.5, 0.147, 4.1), Vector3(2.0, 0.06, 10.0), path_mat, Vector3(0.0, -42.0, 0.0))

	var stepping_stones := [
		Vector3(3.0, 0.11, -1.4), Vector3(3.4, 0.11, 0.2),
		Vector3(4.2, 0.11, 1.8), Vector3(5.3, 0.11, 3.2),
		Vector3(6.6, 0.11, 4.7)
	]
	for index in stepping_stones.size():
		_cylinder("PathStone%02d" % index, stepping_stones[index], 0.48, 0.55, 0.09, stone_mat)

	# Small flower clusters make the central yard readable without blocking it.
	var flowers := [
		Vector3(-1.8, 0.2, 2.2), Vector3(-2.4, 0.2, 2.7),
		Vector3(1.0, 0.2, 4.1), Vector3(1.6, 0.2, 4.5),
		Vector3(-0.8, 0.2, -8.2), Vector3(3.5, 0.2, -8.5)
	]
	for index in flowers.size():
		_cylinder("FlowerStem%02d" % index, flowers[index], 0.025, 0.025, 0.35, leaf_mat)
		_sphere("FlowerHead%02d" % index, flowers[index] + Vector3(0.0, 0.22, 0.0), 0.09, flower_mat)


func _build_field_shelter() -> void:
	var center := Vector3(-7.2, 0.0, -6.8)
	_box("ShelterFloor", center + Vector3(0.0, 0.18, 0.0), Vector3(5.4, 0.3, 4.2), wood_mat)
	for x_side in [-1.0, 1.0]:
		for z_side in [-1.0, 1.0]:
			_cylinder("ShelterPost%s_%s" % [x_side, z_side], center + Vector3(x_side * 2.15, 1.55, z_side * 1.55), 0.11, 0.16, 2.8, dark_wood_mat)
	# A small open thatched shelter keeps the scene rooted in the rice field.
	_box("ThatchRoofLeft", center + Vector3(-1.25, 3.18, 0.0), Vector3(3.2, 0.25, 4.9), rice_mat, Vector3(0.0, 0.0, 28.0))
	_box("ThatchRoofRight", center + Vector3(1.25, 3.18, 0.0), Vector3(3.2, 0.25, 4.9), rice_mat, Vector3(0.0, 0.0, -28.0))
	_cylinder("ShelterRoofRidge", center + Vector3(0.0, 3.88, 0.0), 0.11, 0.11, 5.0, dark_wood_mat, Vector3(90.0, 0.0, 0.0))
	_box("ShelterBenchSeat", center + Vector3(0.0, 0.72, -0.6), Vector3(3.2, 0.18, 0.62), wood_mat)
	for side in [-1.0, 1.0]:
		_box("ShelterBenchLeg%s" % side, center + Vector3(side * 1.15, 0.42, -0.6), Vector3(0.18, 0.62, 0.5), dark_wood_mat)


func _build_rice_fields() -> void:
	# A detailed paddy beside the shrimp pond.
	_box("RicePaddyNear", Vector3(-3.0, 0.08, 10.5), Vector3(10.5, 0.12, 9.0), earth_mat)
	for row in 5:
		var row_z := 7.3 + row * 1.55
		_box("RiceMudRow%02d" % row, Vector3(-3.0, 0.18, row_z), Vector3(9.7, 0.25, 0.85), path_mat)
		for plant in 10:
			var plant_x := -7.1 + plant * 0.92
			_cylinder("RiceStem%02d_%02d" % [row, plant], Vector3(plant_x, 0.52, row_z), 0.035, 0.055, 0.65, rice_mat)
			_sphere("RiceTop%02d_%02d" % [row, plant], Vector3(plant_x, 0.86, row_z), 0.085, rice_mat)

	# Broad striped paddies fill the background without adding collision.
	_distant_paddy("West", Vector3(-20.0, 0.08, 7.0), Vector3(12.0, 0.12, 20.0), false)
	_distant_paddy("South", Vector3(2.0, 0.08, 24.0), Vector3(30.0, 0.12, 9.0), true)
	_distant_paddy("East", Vector3(27.0, 0.08, 8.0), Vector3(13.0, 0.12, 21.0), false)
	_box("FieldSignPost", Vector3(-8.75, 0.75, 6.0), Vector3(0.12, 1.5, 0.12), dark_wood_mat)
	_box("FieldSign", Vector3(-8.75, 1.25, 6.0), Vector3(1.5, 0.62, 0.12), wood_mat, Vector3(0.0, -8.0, 0.0))


func _distant_paddy(prefix: String, center: Vector3, size_value: Vector3, rows_along_x: bool) -> void:
	_box("Paddy" + prefix, center, size_value, earth_mat)
	for row in 7:
		var offset := -0.42 + row * 0.14
		if rows_along_x:
			_box("Paddy%sRow%02d" % [prefix, row], center + Vector3(0.0, 0.16, offset * size_value.z), Vector3(size_value.x - 0.8, 0.22, 0.16), rice_mat)
		else:
			_box("Paddy%sRow%02d" % [prefix, row], center + Vector3(offset * size_value.x, 0.16, 0.0), Vector3(0.16, 0.22, size_value.z - 0.8), rice_mat)


func _build_pond_details() -> void:
	# Layer a grassy earthen bank over the original invisible collision walls.
	_box("PondBankNorthDirt", Vector3(10.0, 0.45, 4.5), Vector3(12.0, 0.82, 1.0), earth_mat)
	_box("PondBankSouthDirt", Vector3(10.0, 0.45, 15.5), Vector3(12.0, 0.82, 1.0), earth_mat)
	_box("PondBankWestDirt", Vector3(4.5, 0.45, 10.0), Vector3(1.0, 0.82, 10.0), earth_mat)
	_box("PondBankEastDirt", Vector3(15.5, 0.45, 10.0), Vector3(1.0, 0.82, 10.0), earth_mat)
	_box("PondBankNorthGrass", Vector3(10.0, 0.89, 4.5), Vector3(12.2, 0.12, 1.18), grass_light_mat)
	_box("PondBankSouthGrass", Vector3(10.0, 0.89, 15.5), Vector3(12.2, 0.12, 1.18), grass_light_mat)
	_box("PondBankWestGrass", Vector3(4.5, 0.89, 10.0), Vector3(1.18, 0.12, 10.0), grass_light_mat)
	_box("PondBankEastGrass", Vector3(15.5, 0.89, 10.0), Vector3(1.18, 0.12, 10.0), grass_light_mat)

	# Reeds and lily pads sit inside the pond and never affect shrimp movement.
	var reeds := [
		Vector3(5.3, 0.72, 5.3), Vector3(5.55, 0.8, 5.45),
		Vector3(14.55, 0.72, 6.1), Vector3(14.35, 0.8, 6.35),
		Vector3(5.4, 0.72, 14.4), Vector3(14.45, 0.72, 14.2)
	]
	for index in reeds.size():
		_cylinder("Reed%02d" % index, reeds[index], 0.025, 0.035, 0.95, leaf_light_mat)
		_cylinder("ReedHead%02d" % index, reeds[index] + Vector3(0.0, 0.55, 0.0), 0.055, 0.04, 0.22, earth_mat)

	var pads := [Vector3(7.0, 0.8, 8.0), Vector3(12.6, 0.8, 7.1), Vector3(8.3, 0.8, 12.9), Vector3(12.8, 0.8, 12.1)]
	for index in pads.size():
		_cylinder("LilyPad%02d" % index, pads[index], 0.38, 0.38, 0.035, leaf_light_mat)

	_box("PondPier", Vector3(10.0, 1.0, 5.7), Vector3(1.25, 0.16, 3.4), wood_mat)
	for plank in 7:
		_box("PierPlank%02d" % plank, Vector3(10.0, 1.1, 4.35 + plank * 0.45), Vector3(1.35, 0.1, 0.36), dark_wood_mat)
	for side in [-1.0, 1.0]:
		_cylinder("PierPost%s" % side, Vector3(10.0 + side * 0.52, 0.9, 6.95), 0.07, 0.09, 1.8, dark_wood_mat)


func _build_fences() -> void:
	# Fence outlines frame the yard but remain non-blocking decoration.
	for x_index in 9:
		var x := -12.0 + x_index * 3.0
		_fence_post(Vector3(x, 0.7, -11.5), "North%02d" % x_index)
	_box("FenceNorthRailA", Vector3(0.0, 0.65, -11.5), Vector3(24.0, 0.12, 0.12), wood_mat)
	_box("FenceNorthRailB", Vector3(0.0, 1.1, -11.5), Vector3(24.0, 0.12, 0.12), wood_mat)

	for z_index in 9:
		var z := -9.0 + z_index * 3.0
		_fence_post(Vector3(18.0, 0.7, z), "East%02d" % z_index)
	_box("FenceEastRailA", Vector3(18.0, 0.65, 3.0), Vector3(0.12, 0.12, 24.0), wood_mat)
	_box("FenceEastRailB", Vector3(18.0, 1.1, 3.0), Vector3(0.12, 0.12, 24.0), wood_mat)


func _build_trees() -> void:
	_tree("Tree01", Vector3(-15.0, 0.0, -6.0), 1.2)
	_tree("Tree02", Vector3(-14.0, 0.0, 4.0), 0.95)
	_tree("Tree03", Vector3(12.0, 0.0, -6.0), 0.92)
	_tree("Tree04", Vector3(17.0, 0.0, -7.0), 1.1)
	_tree("Tree05", Vector3(21.0, 0.0, 9.0), 1.25)
	_tree("Tree06", Vector3(-12.0, 0.0, 16.0), 1.15)
	_tree("Tree07", Vector3(2.0, 0.0, 18.0), 0.9)


func _build_distant_hills() -> void:
	_cone("Hill01", Vector3(-34.0, 3.2, -38.0), 13.0, 6.5, grass_mat)
	_cone("Hill02", Vector3(-12.0, 4.2, -43.0), 16.0, 8.5, grass_light_mat)
	_cone("Hill03", Vector3(15.0, 3.0, -42.0), 12.0, 6.0, grass_mat)
	_cone("Hill04", Vector3(37.0, 4.0, -36.0), 15.0, 8.0, grass_light_mat)


func _tree(node_name: String, base_position: Vector3, scale_factor: float) -> void:
	_cylinder(node_name + "Trunk", base_position + Vector3(0.0, 1.7 * scale_factor, 0.0), 0.26 * scale_factor, 0.38 * scale_factor, 3.4 * scale_factor, wood_mat)
	_sphere(node_name + "CrownA", base_position + Vector3(0.0, 3.8 * scale_factor, 0.0), 1.35 * scale_factor, leaf_mat)
	_sphere(node_name + "CrownB", base_position + Vector3(-0.8, 3.45, 0.2) * scale_factor, 0.92 * scale_factor, leaf_light_mat)
	_sphere(node_name + "CrownC", base_position + Vector3(0.75, 3.55, -0.15) * scale_factor, 1.0 * scale_factor, leaf_light_mat)


func _fence_post(position_value: Vector3, suffix: String) -> void:
	_cylinder("FencePost" + suffix, position_value, 0.1, 0.14, 1.4, dark_wood_mat)


func _material(color_value: Color, roughness_value: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color_value
	material.roughness = roughness_value
	return material


func _box(node_name: String, position_value: Vector3, size_value: Vector3, material: Material, rotation_value: Vector3 = Vector3.ZERO) -> MeshInstance3D:
	var mesh := BoxMesh.new()
	mesh.size = size_value
	mesh.material = material
	var instance := MeshInstance3D.new()
	instance.name = node_name
	instance.mesh = mesh
	instance.position = position_value
	instance.rotation_degrees = rotation_value
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	add_child(instance)
	return instance


func _cylinder(node_name: String, position_value: Vector3, top_radius: float, bottom_radius: float, height_value: float, material: Material, rotation_value: Vector3 = Vector3.ZERO) -> MeshInstance3D:
	var mesh := CylinderMesh.new()
	mesh.top_radius = top_radius
	mesh.bottom_radius = bottom_radius
	mesh.height = height_value
	mesh.radial_segments = 10
	mesh.rings = 1
	mesh.material = material
	var instance := MeshInstance3D.new()
	instance.name = node_name
	instance.mesh = mesh
	instance.position = position_value
	instance.rotation_degrees = rotation_value
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	add_child(instance)
	return instance


func _sphere(node_name: String, position_value: Vector3, radius_value: float, material: Material) -> MeshInstance3D:
	var mesh := SphereMesh.new()
	mesh.radius = radius_value
	mesh.height = radius_value * 2.0
	mesh.radial_segments = 12
	mesh.rings = 6
	mesh.material = material
	var instance := MeshInstance3D.new()
	instance.name = node_name
	instance.mesh = mesh
	instance.position = position_value
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	add_child(instance)
	return instance


func _cone(node_name: String, position_value: Vector3, radius_value: float, height_value: float, material: Material) -> MeshInstance3D:
	return _cylinder(node_name, position_value, 0.0, radius_value, height_value, material)
