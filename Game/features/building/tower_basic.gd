extends Buildings
class_name TowerBasic

@export var shoot_time:float=2 # 射击间隔
@export var attacker_speed:float=200 # 子弹速度
@export var atk:float=1 # 子弹伤害 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
