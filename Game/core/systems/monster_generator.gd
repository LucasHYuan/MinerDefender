extends Node2D
class_name MonsterGenerator

const LOG_MODULE := "Core.Systems"

@onready var interval_timer: Timer = $IntervalTimer
@onready var wave_interval_timer: Timer = $WaveIntervalTimer

@export var enemy_path: Path2D
@export var enemy_spawn_location: PathFollow2D

@export var scene: PackedScene
@export var enemy_prototypes: Array[PackedScene] = [preload("res://features/enemy/skull.tscn"), preload("res://features/enemy/octopus.tscn")]

@export var cycle_controller: CycleController

const SPAWN_RADIUS = 10

# 两种刷怪模式
# 1. 持续不断地以低频刷怪
# 2. 在一定时间周期内分波次刷怪

# 拿着所有怪物的引用，执行全体操作

var enemy_list: Array = []
var interval_enemy_list: Array = enemy_prototypes
var wave_enemy_list: Array = enemy_prototypes

var wave_data: Array = [
	[ # 第一波 赚启动资金
		[[0, 1]], # 第一小波，怪物种类0生成1个
		[[0, 2]], # 第二小波
		[[0, 3]] # 第三小波
	],
	[ # 第二波 给牧场一些攒钱时间
		[[0, 3]],
		[[0, 1], [0, 1], [0, 1]],
		[[0, 1], [1, 1]],
	],
	[ # 第三波 上压力，需要造出1个防御塔
		[[0, 4], ],
		[[0, 4], [1, 2], ],
		[[1, 3], [0, 3], [0, 3]]
	],
	[ # 第四波 准备推平
		[[0, 8], [0, 8], [1, 4], [1, 4]],
		[[0, 10], [1, 8], ],
		[[0, 10], [0, 10], [1, 8]]
	]
]

var wave_index: int = 0 # 夜晚数
var wave_inner_index: int = 0 # 夜晚的波次数


func _ready() -> void:
	interval_timer.timeout.connect(_on_interval_timeout)
	wave_interval_timer.timeout.connect(_on_wave_interval_timeout)

	# cycle_controller.day.connect(_generate_by_interval)
	cycle_controller.night.connect(_generate_next_wave)


func _generate_next_wave(duration: float) -> void:
	AppLogger.info(LOG_MODULE, "Night started. Duration=%.2f" % duration)
	_generate_by_wave(wave_index, duration) # 在N秒内刷出对应波次的怪物

# 在duration中刷出对应波次的怪物
func _generate_by_wave(index: int, duration: float):
	var data = wave_data[index] # 获取这一波的怪物数据
	var size = data.size() # 这一波中有多少小波次

	var interval = duration / (size - 1) / 1.6 # 每小波之间的间隔时间
	wave_interval_timer.wait_time = interval
	wave_inner_index = 0 # 初始化小波次索引
	_add_wave_enemy(wave_index, wave_inner_index) # 生成第一小波怪物
	wave_interval_timer.start()


func _on_wave_interval_timeout() -> void:
	var wave_size = wave_data[wave_index].size()
	if wave_inner_index >= wave_size - 1:
		# 当前波次的所有小波都刷完了，准备下一波
		AppLogger.info(LOG_MODULE, "Finished all waves for this night. Preparing next night.")
		wave_index += 1
		wave_inner_index = 0
		wave_interval_timer.stop()
		return
	else:
		# 继续刷下一小波
		wave_inner_index += 1
		_add_wave_enemy(wave_index, wave_inner_index)
	

#func _add_wave_enemy(wave: int, index: int) -> void:
	#print("刷怪,夜晚：", wave, " 波次", index)
	#var enemy_index = randi()%wave_enemy_list.size()
	#_add_enemy_random_pos(enemy_index, wave_data[wave][index])
	
func _add_wave_enemy(wave: int, inner_wave_index: int) -> void:
	AppLogger.info(LOG_MODULE, "Spawning wave %d, inner wave %d" % [wave, inner_wave_index])
	var inner_wave_data = wave_data[wave][inner_wave_index] # 获取这一小波的怪物数据

	# 遍历这一小波中的每种怪物并生成相应数量
	for enemy_data in inner_wave_data:
		var enemy_type = enemy_data[0] # 怪物种类
		var enemy_count = enemy_data[1] # 怪物数量
		_add_enemy_random_pos(enemy_type, enemy_count) # 生成指定数量的怪物


# 以一定频率刷怪
func _generate_by_interval(interval: float) -> void:
	interval_timer.wait_time = interval
	interval_timer.start()

func _on_interval_timeout() -> void:
	_add_random_enemy()

func _stop_generate() -> void:
	interval_timer.stop()

func _add_random_enemy():
	var enemy_index = randi()%interval_enemy_list.size() # 随机选择一个怪物
	_add_enemy_random_pos(enemy_index) # 随机位置生成一只

# 在随机位置生成几只怪物
func _add_enemy_random_pos(index: int, num: int = 1):
	AppLogger.info(LOG_MODULE, "Spawning %d enemies at random positions" % num)
	var enemy = interval_enemy_list[index]
	var pos = _get_random_point()
	for i in range(num):
		var e = enemy.instantiate()
		e.position = pos + _get_random_offset()
		enemy_list.append(e)
		add_child(e)

func _get_random_offset() -> Vector2:
	return Vector2(randi_range(-SPAWN_RADIUS, SPAWN_RADIUS), randi_range(-SPAWN_RADIUS, SPAWN_RADIUS))

func _get_random_point() -> Vector2:
	enemy_spawn_location.progress_ratio = randf()
	return enemy_spawn_location.position
