class_name Creature
extends CharacterBody3D


enum GravityType { FROM_POINT, TO_POINT, FLAT }


@export var gravity_type := GravityType.FROM_POINT
@export var gravity_point := Vector3.ZERO # global
@export var gravity_scale := 1.0
@export var mass := 1.0


@onready var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")


func get_point_gravity_vector() -> Vector3:
	if gravity_type == GravityType.FROM_POINT:
		return (global_position - gravity_point).normalized()
	if gravity_type == GravityType.TO_POINT:
		return (gravity_point - global_position).normalized()
	return Vector3.DOWN

func get_point_gravity() -> Vector3:
	return get_point_gravity_vector() * gravity * gravity_scale

func _physics_process(delta: float) -> void:
	up_direction = -get_point_gravity_vector()
	if not is_on_floor():
		velocity += get_point_gravity() * delta

func push_props(push_velocity: Vector3) -> void:
	var tangent_velocity := push_velocity
	tangent_velocity -= up_direction * tangent_velocity.dot(up_direction)
	if tangent_velocity.is_zero_approx():
		return
	for i in get_slide_collision_count():
		var collision := get_slide_collision(i)
		var props := collision.get_collider()
		if not props is Props:
			continue
		var props_rigidbody := props as Props
		var push_direction := -collision.get_normal()
		push_direction -= up_direction * push_direction.dot(up_direction)
		if push_direction.is_zero_approx():
			continue
		push_direction = push_direction.normalized()
		var push_speed := tangent_velocity.dot(push_direction)
		if push_speed <= 0.0:
			continue
		var mass_ratio := mass / props_rigidbody.mass
		var force_multiplier := mass_ratio / (mass_ratio + 1.0)
		var target_speed := push_speed * force_multiplier
		var current_speed := props_rigidbody.linear_velocity.dot(push_direction)
		var speed_difference := target_speed - current_speed
		if speed_difference <= 0.0:
			continue
		var impulse := (
			push_direction
			* props_rigidbody.mass
			* speed_difference
		)
		props_rigidbody.apply_central_impulse(impulse)
