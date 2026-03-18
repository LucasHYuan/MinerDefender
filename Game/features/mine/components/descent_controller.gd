extends Node
class_name DescentController

const LOG_MODULE := "Descent"
const CELL_SIZE := 32

signal descended(new_row: int)

@export var descent_speed: float = 40.0
@export var auto_descent: bool = true

var _descending: bool = false
var _target_y: float = 0.0


func _ready() -> void:
	var drill := get_parent().get_node_or_null("DrillHead") as DrillHead
	if drill != null:
		drill.row_cleared.connect(_on_row_cleared)
		AppLogger.info(LOG_MODULE, "DescentController wired to DrillHead")
	else:
		AppLogger.warn(LOG_MODULE, "No sibling DrillHead found")


func _physics_process(delta: float) -> void:
	if not _descending:
		return
	var parent := get_parent() as Node2D
	if parent == null:
		return

	var diff := _target_y - parent.position.y
	if absf(diff) < 1.0:
		parent.position.y = _target_y
		_descending = false

		var new_row := int(_target_y / CELL_SIZE)
		if parent is ShieldMachine:
			parent.current_row = new_row
		descended.emit(new_row)
		AppLogger.info(LOG_MODULE, "Descended to row %d (y=%.0f)" % [new_row, _target_y])
		return

	parent.position.y += signf(diff) * descent_speed * delta


func _on_row_cleared(row: int) -> void:
	if not auto_descent:
		return
	descend_one_row()


func descend_one_row() -> void:
	if _descending:
		return
	var parent := get_parent()
	if parent == null:
		return
	_target_y = parent.position.y + CELL_SIZE
	_descending = true
