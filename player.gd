extends CharacterBody3D

const SPEED = 7.0
const JUMP_VELOCITY = 6.0
const MOUSE_SENSITIVITY = 0.003

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var camera = $Camera3D
@onready var interact_raycast = $Camera3D/InteractRayCast

var is_in_dialogue = false
var inventory = {"tep": 0}
var inventory_ui = null
var has_basket = false

func equip_basket():
	has_basket = true
	if $Camera3D.has_node("EquippedBasket"):
		$Camera3D/EquippedBasket.visible = true

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	# Find inventory UI
	var root = get_tree().root
	var map = root.get_node_or_null("Map")
	if map and map.has_node("InventoryUI"):
		inventory_ui = map.get_node("InventoryUI")
		inventory_ui.update_tep_count(inventory["tep"])

func add_item(item_name: String, amount: int):
	if inventory.has(item_name):
		inventory[item_name] += amount
	else:
		inventory[item_name] = amount
		
	if item_name == "tep" and inventory_ui:
		inventory_ui.update_tep_count(inventory["tep"])

func _unhandled_input(event):
	if is_in_dialogue:
		return

	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		camera.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)
		
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F:
		interact_raycast.force_raycast_update()
		if interact_raycast.is_colliding():
			var collider = interact_raycast.get_collider()
			if collider.has_method("interact"):
				collider.interact(self)
	
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta):
	if is_in_dialogue:
		return

	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_physical_key_pressed(KEY_SPACE) and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction.
	var input_dir = Vector2.ZERO
	if Input.is_physical_key_pressed(KEY_W) or Input.is_physical_key_pressed(KEY_UP):
		input_dir.y -= 1
	if Input.is_physical_key_pressed(KEY_S) or Input.is_physical_key_pressed(KEY_DOWN):
		input_dir.y += 1
	if Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_LEFT):
		input_dir.x -= 1
	if Input.is_physical_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT):
		input_dir.x += 1
		
	input_dir = input_dir.normalized()
		
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y))
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
