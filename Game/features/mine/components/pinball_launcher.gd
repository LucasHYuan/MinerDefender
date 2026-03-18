extends Node2D
class_name PinballLauncher

const LOG_MODULE := "PinballLauncher"

signal pinball_launched(pinball: Node)

@export var projectile_scene: PackedScene
@export var fire_interval: float = 3.0
@export var auto_fire: bool = false
@export var launch_speed: float = 300.0
@export var show_cooldown_ring: bool = true

var _timer: Timer
var _cooldown: float = 0.0
var _ring: CooldownRing


func _ready() -> void:
	if auto_fire:
		_timer = Timer.new()
		_timer.wait_time = fire_interval
		_timer.one_shot = false
		_timer.timeout.connect(_auto_launch)
		add_child(_timer)
		_timer.start()
		AppLogger.info(LOG_MODULE, "Auto-fire enabled, interval=%.1f" % fire_interval)
	else:
		AppLogger.info(LOG_MODULE, "Manual-fire mode, click to launch. cooldown=%.1f" % fire_interval)

	if show_cooldown_ring and not auto_fire:
		_ring = CooldownRing.new()
		add_child(_ring)


func get_cooldown_ratio() -> float:
	if fire_interval <= 0.0:
		return 0.0
	return clampf(_cooldown / fire_interval, 0.0, 1.0)


func _process(delta: float) -> void:
	if _cooldown > 0.0:
		_cooldown -= delta
	if _ring != null:
		_ring.set_ratio(get_cooldown_ratio())


func _unhandled_input(event: InputEvent) -> void:
	if auto_fire:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if _cooldown > 0.0:
			return
		var mouse_pos := get_global_mouse_position()
		var dir := (mouse_pos - global_position).normalized()
		launch(dir)
		_cooldown = fire_interval


func _auto_launch() -> void:
	var angle := randf_range(-PI * 0.35, -PI * 0.65)
	var dir := Vector2.from_angle(angle)
	launch(dir)


func launch(direction: Vector2) -> void:
	if projectile_scene == null:
		AppLogger.warn(LOG_MODULE, "No projectile_scene set")
		return

	var config := { "speed": launch_speed }
	var owner_node := get_parent()
	if owner_node != null and "team" in owner_node:
		config["team"] = owner_node.team
	if owner_node is PhysicsBody2D:
		config["exclude_body"] = owner_node

	var pinball := ProjectileUtil.spawn(projectile_scene, get_tree(), global_position, direction, config)
	if pinball:
		pinball_launched.emit(pinball)
		AppLogger.info(LOG_MODULE, "Launched pinball dir=(%.2f, %.2f)" % [direction.x, direction.y])
