extends CharacterBody2D
class_name Miner

const LOG_MODULE := "Mine"

@export_group("Movement")
@export var move_speed: float = 120.0
@export var jump_velocity: float = -300.0

@export_group("Mining")
@export var mine_range: float = 48.0
@export var mine_damage: int = 1
@export var mine_interval: float = 0.5

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var facing_dir: Vector2 = Vector2.RIGHT

var _hovered_block: MiningBlock = null
var _cooldown_remaining: float = 0.0

@onready var graphics: Node2D = $Graphics
@onready var weapon: WeaponController = $WeaponController


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	var dir_x := Input.get_axis("move_left", "move_right")
	velocity.x = dir_x * move_speed

	if not is_zero_approx(dir_x):
		facing_dir = Vector2.RIGHT if dir_x > 0.0 else Vector2.LEFT
		graphics.scale.x = sign(dir_x)

	move_and_slide()


func _process(delta: float) -> void:
	if _cooldown_remaining > 0.0:
		_cooldown_remaining -= delta
	_update_hover()
	if Input.is_action_pressed("mine"):
		_try_mine()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("shoot"):
		_shoot_towards_mouse()


func _shoot_towards_mouse() -> void:
	if weapon == null or not weapon.can_shoot():
		return
	var mouse_pos := get_global_mouse_position()
	var origin := weapon.get_shoot_origin()
	var dir := (mouse_pos - origin).normalized()
	if dir == Vector2.ZERO:
		return
	weapon.shoot_in_direction(dir)


func _update_hover() -> void:
	var block := _get_block_under_mouse()

	if block != null:
		var dist := global_position.distance_to(block.global_position)
		if dist > mine_range:
			block = null

	if block == _hovered_block:
		return

	_clear_highlight()
	_hovered_block = block
	if _hovered_block != null:
		_hovered_block.modulate = Color(1.3, 1.3, 1.3)


func _clear_highlight() -> void:
	if _hovered_block != null and is_instance_valid(_hovered_block):
		_hovered_block.modulate = Color.WHITE
	_hovered_block = null


func _get_block_under_mouse() -> MiningBlock:
	var mouse_pos := get_global_mouse_position()
	var space := get_world_2d().direct_space_state
	var params := PhysicsPointQueryParameters2D.new()
	params.position = mouse_pos
	params.collision_mask = 8
	params.collide_with_bodies = true
	var results := space.intersect_point(params)
	for result in results:
		if result.collider is MiningBlock:
			return result.collider
	return null


func _try_mine() -> void:
	if _hovered_block == null or not is_instance_valid(_hovered_block):
		return
	if _cooldown_remaining > 0.0:
		return
	_hovered_block.hit(mine_damage)
	_cooldown_remaining = mine_interval
