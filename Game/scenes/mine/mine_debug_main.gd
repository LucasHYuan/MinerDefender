extends Node2D

const LOG_MODULE := "Mine"
const CELL_SIZE := 32

var local_ores: Dictionary = {}

@onready var mine_level: MineLevel = $MineLevel
@onready var miner: Miner = $Miner
@onready var elevator: MineElevator = $Elevator
@onready var spawner: MineMonsterSpawner = $MineMonsterSpawner

var _ore_label: Label


func _ready() -> void:
	mine_level.block_destroyed.connect(_on_block_destroyed)

	var shaft_cols := _compute_shaft_columns()
	mine_level.setup_shaft(shaft_cols, elevator.shaft_depth)
	mine_level.generate()

	var spawn_pos := mine_level.get_spawn_position()
	miner.position = Vector2(spawn_pos.x, spawn_pos.y - 32)
	elevator.position = Vector2(spawn_pos.x, -4)

	_create_hud()
	_create_depth_markers()

	AppLogger.info(LOG_MODULE, "Mine scene ready. Hold right-click to mine, left-click to shoot.")


func _compute_shaft_columns() -> Array[int]:
	var center_col := int(elevator.position.x / CELL_SIZE)
	var half := elevator.platform_width / 2
	var cols: Array[int] = []
	for i in range(elevator.platform_width):
		cols.append(center_col - half + i)
	return cols


func _create_hud() -> void:
	var canvas := CanvasLayer.new()
	canvas.name = "HUD"
	add_child(canvas)

	var panel := PanelContainer.new()
	panel.anchor_right = 1.0
	panel.offset_bottom = 32.0
	canvas.add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_top", 4)
	panel.add_child(margin)

	_ore_label = Label.new()
	_ore_label.text = "No ores collected"
	margin.add_child(_ore_label)


func _update_hud() -> void:
	if local_ores.is_empty():
		_ore_label.text = "No ores collected"
		return
	var parts: Array[String] = []
	for ore_type in local_ores:
		parts.append("%s: %d" % [ore_type, local_ores[ore_type]])
	_ore_label.text = " | ".join(parts)


func _create_depth_markers() -> void:
	var grid_px_width := mine_level.get_grid_pixel_width()
	var colors := [
		Color(1.0, 0.8, 0.2, 0.4),
		Color(1.0, 0.3, 0.2, 0.4),
		Color(0.8, 0.2, 0.8, 0.4),
	]
	for i in range(spawner.spawn_rules.size()):
		var rule: MineSpawnRule = spawner.spawn_rules[i]
		var y_pos := rule.min_depth_row * CELL_SIZE
		var color: Color = colors[i % colors.size()]

		var line := Line2D.new()
		line.width = 2.0
		line.default_color = color
		line.points = PackedVector2Array([Vector2(0, y_pos), Vector2(grid_px_width, y_pos)])
		mine_level.add_child(line)

		var label := Label.new()
		label.text = "DANGER ZONE (row %d+)" % rule.min_depth_row
		label.position = Vector2(4, y_pos - 14)
		label.add_theme_color_override("font_color", color)
		label.add_theme_font_size_override("font_size", 8)
		mine_level.add_child(label)


func _on_block_destroyed(col: int, row: int, ore_type: StringName, ore_amount: int) -> void:
	if ore_type == &"none":
		return
	if not local_ores.has(ore_type):
		local_ores[ore_type] = 0
	local_ores[ore_type] += ore_amount
	AppLogger.info(LOG_MODULE, "Collected %s x%d (total: %d)" % [ore_type, ore_amount, local_ores[ore_type]])
	_update_hud()
	_try_sync_player_data(ore_type, ore_amount)


func _try_sync_player_data(ore_type: StringName, ore_amount: int) -> void:
	var player = GlobalObjects.GetObjectOrNull("player")
	if player == null or player.data == null:
		return
	player.data.add_ore(ore_type, ore_amount)
