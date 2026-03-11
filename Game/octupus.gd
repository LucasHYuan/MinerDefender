extends Enemy
class_name Octupus

@onready var attacker: HitAttacker = $HitAttacker

@export var shoot_time:float=1.5
@export var attacker_speed:float=50
@export var atk:float=1

func init_stats() -> void:
	super.init_stats()

func set_active(_active: bool) -> void:
	super.set_active(_active)
	attacker.set_active(_active)
