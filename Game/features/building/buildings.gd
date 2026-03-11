class_name Buildings
extends Node2D

@export var buildingName: String = "建筑名称"
@export var descriptionLabel: String = "建筑描述"
@export var price: int = 2
@onready var buildShow: Sprite2D = $BuildShow
@onready var building: Node2D = $Building
@onready var battle_unit: BattleUnit = $BattleUnit
@onready var buildC: BuildComponent = $BuildComponent

@export var pre_building: Buildings # 前置建筑,建造后解锁该建筑建造
@export var can_build: bool = false

var is_built: bool = false
var team: GlobalInfo.Team = GlobalInfo.Team.player

signal build

enum State {
	UNBUILT,
	BUILDING,
	IDLE,
}

var current_state: State = State.UNBUILT

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_game_connect()
	_init_build()
	if buildC.price == 0:
		# 自动建造
		buildC.build_process()


	# 监听全局信号
	GlobalSignal.add_listener("day", self, "_on_day")
	GlobalSignal.add_listener("one_second", self, "_on_one_second")

#region 游戏逻辑
func _game_connect() -> void:
	buildC.build.connect(_on_build)
	buildC.show_ui.connect(_on_build_show_ui)
	buildC.hide_ui.connect(_on_build_hide_ui)
	battle_unit.unit_dead.connect(_on_unit_die)
		
	if pre_building:
		pre_building.build.connect(_can_build)

func _can_build() -> void:
	# 允许建造该建筑
	can_build = true
	buildC.set_can_built(true)

func _on_unit_die() -> void:
	# 建筑被摧毁
	is_built = false
	_set_building_active(false)
#endregion

#region 建造基本实现
func _init_build() -> void:
	# 作为需要建造的建筑初始化
	current_state = State.UNBUILT

	# 隐藏建筑和预览
	_set_building_active(false)
	_on_build_hide_ui()

	if not can_build:
		buildC.set_can_built(false)

func _on_build_show_ui() -> void:
	# 展示预览图
	buildShow.visible = true

func _on_build_hide_ui() -> void:
	# 隐藏建筑预览
	buildShow.visible = false

func _on_build() -> void:
	build.emit()
	# 建造建筑
	_set_building_active(true)
	_on_build_hide_ui()

func _set_building_active(active: bool) -> void:
	# 激活/拆除建筑
	is_built = active
	building.visible = active

	call_deferred("_set_collision_active", active)
	if active:
		battle_unit.set_collision()
	else:
		battle_unit.hide_collision()

func _set_collision_active(active: bool) -> void:
	for child in building.get_children():
		if child is CollisionShape2D:
			child.disabled = not active
#endregion

#region 监听信号
func _on_day() -> void:
	pass

func _on_one_second() -> void:
	if is_built:
		_on_one_second_function()

func _on_day_function() -> void:
	# 在继承类中实现
	pass

func _on_one_second_function() -> void:
	# 在继承类中实现
	pass
