class_name Damage
extends RefCounted

var amount: int

var source: Node2D

func _init(amount: int, source: Node2D) -> void:
	self.amount = amount
	self.source = source
