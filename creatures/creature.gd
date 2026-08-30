class_name Creature
extends CharacterBody3D


enum GravityType { FROM_POINT, TO_POINT, FLAT }


@export var gravity_type := GravityType.FROM_POINT
@export var gravity_point := Vector3.ZERO # global
@export var gravity_scale := 1.0


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
