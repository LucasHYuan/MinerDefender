extends Enemy
class_name Skull

@onready var attacker: HitAttacker = $HitAttacker

func init_stats() -> void:
	super.init_stats()

func set_active(_active: bool) -> void:
	super.set_active(_active)
	attacker.set_active(_active)
