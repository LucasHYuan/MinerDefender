extends StaticBody2D
class_name MineElevator

const LOG_MODULE := "Mine"
const CELL_SIZE := 32

@export var platform_width: int = 2
@export var shaft_depth: int = -1
@export var descent_speed: float = 60.0

var _target_y: float = 0.0
var _is_moving: bool = false


func _ready() -> void:
	_target_y = position.y


func _physics_process(delta: float) -> void:
	if not _is_moving:
		return
	var diff := _target_y - position.y
	if absf(diff) < 1.0:
		position.y = _target_y
		_is_moving = false
		AppLogger.info(LOG_MODULE, "Elevator arrived at depth y=%.0f" % position.y)
		return
	position.y += signf(diff) * descent_speed * delta


func descend_to_row(row: int) -> void:
	_target_y = (row - 1) * CELL_SIZE
	_is_moving = true
	AppLogger.info(LOG_MODULE, "Elevator descending to row %d (y=%.0f)" % [row, _target_y])


func get_platform_top_y() -> float:
	return position.y - 10.0
