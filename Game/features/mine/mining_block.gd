extends StaticBody2D
class_name MiningBlock

const LOG_MODULE := "Mine"

signal block_broken(ore_type: StringName, ore_amount: int)

@export var config: BlockConfig

var max_durability: int = 1
var ore_type: StringName = &"none"
var ore_amount: int = 0
var current_durability: int

@onready var visual: Polygon2D = $Visual
@onready var durability_label: Label = $DurabilityLabel

var _base_color: Color


func _ready() -> void:
	if config != null:
		max_durability = config.max_durability
		ore_type = config.ore_type
		ore_amount = config.ore_amount
		visual.color = config.color
	_base_color = visual.color
	current_durability = max_durability
	_update_visuals()


func apply_config(cfg: BlockConfig) -> void:
	config = cfg
	max_durability = cfg.max_durability
	ore_type = cfg.ore_type
	ore_amount = cfg.ore_amount
	visual.color = cfg.color
	_base_color = cfg.color
	current_durability = max_durability
	_update_visuals()


func hit(damage: int = 1) -> void:
	current_durability -= damage
	_update_visuals()
	if current_durability <= 0:
		break_block()


func break_block() -> void:
	AppLogger.info(LOG_MODULE, "Block broken! Ore: %s x%d" % [ore_type, ore_amount])
	block_broken.emit(ore_type, ore_amount)
	queue_free()


func _update_visuals() -> void:
	durability_label.text = "%d/%d" % [current_durability, max_durability]
	var ratio := float(current_durability) / float(max_durability)
	visual.color = _base_color.darkened(0.5 * (1.0 - ratio))
