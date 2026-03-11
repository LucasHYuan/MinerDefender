class_name PlayerCommands
extends Object

const LOG_MODULE := "Player"


static func _get_player() -> Player:
	var player := GlobalObjects.GetObject("player")
	if player == null:
		AppLogger.error(LOG_MODULE, "Player instance not found in GlobalObjects.")
	return player


static func level_up() -> void:
	var player := _get_player()
	if player == null:
		return
	player._on_player_level_up()
	AppLogger.info(LOG_MODULE, "Executed command: player.levelup")


static func set_level(args: Array) -> void:
	var player := _get_player()
	if player == null:
		return
	if args.is_empty():
		AppLogger.warn(LOG_MODULE, "player.set_level requires a numeric level argument.")
		return
	var level_text := str(args[0])
	var new_level := int(level_text)
	if new_level <= 0:
		AppLogger.warn(LOG_MODULE, "player.set_level: level must be positive (got %d)." % new_level)
		return
	player.data.level = new_level
	AppLogger.info(LOG_MODULE, "Executed command: player.set_level %d" % new_level)

