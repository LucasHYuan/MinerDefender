extends Node
class_name JetpackController

const LOG_MODULE := "Jetpack"

signal fuel_changed(current: float, maximum: float)

@export var thrust_force: float = 400.0
@export var max_fuel: float = 3.0
@export var fuel_regen_rate: float = 1.5
@export var fuel_burn_rate: float = 1.0

var current_fuel: float


func _ready() -> void:
	current_fuel = max_fuel
	AppLogger.info(LOG_MODULE, "JetpackController ready. fuel=%.1f, thrust=%.0f" % [max_fuel, thrust_force])


func _physics_process(delta: float) -> void:
	var body := get_parent() as CharacterBody2D
	if body == null:
		return

	if body.is_on_floor():
		_regen_fuel(delta)

	if Input.is_action_pressed("jump") and current_fuel > 0.0 and not body.is_on_floor():
		body.velocity.y = -thrust_force
		current_fuel -= fuel_burn_rate * delta
		current_fuel = maxf(current_fuel, 0.0)
		fuel_changed.emit(current_fuel, max_fuel)


func _regen_fuel(delta: float) -> void:
	if current_fuel >= max_fuel:
		return
	current_fuel += fuel_regen_rate * delta
	current_fuel = minf(current_fuel, max_fuel)
	fuel_changed.emit(current_fuel, max_fuel)
