class_name SpeedBuff
extends MovementModifier

# Simple movement modifier that scales the movement speed
# by a constant multiplier (e.g. for speed buffs or debuffs).

var multiplier: float = 1.0


func _init(_multiplier: float = 1.0) -> void:
	multiplier = _multiplier


func apply_speed(base_speed: float) -> float:
	return base_speed * multiplier

