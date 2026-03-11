extends Hitbox
class_name HitAttacker

@export var atk: float = 1
@export var kickback: float = 0

@onready var collision: CollisionShape2D = $HitCollision

var team: GlobalInfo.Team

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	if owner != null:
		var t = owner.get("team")
		if t != null:
			team = t
			_set_team()

func set_team(_team: GlobalInfo.Team) -> void:
	self.team = _team
	_set_team()

func _set_team() -> void:
	# 避免自己伤害自己
	collision_mask &= ~(1 << team)

func set_active(active: bool) -> void:
	set_deferred("collision.disabled", !active)
