class_name PlayerData
extends Node
signal exp_changed
signal level_changed
signal coin_changed
signal ore_changed(ore_type: StringName, new_total: int)

@export var max_exp: int = 3
@export var init_coin: int = 0
@export var max_coin: int = 9999

var ores: Dictionary = {}

func default_init() -> void:
	EXP = 0
	coin = init_coin
	level = 0
	ores.clear()


func add_ore(ore_type: StringName, amount: int) -> void:
	if not ores.has(ore_type):
		ores[ore_type] = 0
	ores[ore_type] += amount
	ore_changed.emit(ore_type, ores[ore_type])


func get_ore(ore_type: StringName) -> int:
	return ores.get(ore_type, 0)

var EXP: int = 0:
	set(v):
		if v <= 0:
			return
		EXP = v
		if EXP >= max_exp:
			EXP -= max_exp
			level += 1
		exp_changed.emit()

var coin: int = init_coin:
	set(v):
		v = clampi(v, 0, max_coin)
		if coin == v:
			return
		coin = v
		coin_changed.emit()
		
var level: int = 0:
	set(v):
		if v <= 0:
			return
		level = v
		level_changed.emit()
