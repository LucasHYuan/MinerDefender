extends Node2D
class_name MineLevel

const LOG_MODULE := "Mine"
const CELL_SIZE := 32

@export_group("Grid")
@export var grid_width: int = 20
@export var grid_depth: int = 30

var shaft_columns: Array[int] = []
var shaft_depth: int = -1

@export_group("Block Configs")
@export var dirt_config: BlockConfig
@export var iron_config: BlockConfig
@export var gold_config: BlockConfig
@export var block_scene: PackedScene

@export_group("Depth Rules")
@export var shallow_max_row: int = 5
@export var mid_max_row: int = 15

signal block_destroyed(col: int, row: int, ore_type: StringName, ore_amount: int)

@export_group("Pathfinding")
@export var path_rows_above: int = 5

var _grid: Dictionary = {}
var deepest_cleared_row: int = 0

var _block_container: Node2D
var _astar: AStar2D


func _ready() -> void:
	_block_container = Node2D.new()
	_block_container.name = "Blocks"
	add_child(_block_container)


func setup_shaft(columns: Array[int], depth: int = -1) -> void:
	shaft_columns = columns
	shaft_depth = depth


func generate() -> void:
	_clear_all()
	for row in range(grid_depth):
		for col in range(grid_width):
			if _is_shaft(col, row):
				continue
			var cfg := _pick_config(row)
			_spawn_block(col, row, cfg)
	_rebuild_astar()
	AppLogger.info(LOG_MODULE, "Generated %dx%d mine grid (%d blocks, shaft=%s depth=%d)" % [grid_width, grid_depth, _grid.size(), str(shaft_columns), shaft_depth])


func _is_shaft(col: int, row: int) -> bool:
	if col not in shaft_columns:
		return false
	if shaft_depth < 0:
		return true
	return row < shaft_depth


func _pick_config(row: int) -> BlockConfig:
	var roll := randf() * 100.0
	if row <= shallow_max_row:
		if roll < 90.0:
			return dirt_config
		return iron_config
	elif row <= mid_max_row:
		if roll < 60.0:
			return dirt_config
		elif roll < 90.0:
			return iron_config
		return gold_config
	else:
		if roll < 40.0:
			return dirt_config
		elif roll < 70.0:
			return iron_config
		return gold_config


func _spawn_block(col: int, row: int, cfg: BlockConfig) -> void:
	if block_scene == null:
		return
	var block: MiningBlock = block_scene.instantiate()
	block.position = Vector2(col * CELL_SIZE, row * CELL_SIZE)
	_block_container.add_child(block)
	block.apply_config(cfg)
	block.block_broken.connect(_on_block_broken.bind(col, row))
	_grid[Vector2i(col, row)] = block


func _on_block_broken(ore_type: StringName, ore_amount: int, col: int, row: int) -> void:
	_grid.erase(Vector2i(col, row))
	_astar_add_cell(col, row)
	block_destroyed.emit(col, row, ore_type, ore_amount)
	if row > deepest_cleared_row:
		deepest_cleared_row = row


func _clear_all() -> void:
	for key in _grid:
		var block = _grid[key]
		if is_instance_valid(block):
			block.queue_free()
	_grid.clear()
	deepest_cleared_row = 0


func get_spawn_position() -> Vector2:
	var shaft_center := 0.0
	for col in shaft_columns:
		shaft_center += col
	shaft_center /= shaft_columns.size()
	return Vector2(shaft_center * CELL_SIZE, -CELL_SIZE)


func get_grid_pixel_width() -> float:
	return grid_width * CELL_SIZE


func get_grid_pixel_depth() -> float:
	return grid_depth * CELL_SIZE


func is_cell_empty(col: int, row: int) -> bool:
	return not _grid.has(Vector2i(col, row))


# --- AStar2D Pathfinding ---

func _cell_id(col: int, row: int) -> int:
	return (row + path_rows_above) * grid_width + col


func _is_cell_traversable(col: int, row: int) -> bool:
	if row < 0:
		return true
	return is_cell_empty(col, row)


func _rebuild_astar() -> void:
	_astar = AStar2D.new()
	var min_row := -path_rows_above
	for row in range(min_row, grid_depth):
		for col in range(grid_width):
			if not _is_cell_traversable(col, row):
				continue
			var id := _cell_id(col, row)
			var world_pos := Vector2(col * CELL_SIZE, row * CELL_SIZE)
			_astar.add_point(id, world_pos)

	for row in range(min_row, grid_depth):
		for col in range(grid_width):
			if not _is_cell_traversable(col, row):
				continue
			var id := _cell_id(col, row)
			_connect_neighbor(id, col + 1, row)
			_connect_neighbor(id, col, row + 1)


func _connect_neighbor(from_id: int, to_col: int, to_row: int) -> void:
	if to_col < 0 or to_col >= grid_width:
		return
	if to_row < -path_rows_above or to_row >= grid_depth:
		return
	if not _is_cell_traversable(to_col, to_row):
		return
	var to_id := _cell_id(to_col, to_row)
	if _astar.has_point(from_id) and _astar.has_point(to_id):
		if not _astar.are_points_connected(from_id, to_id):
			_astar.connect_points(from_id, to_id)


func _astar_add_cell(col: int, row: int) -> void:
	if _astar == null:
		return
	var id := _cell_id(col, row)
	if _astar.has_point(id):
		return
	_astar.add_point(id, Vector2(col * CELL_SIZE, row * CELL_SIZE))
	_connect_neighbor(id, col - 1, row)
	_connect_neighbor(id, col + 1, row)
	_connect_neighbor(id, col, row - 1)
	_connect_neighbor(id, col, row + 1)


func find_path_world(from: Vector2, to: Vector2) -> PackedVector2Array:
	if _astar == null or _astar.get_point_count() == 0:
		return PackedVector2Array()
	var from_id := _astar.get_closest_point(from - global_position)
	var to_id := _astar.get_closest_point(to - global_position)
	if from_id == to_id:
		return PackedVector2Array([to])
	var local_path := _astar.get_point_path(from_id, to_id)
	var world_path := PackedVector2Array()
	for p in local_path:
		world_path.append(p + global_position)
	return world_path
