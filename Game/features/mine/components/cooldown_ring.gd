extends Node2D
class_name CooldownRing

@export var radius: float = 12.0
@export var width: float = 2.0
@export var color_ready: Color = Color(1, 1, 1, 0.4)
@export var color_cooldown: Color = Color(1, 1, 1, 0.6)

var _ratio: float = 0.0


func set_ratio(r: float) -> void:
	var clamped := clampf(r, 0.0, 1.0)
	if not is_equal_approx(_ratio, clamped):
		_ratio = clamped
		queue_redraw()


func _process(_delta: float) -> void:
	global_position = get_global_mouse_position()


func _draw() -> void:
	if _ratio <= 0.0:
		draw_arc(Vector2.ZERO, radius, 0, TAU, 32, color_ready, width)
		return
	var angle := TAU * (1.0 - _ratio)
	draw_arc(Vector2.ZERO, radius, -PI / 2.0, -PI / 2.0 + angle, 32, color_cooldown, width)
