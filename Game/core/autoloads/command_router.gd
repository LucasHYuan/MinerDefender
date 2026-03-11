extends Node

const LOG_MODULE := "Core.Systems"

var _commands: Dictionary = {}


func _ready() -> void:
	_register_builtin_commands()


func _register_builtin_commands() -> void:
	# Player-related commands.
	_commands["player.levelup"] = func (_args: Array) -> void:
		PlayerCommands.level_up()

	_commands["player.set_level"] = func (args: Array) -> void:
		PlayerCommands.set_level(args)

	# Time / day-night toggle command (basic).
	_commands["time.toggle_day_night"] = func (_args: Array) -> void:
		TimeCommands.toggle_day_night()


func register_command(name: String, handler: Callable) -> void:
	if handler.is_null():
		return
	_commands[name] = handler


func execute(command_text: String) -> void:
	var trimmed := command_text.strip_edges()
	if trimmed.is_empty():
		return

	var parts := trimmed.split(" ", false)
	var name: String = str(parts[0])
	var args: Array = []
	if parts.size() > 1:
		args = parts.slice(1, parts.size())

	if not _commands.has(name):
		AppLogger.warn(LOG_MODULE, "Unknown command: %s" % name)
		return

	var handler: Callable = _commands[name]
	if args.is_empty():
		handler.call([])
	else:
		handler.call(args)
