extends CharacterBody3D

@export var speed_max := 5.0 # m/s
@export var jump_velocity := 4.5 # m/s^2
@export var rotation_speed := 2.094395 # rad/s

@export var zoom_boundaries := [3.0, 4.5] # m
@export var zoom_speed := 3.0 # m/s
@export var pitch_boundaries := [-0.872665, 0.872665] # rad
@export var camera_rotation_speed := [0.003, 0.003]


@onready var rotation_pivot: Node3D = $RotationPivot
@onready var spring_arm: SpringArm3D = $RotationPivot/SpringArm3D


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
	camera_rotation(event)

func camera_rotation(event: InputEvent):
	if event is InputEventMouseMotion:
		rotation_pivot.rotate_y(-event.relative.x * camera_rotation_speed[0])
		spring_arm.rotate_x(-event.relative.y * camera_rotation_speed[1])
		spring_arm.rotation.x = clampf(
			spring_arm.rotation.x, 
			pitch_boundaries[0], 
			pitch_boundaries[1]
		)

func _physics_process(delta: float) -> void:
	camera_zooming(delta)
	character_rotation(delta)
	character_movement(delta)
	check_end()

func camera_zooming(delta: float):
	var zoom_direction := 0
	if Input.is_action_just_pressed("zoom_in"):
		zoom_direction = 1
	elif Input.is_action_just_pressed("zoom_out"):
		zoom_direction = -1
	spring_arm.spring_length += zoom_direction * zoom_speed * delta
	spring_arm.spring_length = clampf(
		spring_arm.spring_length,
		zoom_boundaries[0],
		zoom_boundaries[1]
	)

func character_rotation(delta: float) -> void:
	pass

func character_movement(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	var input_dir := Input.get_vector(
		"move_left", 
		"move_right", 
		"move_forward",
		"move_backward"
	)
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * speed_max
		velocity.z = direction.z * speed_max
	else:
		velocity.x = move_toward(velocity.x, 0, speed_max)
		velocity.z = move_toward(velocity.z, 0, speed_max)

	move_and_slide()

func check_end() -> void:
	if Input.is_action_just_pressed("pause"):
		get_tree().quit()
