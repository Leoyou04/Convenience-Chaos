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

var is_crouching = false
var is_prone = false

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	add_to_group("player")

func _input(event):
	if event is InputEventMouseMotion:
		camera_mount.rotate_y(-event.relative.x * mouse_sensitivity)
		camera.rotate_x(-event.relative.y * mouse_sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)

func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			HotBarManager.cycle_slot(1)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			HotBarManager.cycle_slot(-1)

func _physics_process(_delta):
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
	
	if Input.is_action_pressed("sprint"):
		current_speed = sprint_speed
	elif is_prone:
		current_speed = prone_speed
	elif is_crouching:
		current_speed = crouch_speed
	else:
		current_speed = speed
	
	if Input.is_action_just_pressed("crouch"):
		if is_prone:
			# From prone to crouch
			is_prone = false
			is_crouching = true
			collision_shape.scale.y = 0.5
			camera.position.y = 0.5
		elif is_crouching:
			# Stand up
			is_crouching = false
			collision_shape.scale.y = 1.0
			camera.position.y = 1.0
		else:
			# Crouch
			is_crouching = true
			collision_shape.scale.y = 0.5
			camera.position.y = 0.5
	
	if Input.is_action_just_pressed("prone"):
		if is_crouching:
			# From crouch to prone
			is_crouching = false
			is_prone = true
			collision_shape.scale.y = 0.25
			camera.position.y = 0.25
		elif is_prone:
			# Stand up
			is_prone = false
			collision_shape.scale.y = 1.0
			camera.position.y = 1.0
		else:
			# Prone
			is_prone = true
			collision_shape.scale.y = 0.25
			camera.position.y = 0.25
	
	move_and_slide()
