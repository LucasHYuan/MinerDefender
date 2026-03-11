class_name TimeCommands
extends Object

const LOG_MODULE := "Core.Systems"


static func toggle_day_night() -> void:
	# This implementation reuses the existing GM change-time signal,
	# so game logic does not need to know about the console directly.
	GlobalSignal.emit_signal_when_ready("gmChangeTime", [], GlobalSignal)
	AppLogger.info(LOG_MODULE, "Executed command: time.toggle_day_night")

