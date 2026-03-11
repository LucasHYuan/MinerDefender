class_name Interactable
extends Area2D

signal interacted
signal uninteracted

func _init() -> void:
	collision_layer = 0
	collision_mask = 0
	
	set_collision_mask_value(GlobalInfo.Team.player + 1, true)
	
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
func _on_body_entered(player: Player) -> void:
	player.interacting_with = self.owner
	interacted.emit()

func _on_body_exited(player: Player) -> void:
	player.interacting_with = null
	uninteracted.emit()
