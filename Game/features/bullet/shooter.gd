extends Area2D
class_name Shooter

@onready var attack_range = $"."
@onready var timer = $Timer
@onready var shoot_point = $ShootPoint
@onready var team: GlobalInfo.Team = owner.team
@export var attacker_scene: PackedScene

@export var battle_unit: BattleUnit

@export var shoot_time: float = 1
@export var attacker_speed: float = 200
@export var attacker_damage: float = 1
@export var fix = false;
var is_shooting = false
var target_enemy: BattleUnit = null

func _ready():
	timer.wait_time = shoot_time
	timer.timeout.connect(_on_shoot_timer_timeout)
	area_entered.connect(_start_shooting)

	_set_team()


func _set_team() -> void:
	# 搜索敌人
	collision_mask &= ~(1 << team)

func _sync_data_from_parent() -> void:
	shoot_time = battle_unit.get_parent().shoot_time
	attacker_speed = battle_unit.get_parent().attacker_speed
	attacker_damage = battle_unit.get_parent().atk

func _start_shooting(_area: Area2D) -> void:
	_sync_data_from_parent()
	if is_shooting:
		return
	else:
		is_shooting = true
		_shoot()
		timer.start()


func get_distance(o):
	return (o.global_position - shoot_point.global_position).length()

func get_nearest_enemy() -> BattleUnit:
	var res = null

	var areas = get_overlapping_areas()
	for area in areas:
		if area is Hurtbox == false:
			continue
		if area.owner.team == team:
			continue
		var hurtbox = area as Hurtbox
		var target_unit = hurtbox.battle_unit
		if target_unit.is_dead:
			continue

		if res == null: # 第一个遍历到的敌人
			res = target_unit
		else: # 逐个比较，留在最小的
			if get_distance(target_unit) < get_distance(res):
				res = target_unit
	return res

func _on_shoot_timer_timeout():
	_shoot()

func _shoot() -> void:
	if get_parent().visible == false:
		return

	target_enemy = get_nearest_enemy()
	
	if target_enemy != null:
		# 发射子弹，并初始化数据
		var attacker = attacker_scene.instantiate()
		attacker.set_team(battle_unit.team)

		attacker.atk = attacker_damage
		attacker.speed = attacker_speed
		attacker.position = shoot_point.global_position
		if !fix:
			attacker.dir = (target_enemy.global_position - shoot_point.global_position).normalized()
			
		
		

		get_tree().root.call_deferred("add_child", attacker)
	else:
		# 没有敌人，停止射击
		timer.stop()
		is_shooting = false
