extends Area2D
class_name AutoTargeting

@export var team: GlobalInfo.Team


func _ready() -> void:
	_set_team_mask()


func _set_team_mask() -> void:
	# Exclude own team from detection so we only see enemies.
	if team != null:
		collision_mask &= ~(1 << team)


func _get_distance(from: Vector2, to: Vector2) -> float:
	return (to - from).length()


func get_nearest_target() -> BattleUnit:
	# Returns the nearest alive BattleUnit in range, or null if none.
	var best: BattleUnit = null
	var origin := global_position

	for area in get_overlapping_areas():
		if area is Hurtbox == false:
			continue
		if area.owner == null:
			continue
		if area.owner is BattleUnit == false:
			continue

		var hurtbox := area as Hurtbox
		var unit := hurtbox.battle_unit
		if unit == null or unit.is_dead:
			continue

		# Optional extra safety: skip same team if team info is available.
		if team != null and area.owner.has_method("team") and area.owner.team == team:
			continue

		if best == null:
			best = unit
		else:
			if _get_distance(origin, unit.global_position) < _get_distance(origin, best.global_position):
				best = unit

	return best

