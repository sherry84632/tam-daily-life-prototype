extends Node3D

@export var custom_house_scene: PackedScene = null
@export var use_custom_model_if_present: bool = true

# Materials for stylized rural North Vietnamese homestead
var brick_mat: StandardMaterial3D
var porch_brick_mat: StandardMaterial3D
var yard_dirt_mat: StandardMaterial3D
var grass_mat: StandardMaterial3D
var wall_mat: StandardMaterial3D
var wood_mat: StandardMaterial3D
var dark_wood_mat: StandardMaterial3D
var roof_tile_mat: StandardMaterial3D
var roof_ridge_mat: StandardMaterial3D
var straw_mat: StandardMaterial3D
var ceramic_jar_mat: StandardMaterial3D
var leaf_mat: StandardMaterial3D
var banana_leaf_mat: StandardMaterial3D
var stone_mat: StandardMaterial3D
var water_mat: StandardMaterial3D

var procedural_house_node: Node3D = null

func _ready() -> void:
	_create_materials()
	_build_ground_and_yard()
	
	# Check if custom model is provided or present in project
	var custom_instantiated = false
	if custom_house_scene != null:
		var instance = custom_house_scene.instantiate()
		$ModelSlot.add_child(instance)
		custom_instantiated = true
	elif use_custom_model_if_present:
		var possible_paths = [
			"res://village_house.glb",
			"res://village_house.gltf",
			"res://village_life.glb"
		]
		for path in possible_paths:
			if ResourceLoader.exists(path):
				var loaded = load(path)
				if loaded is PackedScene:
					var inst = loaded.instantiate()
					$ModelSlot.add_child(inst)
					custom_instantiated = true
					break
	
	procedural_house_node = Node3D.new()
	procedural_house_node.name = "ProceduralHomestead"
	add_child(procedural_house_node)
	
	if not custom_instantiated:
		_build_traditional_three_bay_house()
	
	# Common rustic yard details (straw stack, water urns, banana trees, fences, gate)
	_build_haystack(Vector3(-7.5, 0.0, 3.5))
	_build_water_urns(Vector3(5.8, 0.0, -1.8))
	_build_banana_grove()
	_build_bamboo_fences()
	_build_village_gate(Vector3(0.0, 0.0, 10.5))


func _create_materials() -> void:
	brick_mat = _mat(Color("#ab4e33"), 0.95)         # Sân gạch đỏ
	porch_brick_mat = _mat(Color("#c26344"), 0.9)    # Gạch hiên nhà
	yard_dirt_mat = _mat(Color("#6b533d"), 1.0)      # Đất vườn
	grass_mat = _mat(Color("#4b7039"), 1.0)          # Cỏ xanh
	wall_mat = _mat(Color("#d8cbab"), 1.0)           # Vách đất trát rơm/vôi
	wood_mat = _mat(Color("#754b2d"), 0.9)           # Cột gỗ xoan/lim
	dark_wood_mat = _mat(Color("#422817"), 0.95)     # Xà gồ, cửa gỗ sẫm
	roof_tile_mat = _mat(Color("#a13825"), 0.9)      # Mái ngói ta vảy cá
	roof_ridge_mat = _mat(Color("#473229"), 0.95)    # Bờ nóc mái ngói
	straw_mat = _mat(Color("#bfa356"), 1.0)          # Rơm rạ vàng
	ceramic_jar_mat = _mat(Color("#4a2d1d"), 0.8)    # Chum/lu sành da lươn
	leaf_mat = _mat(Color("#366336"), 1.0)           # Lá cây chung
	banana_leaf_mat = _mat(Color("#487d2b"), 0.95)   # Lá chuối xanh tươi
	stone_mat = _mat(Color("#858579"), 1.0)          # Chân tảng đá kê cột
	
	water_mat = _mat(Color(0.2, 0.45, 0.4, 0.85), 0.2)
	water_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA


func _mat(color: Color, roughness: float) -> StandardMaterial3D:
	var m = StandardMaterial3D.new()
	m.albedo_color = color
	m.roughness = roughness
	return m


func _build_ground_and_yard() -> void:
	# Main terrain base
	_box(self, "MainTerrain", Vector3(0.0, -0.2, 0.0), Vector3(40.0, 0.4, 40.0), grass_mat, true)
	
	# Sân gạch rộng rãi trước nhà
	_box(self, "BrickYard", Vector3(0.0, 0.02, 3.2), Vector3(15.0, 0.06, 12.0), brick_mat, true)
	
	# Lối đất ra cổng
	_box(self, "GatewayPath", Vector3(0.0, 0.025, 9.8), Vector3(3.2, 0.06, 4.5), yard_dirt_mat, false)


func _build_traditional_three_bay_house() -> void:
	var house_center = Vector3(0.0, 0.0, -3.8)
	var house = procedural_house_node
	
	# Nền móng nhà nâng cao (3 bậc thềm)
	_box(house, "Foundation", house_center + Vector3(0.0, 0.25, 0.0), Vector3(13.6, 0.5, 6.8), porch_brick_mat, true)
	
	# Bậc thềm tam cấp dẫn lên hiên
	for step in 3:
		var step_y = 0.12 + step * 0.12
		var step_z = 3.4 + (2 - step) * 0.35
		_box(house, "Step%02d" % step, house_center + Vector3(0.0, step_y, step_z), Vector3(4.0, 0.12, 0.4), porch_brick_mat, true)
	
	# Thân nhà ba gian (tường gạch/vách trát)
	_box(house, "BackWall", house_center + Vector3(0.0, 1.8, -2.6), Vector3(12.8, 2.6, 0.3), wall_mat, true)
	_box(house, "LeftWall", house_center + Vector3(-6.25, 1.8, 0.0), Vector3(0.3, 2.6, 5.2), wall_mat, true)
	_box(house, "RightWall", house_center + Vector3(6.25, 1.8, 0.0), Vector3(0.3, 2.6, 5.2), wall_mat, true)
	
	# Vách ngăn gian giữa và 2 chái
	_box(house, "PartitionLeft", house_center + Vector3(-2.2, 1.8, -0.6), Vector3(0.2, 2.6, 3.8), wall_mat, true)
	_box(house, "PartitionRight", house_center + Vector3(2.2, 1.8, -0.6), Vector3(0.2, 2.6, 3.8), wall_mat, true)
	
	# Tường trước và cửa gỗ ba gian
	# Cửa chính gian giữa
	_box(house, "FrontWallLeftBay", house_center + Vector3(-4.2, 1.8, 1.3), Vector3(3.8, 2.6, 0.25), wall_mat, true)
	_box(house, "FrontWallRightBay", house_center + Vector3(4.2, 1.8, 1.3), Vector3(3.8, 2.6, 0.25), wall_mat, true)
	_box(house, "DoorFrameTop", house_center + Vector3(0.0, 2.7, 1.3), Vector3(4.4, 0.8, 0.25), wall_mat, true)
	
	# Cánh cửa gỗ mở hờ ở gian giữa
	_box(house, "DoorLeafLeft", house_center + Vector3(-0.95, 1.25, 1.55), Vector3(1.1, 2.2, 0.08), dark_wood_mat, true, Vector3(0.0, 25.0, 0.0))
	_box(house, "DoorLeafRight", house_center + Vector3(0.95, 1.25, 1.55), Vector3(1.1, 2.2, 0.08), dark_wood_mat, true, Vector3(0.0, -25.0, 0.0))
	
	# Cửa sổ chấn song gỗ ở 2 gian bên
	for x_side in [-4.2, 4.2]:
		_box(house, "WindowFrame%s" % x_side, house_center + Vector3(x_side, 1.5, 1.45), Vector3(1.5, 1.3, 0.12), dark_wood_mat, false)
		for bar in 4:
			var bar_x = x_side - 0.45 + bar * 0.3
			_cylinder(house, "WindowBar%s_%d" % [x_side, bar], house_center + Vector3(bar_x, 1.5, 1.45), 0.02, 0.02, 1.2, wood_mat)
	
	# Hàng cột hiên tròn bằng gỗ sẫm kê trên đá tảng
	var column_x_coords = [-5.6, -3.4, -1.2, 1.2, 3.4, 5.6]
	for col_idx in column_x_coords.size():
		var cx = column_x_coords[col_idx]
		# Chân tảng đá tròn
		_cylinder(house, "PillarBase%d" % col_idx, house_center + Vector3(cx, 0.58, 2.95), 0.24, 0.28, 0.16, stone_mat, false)
		# Thân cột gỗ tròn
		_cylinder(house, "Pillar%d" % col_idx, house_center + Vector3(cx, 1.85, 2.95), 0.14, 0.16, 2.4, wood_mat, true)
	
	# Xà hiên đỡ mái
	_box(house, "PorchBeam", house_center + Vector3(0.0, 3.05, 2.95), Vector3(12.6, 0.22, 0.24), dark_wood_mat, false)
	
	# Mái ngói cong dốc truyền thống Bắc Bộ
	# Mái trước
	_box(house, "RoofFront", house_center + Vector3(0.0, 3.8, 1.6), Vector3(14.8, 0.2, 4.5), roof_tile_mat, true, Vector3(26.0, 0.0, 0.0))
	# Mái sau
	_box(house, "RoofBack", house_center + Vector3(0.0, 3.8, -1.6), Vector3(14.8, 0.2, 4.5), roof_tile_mat, true, Vector3(-26.0, 0.0, 0.0))
	# Đỉnh nóc nhà (bờ nóc)
	_box(house, "RoofRidge", house_center + Vector3(0.0, 4.75, 0.0), Vector3(15.2, 0.28, 0.4), roof_ridge_mat, false)
	
	# Đao mái uốn cong 2 đầu hồi
	for x_end in [-7.5, 7.5]:
		_box(house, "GableLeft%s" % x_end, house_center + Vector3(x_end * 0.96, 4.75, 0.0), Vector3(0.6, 0.35, 0.35), roof_ridge_mat, false, Vector3(0.0, 0.0, x_end * 3.0))


func _build_haystack(pos: Vector3) -> void:
	# Cây rơm tròn làng quê truyền thống
	var root = procedural_house_node
	# Cột cọc rơm ở giữa
	_cylinder(root, "HaystackPole", pos + Vector3(0.0, 2.2, 0.0), 0.06, 0.06, 4.5, dark_wood_mat, true)
	# Khối rơm thân
	_cylinder(root, "HaystackBase", pos + Vector3(0.0, 0.9, 0.0), 1.6, 1.8, 1.8, straw_mat, true)
	# Khối rơm chóp nón
	_cylinder(root, "HaystackTop", pos + Vector3(0.0, 2.2, 0.0), 0.2, 1.6, 1.5, straw_mat, true)
	_sphere(root, "HaystackCap", pos + Vector3(0.0, 3.0, 0.0), 0.35, straw_mat)


func _build_water_urns(pos: Vector3) -> void:
	var root = procedural_house_node
	# Kệ kê chum sành
	_box(root, "UrnStand", pos + Vector3(0.0, 0.15, 0.0), Vector3(2.4, 0.3, 1.4), porch_brick_mat, true)
	
	# Chum nước 1 (lớn)
	var urn1_pos = pos + Vector3(-0.6, 0.3, 0.0)
	_sphere(root, "Urn1Body", urn1_pos + Vector3(0.0, 0.55, 0.0), 0.45, ceramic_jar_mat)
	_cylinder(root, "Urn1Rim", urn1_pos + Vector3(0.0, 0.95, 0.0), 0.3, 0.35, 0.15, ceramic_jar_mat, true)
	_cylinder(root, "Urn1Water", urn1_pos + Vector3(0.0, 0.9, 0.0), 0.29, 0.29, 0.04, water_mat)
	
	# Chum nước 2 (nhỏ hơn cạnh bên)
	var urn2_pos = pos + Vector3(0.6, 0.3, 0.0)
	_sphere(root, "Urn2Body", urn2_pos + Vector3(0.0, 0.45, 0.0), 0.38, ceramic_jar_mat)
	_cylinder(root, "Urn2Rim", urn2_pos + Vector3(0.0, 0.78, 0.0), 0.26, 0.3, 0.12, ceramic_jar_mat, true)


func _build_banana_grove() -> void:
	var root = procedural_house_node
	var banana_positions = [
		Vector3(-8.5, 0.0, -1.0),
		Vector3(-9.2, 0.0, -3.5),
		Vector3(-7.8, 0.0, -5.5),
		Vector3(8.5, 0.0, 0.5),
		Vector3(9.2, 0.0, -2.5),
		Vector3(8.0, 0.0, -4.8)
	]
	for idx in banana_positions.size():
		var bp = banana_positions[idx]
		# Thân cây chuối
		_cylinder(root, "BananaTrunk%d" % idx, bp + Vector3(0.0, 1.4, 0.0), 0.12, 0.2, 2.8, leaf_mat, true)
		# Tàu lá chuối xòe rộng
		for leaf_i in 6:
			var angle = leaf_i * (PI / 3.0) + idx * 0.4
			var l_offset = Vector3(cos(angle) * 1.3, 2.6 - sin(leaf_i) * 0.2, sin(angle) * 1.3)
			var leaf_rot = Vector3(cos(angle) * 25.0, rad_to_deg(angle), sin(angle) * 25.0)
			_box(root, "BananaLeaf%d_%d" % [idx, leaf_i], bp + l_offset, Vector3(0.45, 0.03, 1.6), banana_leaf_mat, false, leaf_rot)


func _build_bamboo_fences() -> void:
	var root = procedural_house_node
	# Hàng rào tre bao quanh sân
	var fence_y = 0.8
	
	# Rào bên trái sân
	for i in 12:
		var z = -2.0 + i * 1.0
		_cylinder(root, "FenceLeftPost%d" % i, Vector3(-8.2, fence_y, z), 0.04, 0.04, 1.6, wood_mat, true)
	_box(root, "FenceLeftRailTop", Vector3(-8.2, 1.2, 3.5), Vector3(0.06, 0.08, 11.5), dark_wood_mat, false)
	_box(root, "FenceLeftRailBottom", Vector3(-8.2, 0.5, 3.5), Vector3(0.06, 0.08, 11.5), dark_wood_mat, false)
	
	# Rào bên phải sân
	for i in 12:
		var z = -2.0 + i * 1.0
		_cylinder(root, "FenceRightPost%d" % i, Vector3(8.2, fence_y, z), 0.04, 0.04, 1.6, wood_mat, true)
	_box(root, "FenceRightRailTop", Vector3(8.2, 1.2, 3.5), Vector3(0.06, 0.08, 11.5), dark_wood_mat, false)
	_box(root, "FenceRightRailBottom", Vector3(8.2, 0.5, 3.5), Vector3(0.06, 0.08, 11.5), dark_wood_mat, false)
	
	# Rào phía trước sân (2 bên cổng)
	for i in 6:
		var x = -7.5 + i * 0.9
		_cylinder(root, "FenceFrontLeftPost%d" % i, Vector3(x, fence_y, 9.5), 0.04, 0.04, 1.6, wood_mat, true)
	_box(root, "FenceFrontLeftRail", Vector3(-5.2, 0.85, 9.5), Vector3(5.0, 0.08, 0.06), dark_wood_mat, false)
	
	for i in 6:
		var x = 2.8 + i * 0.9
		_cylinder(root, "FenceFrontRightPost%d" % i, Vector3(x, fence_y, 9.5), 0.04, 0.04, 1.6, wood_mat, true)
	_box(root, "FenceFrontRightRail", Vector3(5.2, 0.85, 9.5), Vector3(5.0, 0.08, 0.06), dark_wood_mat, false)


func _build_village_gate(pos: Vector3) -> void:
	var root = procedural_house_node
	# Cổng ngõ dẫn ra đồng
	for x_side in [-1.7, 1.7]:
		# Trụ cổng xây gạch
		_box(root, "GatePillar%s" % x_side, pos + Vector3(x_side, 1.6, 0.0), Vector3(0.65, 3.2, 0.65), porch_brick_mat, true)
		# Chóp trụ cổng
		_box(root, "GatePillarCap%s" % x_side, pos + Vector3(x_side, 3.3, 0.0), Vector3(0.8, 0.2, 0.8), roof_ridge_mat, false)
	
	# Xà ngang nối cổng
	_box(root, "GateTopBeam", pos + Vector3(0.0, 3.1, 0.0), Vector3(3.8, 0.2, 0.35), dark_wood_mat, false)
	# Mái che nhỏ trên cổng
	_box(root, "GateRoofLeft", pos + Vector3(0.0, 3.5, -0.3), Vector3(4.2, 0.12, 1.0), roof_tile_mat, false, Vector3(25.0, 0.0, 0.0))
	_box(root, "GateRoofRight", pos + Vector3(0.0, 3.5, 0.3), Vector3(4.2, 0.12, 1.0), roof_tile_mat, false, Vector3(-25.0, 0.0, 0.0))
	
	# Tấm biển gỗ chỉ dẫn: "Đường ra đồng"
	_box(root, "GateSignBoard", pos + Vector3(0.0, 2.7, 0.0), Vector3(1.8, 0.45, 0.06), wood_mat, false)


# Helpers for procedural meshes & static collisions
func _box(parent: Node, node_name: String, pos: Vector3, size: Vector3, mat: StandardMaterial3D, add_col: bool = false, rot_deg: Vector3 = Vector3.ZERO) -> MeshInstance3D:
	var mesh_inst = MeshInstance3D.new()
	mesh_inst.name = node_name
	var box_mesh = BoxMesh.new()
	box_mesh.size = size
	box_mesh.material = mat
	mesh_inst.mesh = box_mesh
	mesh_inst.position = pos
	if rot_deg != Vector3.ZERO:
		mesh_inst.rotation_degrees = rot_deg
	
	if add_col:
		var sb = StaticBody3D.new()
		sb.name = node_name + "Col"
		var cs = CollisionShape3D.new()
		var shape = BoxShape3D.new()
		shape.size = size
		cs.shape = shape
		sb.add_child(cs)
		mesh_inst.add_child(sb)
		
	parent.add_child(mesh_inst)
	return mesh_inst


func _cylinder(parent: Node, node_name: String, pos: Vector3, top_r: float, bot_r: float, h: float, mat: StandardMaterial3D, add_col: bool = false, rot_deg: Vector3 = Vector3.ZERO) -> MeshInstance3D:
	var mesh_inst = MeshInstance3D.new()
	mesh_inst.name = node_name
	var cyl = CylinderMesh.new()
	cyl.top_radius = top_r
	cyl.bottom_radius = bot_r
	cyl.height = h
	cyl.radial_segments = 12
	cyl.material = mat
	mesh_inst.mesh = cyl
	mesh_inst.position = pos
	if rot_deg != Vector3.ZERO:
		mesh_inst.rotation_degrees = rot_deg
		
	if add_col:
		var sb = StaticBody3D.new()
		sb.name = node_name + "Col"
		var cs = CollisionShape3D.new()
		var shape = CylinderShape3D.new()
		shape.radius = max(top_r, bot_r)
		shape.height = h
		cs.shape = shape
		sb.add_child(cs)
		mesh_inst.add_child(sb)
		
	parent.add_child(mesh_inst)
	return mesh_inst


func _sphere(parent: Node, node_name: String, pos: Vector3, r: float, mat: StandardMaterial3D) -> MeshInstance3D:
	var mesh_inst = MeshInstance3D.new()
	mesh_inst.name = node_name
	var sp = SphereMesh.new()
	sp.radius = r
	sp.height = r * 2.0
	sp.radial_segments = 12
	sp.rings = 6
	sp.material = mat
	mesh_inst.mesh = sp
	mesh_inst.position = pos
	parent.add_child(mesh_inst)
	return mesh_inst
