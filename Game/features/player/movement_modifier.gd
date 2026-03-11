class_name MovementModifier
extends RefCounted

# Base interface for movement modifiers (buffs, debuffs, etc.).
# Implementations can adjust movement speed or the final velocity vector.

func apply_speed(base_speed: float) -> float:
	# Override in subclasses to modify the scalar speed.
	return base_speed


func apply_velocity(velocity: Vector2) -> Vector2:
	# Override in subclasses to modify the full velocity vector.
	return velocity

