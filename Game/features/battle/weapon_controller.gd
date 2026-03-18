extends Node2D
class_name WeaponController

@export var projectile_scene: PackedScene
@export var base_cooldown: float = 0.5
@export var base_speed: float = 200.0
@export var base_damage: float = 1.0
@export var shoot_point: NodePath

var _cooldown_timer: Timer
var _can_shoot: bool = true


func _ready() -> void:
	_cooldown_timer = Timer.new()
	_cooldown_timer.one_shot = true
	_cooldown_timer.timeout.connect(_on_cooldown_finished)
	add_child(_cooldown_timer)


func _on_cooldown_finished() -> void:
	_can_shoot = true


func can_shoot() -> bool:
	return _can_shoot


func get_shoot_origin() -> Vector2:
	if shoot_point != NodePath(""):
		var node := get_node_or_null(shoot_point) as Node2D
		if node != null:
			return node.global_position
	return global_position


func shoot_in_direction(dir: Vector2) -> void:
	if not _can_shoot:
		return
	if dir == Vector2.ZERO:
		return
	_spawn_projectile(dir.normalized())
	_start_cooldown()


func _start_cooldown() -> void:
	_can_shoot = false
	_cooldown_timer.start(base_cooldown)


func _spawn_projectile(dir: Vector2) -> void:
	if projectile_scene == null:
		return

	var config := {
		"speed": base_speed,
		"atk": base_damage,
		"instigator": owner,
	}
	if owner != null and "team" in owner:
		config["team"] = owner.team

	ProjectileUtil.spawn(projectile_scene, get_tree(), get_shoot_origin(), dir, config)
