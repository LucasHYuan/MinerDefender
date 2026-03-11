extends Node2D

@export var duration: float = 1.0

@onready var battle_unit: BattleUnit = get_parent()
@onready var graphics: Node2D = $"../../Graphics"
@onready var timer: Timer = $Timer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer.wait_time = duration

	battle_unit.unit_hurt.connect(_start_invincible)
	timer.timeout.connect(_stop_invincible)
	pass # Replace with function body.

func _graphics_shinning() -> void:
	graphics.modulate.a = sin(Time.get_ticks_msec() / 20.0) * 0.5 + 0.5

func _start_invincible(_attack: AttackItem) -> void:
	battle_unit.invincible = true
	timer.start()

func _stop_invincible() -> void:
	battle_unit.invincible = false
	graphics.modulate.a = 1

func _process(_delta: float) -> void:
	if battle_unit.invincible:
		_graphics_shinning()