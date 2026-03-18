extends CharacterBody2D
class_name MineEnemy

const LOG_MODULE := "MineEnemy"
const KNOCKBACK_AMOUNT := 20.0

signal enemy_death(enemy: Node)

enum MoveMode { WALK, FLY_PATHFIND }

@export var speed: float = 40.0
@export var jump_velocity: float = -250.0
@export var EXP: int = 1
@export var coin: int = 1
@export var move_mode: MoveMode = MoveMode.FLY_PATHFIND

const PATH_REFRESH_INTERVAL := 1.0
const WAYPOINT_REACH_DIST := 8.0

var team: GlobalInfo.Team = GlobalInfo.Team.enemy
var DEFAULT_TARGET: Node2D = null
var is_stay: bool = true

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var _dead: bool = false
var _mine_level: MineLevel
var _path: PackedVector2Array = PackedVector2Array()
var _path_index: int = 0
var _path_refresh_timer: float = 0.0

@onready var graphics: Node2D = $Graphics
@onready var battle_unit: BattleUnit = $BattleUnit
@onready var battle_search: BattleSearch = $BattleSearch


func _ready() -> void:
	battle_unit.unit_hurt.connect(_on_unit_hurt)
	battle_unit.unit_kickback.connect(_on_unit_kickback)
	battle_unit.unit_dead.connect(_on_unit_die)
	GlobalSignal.add_emitter("enemy_death", self)

	var levels := get_tree().get_nodes_in_group("mine_level")
	if levels.size() > 0:
		_mine_level = levels[0] as MineLevel

	AppLogger.info(LOG_MODULE, "MineEnemy ready at (%.0f, %.0f) mode=%s" % [global_position.x, global_position.y, MoveMode.keys()[move_mode]])


func _physics_process(delta: float) -> void:
	if _dead:
		return

	match move_mode:
		MoveMode.WALK:
			_walk_toward_target(delta)
		MoveMode.FLY_PATHFIND:
			_fly_pathfind(delta)

	move_and_slide()


func _fly_pathfind(delta: float) -> void:
	var target := _get_target()
	if target == null:
		velocity = velocity.move_toward(Vector2.ZERO, speed * delta * 3.0)
		return

	_path_refresh_timer -= delta
	if _path.is_empty() or _path_refresh_timer <= 0.0:
		_refresh_path(target)

	if _path_index < _path.size():
		var waypoint := _path[_path_index]
		var to_wp := waypoint - global_position
		if to_wp.length() < WAYPOINT_REACH_DIST:
			_path_index += 1
			if _path_index >= _path.size():
				velocity = velocity.move_toward(Vector2.ZERO, speed * delta * 3.0)
				return
			waypoint = _path[_path_index]
			to_wp = waypoint - global_position

		velocity = to_wp.normalized() * speed
		if not is_zero_approx(to_wp.x):
			graphics.scale.x = signf(to_wp.x)
	else:
		var dir := (target.global_position - global_position).normalized()
		velocity = dir * speed
		if not is_zero_approx(dir.x):
			graphics.scale.x = signf(dir.x)


func _refresh_path(target: Node2D) -> void:
	_path_refresh_timer = PATH_REFRESH_INTERVAL
	_path_index = 0
	if _mine_level != null:
		_path = _mine_level.find_path_world(global_position, target.global_position)
		if _path.size() > 1:
			_path_index = 1
	else:
		_path = PackedVector2Array([target.global_position])


func _walk_toward_target(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

	var target := _get_target()
	if target != null:
		var dir_x := signf(target.global_position.x - global_position.x)
		velocity.x = dir_x * speed
		if not is_zero_approx(dir_x):
			graphics.scale.x = dir_x
	else:
		velocity.x = move_toward(velocity.x, 0.0, speed * delta * 3.0)

	if is_on_floor() and is_on_wall() and not is_zero_approx(velocity.x):
		velocity.y = jump_velocity


func _get_target() -> Node2D:
	if battle_search != null and battle_search.target != null:
		return battle_search.target
	return DEFAULT_TARGET


func _on_unit_hurt(_attack: AttackItem) -> void:
	pass


func _on_unit_kickback(kickback: Vector2) -> void:
	translate(kickback * KNOCKBACK_AMOUNT)


func _on_unit_die() -> void:
	if _dead:
		return
	_dead = true
	speed = 0
	velocity = Vector2.ZERO

	var hit := get_node_or_null("HitAttacker") as HitAttacker
	if hit:
		hit.set_active(false)

	enemy_death.emit(self)

	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.4)
	tween.tween_callback(queue_free)


func destroy() -> void:
	queue_free()
