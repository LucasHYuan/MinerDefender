class_name AttackItem
extends RefCounted

var atk: float = 0
var kickback_volume: float = 0
var attacker: Node2D

func _init(_atk: float, _attacker: Node2D) -> void:
	self.atk = _atk
	self.attacker = _attacker
	
	if _attacker.kickback != null:
		self.kickback_volume = _attacker.kickback
