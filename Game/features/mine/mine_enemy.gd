extends CharacterBody2D
class_name MineEnemy

const LOG_MODULE := "MineEnemy"
const KNOCKBACK_AMOUNT := 20.0

signal enemy_death(enemy: Node)

@export var speed: float = 40.0
@export var jump_velocity: float = -250.0
@export var EXP: int = 1
@export var coin: int = 1

var team: GlobalInfo.Team = GlobalInfo.Team.enemy
var DEFAULT_TARGET: Node2D = null
var is_stay: bool = true

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var _dead: bool = false

@onready var graphics: Node2D = $Graphics
@onready var battle_unit: BattleUnit = $BattleUnit
@onready var battle_search: BattleSearch = $BattleSearch


func _ready() -> void:
	battle_unit.unit_hurt.connect(_on_unit_hurt)
	battle_unit.unit_kickback.connect(_on_unit_kickback)
	battle_unit.unit_dead.connect(_on_unit_die)
	GlobalSignal.add_emitter("enemy_death", self)
	AppLogger.info(LOG_MODULE, "MineEnemy ready at (%.0f, %.0f)" % [global_position.x, global_position.y])


func _physics_process(delta: float) -> void:
	if _dead:
		return

	if not is_on_floor():
		velocity.y += gravity * delta

	var target := _get_target()
	if target != null:
		var dir_x := signf(target.global_position.x - global_position.x)
		velocity.x = dir_x * speed
		if not is_zero_approx(dir_x):
			graphics.scale.x = dir_x
	else:
		velocity.x = move_toward(velocity.x, 0.0, speed * delta * 3.0)

	if is_on_floor() and is_on_wall() and not is_zero_approx(velocity.x):
		velocity.y = jump_velocity

	move_and_slide()


func _get_target() -> Node2D:
	if battle_search != null and battle_search.target != null:
		return battle_search.target
	return DEFAULT_TARGET


func _on_unit_hurt(_attack: AttackItem) -> void:
	pass


func _on_unit_kickback(kickback: Vector2) -> void:
	translate(kickback * KNOCKBACK_AMOUNT)


func _on_unit_die() -> void:
	if _dead:
		return
	_dead = true
	speed = 0
	velocity = Vector2.ZERO

	var hit := get_node_or_null("HitAttacker") as HitAttacker
	if hit:
		hit.set_active(false)

	enemy_death.emit(self)

	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.4)
	tween.tween_callback(queue_free)


func destroy() -> void:
	queue_free()
