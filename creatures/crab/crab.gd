class_name Crab
extends Creature

@export var speed_max := 5.0 # m/s
@export var jump_velocity := 6 # m/s^2
@export var rotation_speed := 2.094395 # rad/s
@export var max_side_acceleration_multiplier := 1.5

@export var zoom_boundaries := [3.0, 6.0] # m
@export var zoom_speed := 10.0 # m/s
@export var pitch_boundaries := [-0.872665, 0.872665] # rad
@export var camera_rotation_speed := [0.003, 0.003]


@onready var character_body: CSGCombiner3D = $CollisionShape3D/CSGCombiner3D
@onready var rotation_pivot: Node3D = $RotationPivot
@onready var spring_arm: SpringArm3D = $RotationPivot/SpringArm3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer


var double_jump := true


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
	super._physics_process(delta)
	camera_zooming(delta)
	var movement_velocity := character_movement()
	push_props(movement_velocity)
	handle_kick()
	handle_restart()
	handle_end()

func camera_zooming(delta: float):
	var zoom_direction := 0.0
	if Input.is_action_just_pressed("zoom_in"):
		zoom_direction = -1.0
	elif Input.is_action_just_pressed("zoom_out"):
		zoom_direction = 1.0
	spring_arm.spring_length += zoom_direction * zoom_speed * delta
	spring_arm.spring_length = clampf(
		spring_arm.spring_length,
		zoom_boundaries[0],
		zoom_boundaries[1]
	)

func character_movement() -> Vector3:
	if is_on_floor():
		double_jump = true

	if Input.is_action_just_pressed("jump"):
		if  is_on_floor():
			velocity += up_direction * jump_velocity
		elif double_jump:
			velocity += up_direction * jump_velocity
			double_jump = false

	var input_dir := Input.get_vector(
		"move_left",
		"move_right",
		"move_forward",
		"move_backward"
	)
	var pivot_basis := rotation_pivot.transform.basis
	var direction := pivot_basis * Vector3(input_dir.x, 0, input_dir.y)

	if not is_zero_approx(direction.length_squared()):
		direction -= up_direction * direction.dot(up_direction)
		direction = direction.normalized()

	if not is_zero_approx(direction.length_squared()):
		var side_acceleration_multiplier := 1.0
		var look_target := direction
		if Input.is_action_pressed("side_acceleration"):
			var camera_forward := -pivot_basis.z
			camera_forward -= up_direction * camera_forward.dot(up_direction)
			if not is_zero_approx(camera_forward.length_squared()):
				look_target = camera_forward.normalized()

			var camera_right := pivot_basis.x.normalized()
			var dot_sideways := absf(direction.dot(camera_right))
			side_acceleration_multiplier = lerpf(
				1.0, 
				max_side_acceleration_multiplier, 
				dot_sideways
			)
		character_body.look_at(
			character_body.global_position + look_target,
			up_direction
		)
		var normal_velocity := velocity.dot(up_direction)
		var tangent_velocity := (
			direction *
			speed_max *
			side_acceleration_multiplier
		)
		velocity = tangent_velocity + up_direction * normal_velocity

	else:
		var normal_velocity := velocity.dot(up_direction)
		velocity = up_direction * normal_velocity

	var movement_velocity := velocity
	move_and_slide()
	return movement_velocity

func handle_kick() -> void:
	if Input.is_action_just_pressed("kick"):
		animation_player.play("kick")

func handle_restart() -> void:
	if Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()

func handle_end() -> void:
	if Input.is_action_just_pressed("pause"):
		get_tree().quit()
