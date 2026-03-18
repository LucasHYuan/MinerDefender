extends Node2D

const LOG_MODULE := "MineMode1"
const CELL_SIZE := 32

var local_ores: Dictionary = {}

@onready var mine_level: MineLevel = $MineLevel
@onready var machine: ShieldMachine = $ShieldMachine
@onready var miner: Node2D = $Miner
@onready var spawner: MineMonsterSpawner = $MineMonsterSpawner

var _ore_label: Label
var _fuel_label: Label


func _ready() -> void:
	mine_level.add_to_group("mine_level")
	mine_level.block_destroyed.connect(_on_block_destroyed)

	var center_x := (mine_level.grid_width / 2) * CELL_SIZE
	machine.position = Vector2(center_x, 0)
	miner.position = Vector2(center_x, -32)

	mine_level.position = Vector2(0, CELL_SIZE)
	mine_level.generate()

	var jetpack := miner.get_node_or_null("JetpackController") as JetpackController
	if jetpack:
		jetpack.fuel_changed.connect(_on_fuel_changed)

	_create_hud()
	AppLogger.info(LOG_MODULE, "Mode 1 scene ready. Player + ShieldMachine.")


func _create_hud() -> void:
	var canvas := CanvasLayer.new()
	canvas.name = "HUD"
	add_child(canvas)

	var vbox := VBoxContainer.new()
	vbox.anchor_right = 1.0
	vbox.offset_bottom = 48.0
	canvas.add_child(vbox)

	var panel := PanelContainer.new()
	vbox.add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_top", 4)
	panel.add_child(margin)

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 24)
	margin.add_child(hbox)

	_ore_label = Label.new()
	_ore_label.text = "Mode 1 | No ores collected"
	hbox.add_child(_ore_label)

	_fuel_label = Label.new()
	_fuel_label.text = "Fuel: --"
	hbox.add_child(_fuel_label)


func _update_hud() -> void:
	if local_ores.is_empty():
		_ore_label.text = "Mode 1 | No ores collected"
		return
	var parts: Array[String] = []
	for ore_type in local_ores:
		parts.append("%s: %d" % [ore_type, local_ores[ore_type]])
	_ore_label.text = "Mode 1 | " + " | ".join(parts)


func _on_fuel_changed(current: float, maximum: float) -> void:
	if _fuel_label:
		_fuel_label.text = "Fuel: %.0f/%.0f" % [current, maximum]


func _on_block_destroyed(_col: int, _row: int, ore_type: StringName, ore_amount: int) -> void:
	if ore_type == &"none":
		return
	if not local_ores.has(ore_type):
		local_ores[ore_type] = 0
	local_ores[ore_type] += ore_amount
	_update_hud()
