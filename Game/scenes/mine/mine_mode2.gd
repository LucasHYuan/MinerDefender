extends Node2D

const LOG_MODULE := "MineMode2"
const CELL_SIZE := 32

var local_ores: Dictionary = {}

@onready var mine_level: MineLevel = $MineLevel
@onready var machine: ShieldMachine = $ShieldMachine
@onready var spawner: MineMonsterSpawner = $MineMonsterSpawner

var _ore_label: Label


func _ready() -> void:
	mine_level.add_to_group("mine_level")
	mine_level.block_destroyed.connect(_on_block_destroyed)

	var center_x := (mine_level.grid_width / 2) * CELL_SIZE
	machine.position = Vector2(center_x, 0)

	# Terrain starts right below the drill visual (drill bottom is +14 relative to machine,
	# and block centers sit at row * CELL_SIZE, so block top edge = center - 16).
	mine_level.position = Vector2(0, CELL_SIZE)
	mine_level.generate()

	_create_hud()
	AppLogger.info(LOG_MODULE, "Mode 2 scene ready. ShieldMachine auto-drills and launches pinballs.")


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
	_ore_label.text = "Mode 2 | No ores collected"
	margin.add_child(_ore_label)


func _update_hud() -> void:
	if local_ores.is_empty():
		_ore_label.text = "Mode 2 | No ores collected"
		return
	var parts: Array[String] = []
	for ore_type in local_ores:
		parts.append("%s: %d" % [ore_type, local_ores[ore_type]])
	_ore_label.text = "Mode 2 | " + " | ".join(parts)


func _on_block_destroyed(_col: int, _row: int, ore_type: StringName, ore_amount: int) -> void:
	if ore_type == &"none":
		return
	if not local_ores.has(ore_type):
		local_ores[ore_type] = 0
	local_ores[ore_type] += ore_amount
	_update_hud()
