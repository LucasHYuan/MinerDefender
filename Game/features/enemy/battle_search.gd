extends Area2D
class_name BattleSearch

signal find_target(target: Node2D)

@onready var team: GlobalInfo.Team = owner.team

var target: BattleUnit = null

# 获取最近的battle_unit
func get_neareast_target() -> BattleUnit:
	var areas = get_overlapping_areas()
	var res = null
	for area in areas:
		if area is Hurtbox:
			if res == null:
				res = area
			else:
				if get_distance(area) < get_distance(res):
					res = area
	return null if res == null else res.battle_unit


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_set_team()
	
	area_exited.connect(_search_target)
	area_entered.connect(_search_target)


func _set_team() -> void:
	# 搜索敌人
	collision_mask &= ~(1 << team)

func get_distance(o):
	return (o.global_position - global_position).length()

func _search_target(_area: Area2D) -> void:
	target = get_neareast_target()
	# print("范围搜索发现目标:", target)
