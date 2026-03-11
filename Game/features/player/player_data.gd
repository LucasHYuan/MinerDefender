class_name PlayerData
extends Node
signal exp_changed
signal level_changed
signal coin_changed

@export var max_exp: int = 3
@export var init_coin: int = 0
@export var max_coin: int = 9999

func default_init() -> void:
	EXP = 0
	coin = init_coin
	level = 0

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
