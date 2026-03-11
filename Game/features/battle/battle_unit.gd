extends Node2D
class_name BattleUnit

const LOG_MODULE := "Battle"

@export var hurtbox: Hurtbox
@export var max_health: float = 1
@onready var team: GlobalInfo.Team = owner.team
@onready var healthBar: TextureProgressBar = $HealthBar

var is_dead: bool = false:
	get:
		return health <= 0
var health: float = 1
var invincible: bool = false

signal health_changed()
signal unit_kickback(kickback: Vector2)
signal unit_hurt(attack: AttackItem)
signal unit_dead()


func _ready() -> void:
	owner.team = team
	health = max_health
	hurtbox.battle_unit = self
	hurtbox.hurt.connect(_on_hurtbox_hurt)
	update_health()
	set_collision()

func set_collision() -> void:
	if team == GlobalInfo.Team.player:
		hurtbox.collision_layer = 1 << GlobalInfo.Team.player
	elif team == GlobalInfo.Team.enemy:
		hurtbox.collision_layer = 1 << GlobalInfo.Team.enemy

func hide_collision() -> void:
	hurtbox.collision_layer = 0
	

# 通用受击逻辑
func _on_hurtbox_hurt(hitbox: Hitbox) -> void:
	var attacker: Node2D = hitbox
	var attack = AttackItem.new(attacker.atk, attacker)

	_process_atk(attack)

# 伤害结算逻辑
func _process_atk(attack: AttackItem) -> void:
	if invincible:
		# 无敌状态下不受伤
		return

	# print("有效攻击，攻击者:", attack.attacker, "  攻击力:", attack.atk)
	_process_kickback(attack)

	health -= attack.atk
	
	update_health()
	health_changed.emit()
	unit_hurt.emit(attack)

	if health <= 0:
		health = 0
		unit_dead.emit()

# 击退逻辑
func _process_kickback(attack: AttackItem) -> void:
	if attack.kickback_volume > 0:
		AppLogger.info(LOG_MODULE, "Knockback amount: %f" % attack.kickback_volume)
		
		var dir = attack.attacker.global_position.direction_to(global_position)
		var kickback = dir * attack.kickback_volume
		unit_kickback.emit(kickback)

#region UI更新
func update_health() -> void:
	if owner is Player:
		healthBar.visible = false
		return
	# 满血时不显示血条
	if health >= max_health:
		healthBar.visible = false
	else:
		healthBar.visible = true
		var health_percentage := health / float(max_health)
		healthBar.value = health_percentage
#endregion
