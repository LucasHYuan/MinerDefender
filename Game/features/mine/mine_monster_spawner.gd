extends Node
class_name MineMonsterSpawner

const LOG_MODULE := "Mine"
const CELL_SIZE := 32

@export var spawn_rules: Array[MineSpawnRule] = []
@export var spawn_container_path: NodePath
@export var miner_path: NodePath
@export var mine_level_path: NodePath

@export_group("Spawn Area")
@export var spawn_margin_x: float = 120.0
@export var spawn_margin_y: float = 32.0

var _timers: Array[Timer] = []
var _alive_counts: Array[int] = []
var _miner: Node2D
var _container: Node2D
var _mine_level: MineLevel


func _ready() -> void:
	_miner = get_node_or_null(miner_path)
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


func _get_miner_row() -> int:
	if _miner == null:
		return -999
	var miner_y := _miner.global_position.y
	if _mine_level != null:
		miner_y -= _mine_level.global_position.y
	return int(miner_y / CELL_SIZE)


func _on_spawn_timer(rule_index: int) -> void:
	if _miner == null:
		AppLogger.warn(LOG_MODULE, "Spawn timer[%d] fired but _miner is null" % rule_index)
		return
	var rule := spawn_rules[rule_index]

	var miner_row := _get_miner_row()
	AppLogger.info(LOG_MODULE, "Timer[%d] check: miner_row=%d, rule=[%d,%d], alive=%d/%d" % [
		rule_index, miner_row, rule.min_depth_row, rule.max_depth_row,
		_alive_counts[rule_index], rule.max_alive])

	if miner_row < rule.min_depth_row or miner_row > rule.max_depth_row:
		return
	if _alive_counts[rule_index] >= rule.max_alive:
		return

	_spawn_enemy(rule_index)


func _spawn_enemy(rule_index: int) -> void:
	var rule := spawn_rules[rule_index]
	if rule.enemy_scene == null:
		return

	var enemy := rule.enemy_scene.instantiate()
	var pos := _get_offscreen_position()
	enemy.position = pos

	if "is_stay" in enemy:
		enemy.is_stay = true

	_container.add_child(enemy)
	_alive_counts[rule_index] += 1

	# Inject Miner as fallback target so the enemy always chases it
	if "DEFAULT_TARGET" in enemy:
		enemy.DEFAULT_TARGET = _miner

	if enemy.has_signal("enemy_death"):
		enemy.enemy_death.connect(_on_enemy_died.bind(rule_index))

	AppLogger.info(LOG_MODULE, "Spawned mine enemy at (%.0f, %.0f) for rule %d (miner row=%d)" % [pos.x, pos.y, rule_index, _get_miner_row()])


func _on_enemy_died(_enemy: Node, rule_index: int) -> void:
	_alive_counts[rule_index] = maxi(0, _alive_counts[rule_index] - 1)


func _get_offscreen_position() -> Vector2:
	if _miner == null:
		return Vector2.ZERO
	var side := 1.0 if randf() > 0.5 else -1.0
	var offset_x := spawn_margin_x * side + randf_range(-32, 32)
	# Keep Y near Miner level; gravity will pull the enemy down to the nearest floor
	var offset_y := randf_range(-spawn_margin_y, 0.0)
	return _miner.global_position + Vector2(offset_x, offset_y)
