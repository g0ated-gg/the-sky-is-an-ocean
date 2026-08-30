class_name Props
extends RigidBody3D


enum GravityType { FROM_POINT, TO_POINT, FLAT }


@export var gravity_type := GravityType.FROM_POINT:
	set(value):
		gravity_type = value
		update_gravity_scale()
@export var gravity_point := Vector3.ZERO # global
@export var formal_gravity_scale := 1.0:
	set(value):
		formal_gravity_scale = value
		update_gravity_scale()


@onready var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")


func _ready() -> void:
	update_gravity_scale()

func update_gravity_scale() -> void:
	gravity_scale = 0.0 if gravity_type != GravityType.FLAT else formal_gravity_scale

func get_point_gravity_vector() -> Vector3:
	if gravity_type == GravityType.FROM_POINT:
		return (global_position - gravity_point).normalized()
	if gravity_type == GravityType.TO_POINT:
		return (gravity_point - global_position).normalized()
	return Vector3.DOWN

func get_point_gravity() -> Vector3:
	return get_point_gravity_vector() * gravity * formal_gravity_scale

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if gravity_type in [GravityType.FROM_POINT, GravityType.TO_POINT]:
		state.apply_central_force(get_point_gravity() * mass)
