class_name ConcaveWorldCreature
extends CharacterBody3D


@export var omnirepulsion_point := Vector3.ZERO # global


@onready var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")


func get_concave_world_gravity_vector() -> Vector3:
	return (global_position - omnirepulsion_point).normalized()

func get_concave_world_gravity() -> Vector3:
	return get_concave_world_gravity_vector() * gravity

func _physics_process(delta: float) -> void:
	up_direction = -get_concave_world_gravity_vector()
	if not is_on_floor():
		velocity += get_concave_world_gravity() * delta
