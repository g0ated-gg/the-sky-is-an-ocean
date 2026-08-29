class_name ConcaveWorldProps
extends RigidBody3D


@export var omnirepulsion_point := Vector3.ZERO # global


@onready var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")


func get_concave_world_gravity_vector() -> Vector3:
	return (global_position - omnirepulsion_point).normalized()

func get_concave_world_gravity() -> Vector3:
	return get_concave_world_gravity_vector() * gravity

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	state.apply_central_force(get_concave_world_gravity() * mass)
