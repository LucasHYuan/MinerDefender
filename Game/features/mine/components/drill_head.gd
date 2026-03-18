extends Node
class_name DrillHead

const LOG_MODULE := "DrillHead"
const CELL_SIZE := 32

signal row_cleared(row: int)

@export var drill_damage: int = 1
@export var drill_interval: float = 2.0
@export var drill_width: int = 3
@export var mine_level_path: NodePath

var _mine_level: MineLevel
var _timer: Timer
var _current_target_row: int = 0


func _ready() -> void:
	_mine_level = get_node_or_null(mine_level_path) as MineLevel
	if _mine_level == null:
		var nodes := get_tree().get_nodes_in_group("mine_level")
		if nodes.size() > 0:
			_mine_level = nodes[0] as MineLevel

	_timer = Timer.new()
	_timer.wait_time = drill_interval
	_timer.one_shot = false
	_timer.timeout.connect(_on_drill_tick)
	add_child(_timer)
	_timer.start()

	_current_target_row = _get_owner_row() + 1
	AppLogger.info(LOG_MODULE, "DrillHead ready. width=%d, damage=%d, interval=%.1f, target_row=%d" % [drill_width, drill_damage, drill_interval, _current_target_row])


func _on_drill_tick() -> void:
	if _mine_level == null:
		return

	var owner_row := _get_owner_row()
	_current_target_row = owner_row + 1

	var center_col := _get_owner_center_col()
	var half := drill_width / 2
	var all_clear := true

	for i in range(drill_width):
		var col := center_col - half + i
		if col < 0 or col >= _mine_level.grid_width:
			continue
		if not _mine_level.is_cell_empty(col, _current_target_row):
			all_clear = false
			var block = _mine_level._grid.get(Vector2i(col, _current_target_row))
			if block != null and is_instance_valid(block):
				block.hit(drill_damage)

	if all_clear:
		AppLogger.info(LOG_MODULE, "Row %d cleared beneath drill" % _current_target_row)
		row_cleared.emit(_current_target_row)


func _get_owner_row() -> int:
	var owner_node := get_parent() as Node2D
	if owner_node == null:
		return 0
	var y := owner_node.global_position.y
	if _mine_level != null:
		y -= _mine_level.global_position.y
	return int(y / CELL_SIZE)


func _get_owner_center_col() -> int:
	var owner_node := get_parent() as Node2D
	if owner_node == null:
		return 0
	var x := owner_node.global_position.x
	if _mine_level != null:
		x -= _mine_level.global_position.x
	return int(x / CELL_SIZE)
