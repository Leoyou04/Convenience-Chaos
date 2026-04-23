extends CharacterBody3D

@onready var camera_mount = $CameraMount
@onready var camera = $CameraMount/Camera3D
@onready var collision_shape = $CollisionShape3D

var speed = 5.0
var sprint_speed = 10.0
var crouch_speed = 2.5
var prone_speed = 1.0
var current_speed = speed
var mouse_sensitivity = 0.002
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

const CROUCH_HEIGHT_MULTIPLIER := 0.5
const PRONE_HEIGHT_MULTIPLIER := 0.25
const SPRINT_MAX_SECONDS := 6.0
const SPRINT_RECHARGE_SECONDS := 10.0

var is_crouching = false
var is_prone = false

var base_collision_position_y: float
var base_collision_half_height: float = 0.0
var base_capsule_height: float = 0.0
var base_capsule_radius: float = 0.0
var base_camera_height: float
var sprint_stamina: float = SPRINT_MAX_SECONDS

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	add_to_group("player")
	collision_shape.scale = Vector3.ONE

	if collision_shape.shape is CapsuleShape3D:
		collision_shape.shape = collision_shape.shape.duplicate()
		var capsule := collision_shape.shape as CapsuleShape3D
		base_capsule_height = capsule.height
		base_capsule_radius = capsule.radius
		base_collision_half_height = (base_capsule_height / 2.0) + base_capsule_radius

	base_collision_position_y = collision_shape.position.y
	base_camera_height = camera_mount.position.y

	_apply_posture_height(1.0)

func _input(event):
	if event is InputEventMouseMotion:
		camera_mount.rotate_y(-event.relative.x * mouse_sensitivity)
		camera.rotate_x(-event.relative.y * mouse_sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, -PI / 2, PI / 2)

func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			HotBarManager.cycle_slot(1)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			HotBarManager.cycle_slot(-1)

func _physics_process(delta):
	if Input.is_action_just_pressed("slot_1"):
		HotBarManager.set_active_slot(0)
	if Input.is_action_just_pressed("slot_2"):
		HotBarManager.set_active_slot(1)
	if Input.is_action_just_pressed("slot_3"):
		HotBarManager.set_active_slot(2)
	if Input.is_action_just_pressed("drop_item"):
		HotBarManager.drop_active_item(self)

	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (camera_mount.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)

	if not is_on_floor():
		velocity.y -= gravity * delta
	elif velocity.y < 0.0:
		velocity.y = 0.0

	var is_standing := not is_crouching and not is_prone
	var wants_to_sprint := Input.is_action_pressed("sprint") and is_standing

	if wants_to_sprint and sprint_stamina > 0.0:
		sprint_stamina = maxf(0.0, sprint_stamina - delta)
		current_speed = sprint_speed
	else:
		sprint_stamina = minf(SPRINT_MAX_SECONDS, sprint_stamina + (SPRINT_MAX_SECONDS / SPRINT_RECHARGE_SECONDS) * delta)
		if is_prone:
			current_speed = prone_speed
		elif is_crouching:
			current_speed = crouch_speed
		else:
			current_speed = speed

	if Input.is_action_just_pressed("crouch"):
		if is_prone:
			is_prone = false
			is_crouching = true
			_apply_posture_height(CROUCH_HEIGHT_MULTIPLIER)
		elif is_crouching:
			is_crouching = false
			_apply_posture_height(1.0)
		else:
			is_crouching = true
			_apply_posture_height(CROUCH_HEIGHT_MULTIPLIER)

	if Input.is_action_just_pressed("prone"):
		if is_crouching:
			is_crouching = false
			is_prone = true
			_apply_posture_height(PRONE_HEIGHT_MULTIPLIER)
		elif is_prone:
			is_prone = false
			_apply_posture_height(1.0)
		else:
			is_prone = true
			_apply_posture_height(PRONE_HEIGHT_MULTIPLIER)

	move_and_slide()

func _apply_posture_height(multiplier: float) -> void:
	if collision_shape.shape is CapsuleShape3D:
		var capsule := collision_shape.shape as CapsuleShape3D

		capsule.height = base_capsule_height * multiplier
		# Re-lock radius every call so any scale drift can't accumulate
		capsule.radius = base_capsule_radius

		var new_half_height := (capsule.height / 2.0) + base_capsule_radius
		var height_delta := base_collision_half_height - new_half_height
		collision_shape.position.y = base_collision_position_y - height_delta

	# Move the mount, not the camera — the mount holds the actual elevation
	camera_mount.position.y = base_camera_height * multiplier
