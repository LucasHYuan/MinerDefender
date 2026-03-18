extends StaticBody2D
class_name ShieldMachine

const LOG_MODULE := "ShieldMachine"
const CELL_SIZE := 32

@export var platform_width: int = 3

var current_row: int = 0
var team: GlobalInfo.Team = GlobalInfo.Team.player

@onready var battle_unit: BattleUnit = $BattleUnit


func _ready() -> void:
	add_to_group("shield_machine")
	AppLogger.info(LOG_MODULE, "ShieldMachine ready at row %d (width=%d cells)" % [current_row, platform_width])


func get_platform_half_width_px() -> float:
	return (platform_width * CELL_SIZE) / 2.0
