class_name BuildComponent
extends Node2D

@onready var icon: Sprite2D = $Graphics/Icon
@onready var ui: Container = $CanvasLayer/VBoxContainer
@onready var interactable_area: Interactable = $Interactable_area
@onready var button: Button = $CanvasLayer/VBoxContainer/Button
@onready var label: Label = $CanvasLayer/VBoxContainer/Label
@onready var labelDescription: Label = $CanvasLayer/VBoxContainer/Description

# signal build_ask(price: int) # 向玩家请求建造
signal build # 建造
signal show_ui
signal hide_ui

var price: int = 0
var nameLabel: String = "未命名"
var descriptionLabel: String = "未命名"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# 绑定interactable
	interactable_area.interacted.connect(interacting)
	interactable_area.uninteracted.connect(interacting_end)
	button.pressed.connect(_on_Button_pressed)

	price = get_parent().price
	nameLabel = get_parent().buildingName
	descriptionLabel = get_parent().descriptionLabel
	button.text = str(price)
	label.text = nameLabel
	labelDescription.text = descriptionLabel

	# 初始化
	ui.visible = false

	# 监听全局信号
	# GlobalSignal.add_listener("day", self, "_on_day")
	# GlobalSignal.add_listener("night", self, "_on_night")

func interacting() -> void:
	show_ui.emit()
	ui.visible = true

func interacting_end() -> void:
	hide_ui.emit()
	ui.visible = false

func set_can_built(can_built: bool) -> void:
	if can_built:
		# 显示并激活碰撞
		icon.visible = true
		interactable_area.process_mode = Node.PROCESS_MODE_INHERIT
	else:
		# 隐藏并禁用碰撞
		icon.visible = false
		interactable_area.process_mode = Node.PROCESS_MODE_DISABLED


func _on_Button_pressed() -> void:
	# 检查钱够不够
	# build_ask.emit(price)
	var player = GlobalObjects.GetObject("player")
	if player:
		if player.data.coin >= price:
			player.data.coin -= price
			build_process()


func build_process() -> void:
	# 钱够,建造
	build.emit()
	self.queue_free()
	pass

# func _on_day() -> void:
# 	# 白天显示地基，可建造
# 	interactable_area.process_mode = Node.PROCESS_MODE_INHERIT
# 	icon.visible = true
# 	pass

# func _on_night(_duration: float) -> void:
# 	# 夜晚隐藏地基，不可建造
# 	interactable_area.process_mode = Node.PROCESS_MODE_DISABLED
# 	icon.visible = false
# 	pass
