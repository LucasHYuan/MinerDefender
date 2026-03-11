extends Node2D

signal gmPlayerLevelUp
signal gmChangeTime

const LOG_MODULE := "UI.Debug"

@onready var button_lv_up: Button = $CanvasLayer/ButtonLvUp
@onready var button_change_time: Button = $CanvasLayer/ButtonChangeTime

func _ready() -> void:
	# 注册信号
	GlobalSignal.add_emitter("gmPlayerLevelUp", self)
	GlobalSignal.add_emitter("gmChangeTime", self)

	# 绑定按钮事件
	button_lv_up.pressed.connect(_on_button_lv_up_pressed)
	button_change_time.pressed.connect(_on_button_change_time_pressed)
	
func _on_button_lv_up_pressed():
	GMPrint("Player level up")
	gmPlayerLevelUp.emit()

func _on_button_change_time_pressed():
	GMPrint("Toggle day/night state")
	gmChangeTime.emit()


func GMPrint(text):
	AppLogger.info(LOG_MODULE, "GM command: %s" % text)
