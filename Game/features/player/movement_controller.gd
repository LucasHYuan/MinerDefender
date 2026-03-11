class_name MovementController
extends RefCounted

const DEFAULT_BASE_SPEED := 50.0

# Base movement speed before any modifiers are applied.
var base_speed: float = DEFAULT_BASE_SPEED

# Optional upper cap for final movement speed (0 means no cap).
var max_speed: float = 0.0

# List of active movement modifiers (buffs, debuffs, etc.).
var modifiers: Array[MovementModifier] = []


func add_modifier(modifier: MovementModifier) -> void:
	if modifier == null:
		return
	if modifier in modifiers:
		return
	modifiers.append(modifier)


func remove_modifier(modifier: MovementModifier) -> void:
	modifiers.erase(modifier)


func clear_modifiers() -> void:
	modifiers.clear()


func get_input_direction() -> Vector2:
	# Returns normalized input direction based on keyboard actions (WASD / arrows).
	var x := Input.get_axis("move_left", "move_right")
	var y := Input.get_axis("move_up", "move_down")
	var dir := Vector2(x, y)
	if dir.length_squared() == 0.0:
		return Vector2.ZERO
	return dir.normalized()


func compute_speed() -> float:
	# Computes final scalar speed after applying all active modifiers.
	var current_speed := base_speed
	for modifier in modifiers:
		current_speed = modifier.apply_speed(current_speed)
	if max_speed > 0.0 and current_speed > max_speed:
		current_speed = max_speed
	return current_speed


func compute_velocity(direction: Vector2, _delta: float) -> Vector2:
	# Computes final velocity from direction and speed.
	# For now this is instantaneous; acceleration or smoothing
	# can be added later without changing Player code.
	if direction == Vector2.ZERO:
		return Vector2.ZERO
	var speed := compute_speed()
	return direction * speed

