extends Node
class_name MineMonsterSpawner

const LOG_MODULE := "Mine"
const CELL_SIZE := 32

@export var spawn_rules: Array[MineSpawnRule] = []
@export var spawn_container_path: NodePath
@export var target_path: NodePath
@export var mine_level_path: NodePath

@export_group("Spawn Area")
@export var spawn_margin_y: float = 64.0

var _timers: Array[Timer] = []
var _alive_counts: Array[int] = []
var _target: Node2D
var _container: Node2D
var _mine_level: MineLevel


func _ready() -> void:
	_target = get_node_or_null(target_path)
	_mine_level = get_node_or_null(mine_level_path) as MineLevel
	_container = get_node_or_null(spawn_container_path) as Node2D
	if _container == null:
		_container = Node2D.new()
		_container.name = "EnemyContainer"
		get_parent().add_child.call_deferred(_container)

	for i in range(spawn_rules.size()):
		_alive_counts.append(0)
		var timer := Timer.new()
		timer.wait_time = spawn_rules[i].spawn_interval
		timer.one_shot = false
		timer.timeout.connect(_on_spawn_timer.bind(i))
		add_child(timer)
		_timers.append(timer)
		timer.start()

	AppLogger.info(LOG_MODULE, "Spawner ready: %d rules, target=%s" % [spawn_rules.size(), str(_target)])


func _get_target_row() -> int:
	if _target == null:
		return -999
	var target_y := _target.global_position.y
	if _mine_level != null:
		target_y -= _mine_level.global_position.y
	return int(target_y / CELL_SIZE)


func _on_spawn_timer(rule_index: int) -> void:
	if _target == null:
		AppLogger.warn(LOG_MODULE, "Spawn timer[%d] fired but target is null" % rule_index)
		return
	var rule := spawn_rules[rule_index]

	var target_row := _get_target_row()
	AppLogger.info(LOG_MODULE, "Timer[%d] check: target_row=%d, rule=[%d,%d], alive=%d/%d" % [
		rule_index, target_row, rule.min_depth_row, rule.max_depth_row,
		_alive_counts[rule_index], rule.max_alive])

	if target_row < rule.min_depth_row or target_row > rule.max_depth_row:
		return
	if _alive_counts[rule_index] >= rule.max_alive:
		return

	_spawn_enemy(rule_index)


func _spawn_enemy(rule_index: int) -> void:
	var rule := spawn_rules[rule_index]
	if rule.enemy_scene == null:
		return

	var enemy := rule.enemy_scene.instantiate()
	var pos := _get_spawn_position_above()
	enemy.position = pos

	if "is_stay" in enemy:
		enemy.is_stay = true
	if "move_mode" in enemy:
		enemy.move_mode = MineEnemy.MoveMode.FLY_PATHFIND

	_container.add_child(enemy)
	_alive_counts[rule_index] += 1

	if "DEFAULT_TARGET" in enemy:
		enemy.DEFAULT_TARGET = _target

	if enemy.has_signal("enemy_death"):
		enemy.enemy_death.connect(_on_enemy_died.bind(rule_index))

	AppLogger.info(LOG_MODULE, "Spawned enemy at (%.0f, %.0f) rule %d" % [pos.x, pos.y, rule_index])


func _on_enemy_died(_enemy: Node, rule_index: int) -> void:
	_alive_counts[rule_index] = maxi(0, _alive_counts[rule_index] - 1)


func _get_spawn_position_above() -> Vector2:
	if _target == null:
		return Vector2.ZERO
	var grid_width_px := 640.0
	if _mine_level != null:
		grid_width_px = _mine_level.get_grid_pixel_width()
	var x := randf_range(0.0, grid_width_px)
	if _mine_level != null:
		x += _mine_level.global_position.x

	var ref_y: float
	if _mine_level != null:
		ref_y = _mine_level.global_position.y - CELL_SIZE
	else:
		ref_y = _target.global_position.y
	var y := ref_y - spawn_margin_y - randf_range(0.0, 32.0)
	return Vector2(x, y)
