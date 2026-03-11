extends Node2D
class_name UpMoveLabel

@onready var label: Label = $Label
@onready var anim: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	label.visible = false

func play(text: String) -> void:
	label.visible = true
	label.text = text
	anim.play("UpMovingLabel")