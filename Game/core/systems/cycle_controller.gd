class_name CycleController

extends Node2D
signal day
signal night(duration: float)
signal one_second


## 世界在白天黑夜中不断循环
## 白天是休息阶段，也会刷怪，但不构成实质威胁
## 夜晚是怪物进攻阶段，压力激增
## cycle_controller 负责白天黑夜切换的表现
## 1 白天光亮、夜晚黑暗，并且颜色随时间逐渐变化
## 2 在白天、黑夜开始时，出现暂时的文字，告诉玩家敌人要进攻了or可以喘息
## 3 阶段内，显示时间的倒计时
## 4 由cycle_controller控制刷怪器进行
@onready var day_night_modulate: CanvasModulate = $DayNightModulate
@onready var state_timer: Timer = $StateTimer
@onready var count_down_timer: Timer = $CountDownTimer
@onready var transition_timer: Timer = $TransitionTimer
@onready var one_second_timer: Timer = $OneSecondTimer
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var countdown: Label = $CanvasLayer/Countdown

@export var day_colors: Array = [
	Color(1, 1, 1), # Mid day
	Color(0.843, 0.798, 0.688), # Afternoon
	Color(0.554, 0.589, 0.709), # Dusk
]
@export var night_colors: Array = [
	Color(0, 0.431, 1),
	Color(0.161, 0.573, 0.769),
	Color(0.224, 0.243, 0.333),
	Color(0.867, 0.741, 0.525),
]
@export var start_state: State = State.DAY
@onready var current_state: State = start_state

enum State {
	DAY = 0,
	NIGHT = 1,
}

var colors: Array = []
var color_index: int = 0

## 从白天开始，每晚时间不同
var day_index = 0
var day_time = [10, 10, 10, 10, 10] # 白天的喘息时间基本只用来建造
var night_time = [15, 20, 20, 20, 20] # 夜晚时间较长，刷怪、打怪、存钱
var times = []
var is_day: bool:
	get:
		return current_state == State.DAY

func _ready() -> void:
	# 监听GM指令
	GlobalSignal.add_listener("gmChangeTime", self, "_change_state")

	# 注册全局指令
	GlobalSignal.add_emitter("day", self)
	GlobalSignal.add_emitter("night", self)
	GlobalSignal.add_emitter("one_second", self)

	# 监听基地建造
	GlobalSignal.add_listener("camp_built", self, "_camp_built")

	state_timer.timeout.connect(_change_state)
	count_down_timer.timeout.connect(_count_down)
	transition_timer.timeout.connect(_transition_next_color)
	one_second_timer.timeout.connect(_one_second)
	one_second_timer.wait_time = 1.0
	one_second_timer.start()

	countdown.text = ""

func _one_second() -> void:
	one_second.emit()

func _camp_built() -> void:
	_start_by_state()

func _count_down() -> void:
	var remaining_time: int = round(state_timer.time_left) # 截断小数强制转换
	_set_count_down_text(remaining_time)

func _set_count_down_text(t: int) -> void:
	countdown.text = str(t)
	
# 日夜交替
func _change_state() -> void:
	_set_next_state()
	_start_by_state()

# 设置昼夜状态
func _set_next_state() -> void:
	if current_state == State.DAY:
		current_state = State.NIGHT
	else:
		current_state = State.DAY
		day_index += 1
	
# 根据当前状态开始计时
func _start_by_state() -> void:
	if current_state == State.DAY:
		times = day_time
		day.emit()
	else:
		times = night_time
		night.emit(times[day_index])
	var _time = times[day_index]
	state_timer.start(_time)
	_start_transition()
	_set_count_down_text(_time)

	# 开始数字倒计时
	count_down_timer.start(1.0)


func _start_transition() -> void:
	colors = day_colors if current_state == State.DAY else night_colors
	color_index = 0
	_transition_next_color()

# 整段渐变由多个颜色组成，在此切换
func _transition_next_color() -> void:
	var duration = times[day_index] / float(colors.size())
	_transition_to_color(colors[color_index], duration)
	color_index = (color_index + 1) % colors.size()
	if color_index > 0:
		transition_timer.start(duration)
	else:
		transition_timer.stop()


# 在一段时间内切换到目标颜色
func _transition_to_color(target_color: Color, duration: float) -> void:
	var anim = animation_player.get_animation("transition")
	if anim:
		anim.length = duration
		anim.track_insert_key(0, 0, day_night_modulate.color) # 设置当前颜色
		anim.track_insert_key(0, duration, target_color) # 设置目标颜色
		animation_player.stop()
		animation_player.play("transition")
