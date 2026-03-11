extends Node

const LEVEL_INFO := 0
const LEVEL_WARN := 1
const LEVEL_ERROR := 2

var log_level: int = LEVEL_INFO
var max_recent_logs: int = 100
var _recent_logs: Array[String] = []


func _append_recent(message: String) -> void:
	_recent_logs.append(message)
	if _recent_logs.size() > max_recent_logs:
		_recent_logs.pop_front()


func get_recent_logs() -> Array[String]:
	# Returns a copy of recent log messages for in-game consoles or UI.
	return _recent_logs.duplicate()


func info(module: String, message: String) -> void:
	if log_level > LEVEL_INFO:
		return
	var text := "[%s] %s" % [module, message]
	print(text)
	_append_recent(text)


func warn(module: String, message: String) -> void:
	if log_level > LEVEL_WARN:
		return
	var text := "[%s][Warning] %s" % [module, message]
	push_warning(text)
	_append_recent(text)


func error(module: String, message: String) -> void:
	if log_level > LEVEL_ERROR:
		return
	var text := "[%s][Error] %s" % [module, message]
	push_error(text)
	_append_recent(text)
