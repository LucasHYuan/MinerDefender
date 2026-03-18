extends CharacterBody2D
class_name Pinball

const LOG_MODULE := "Pinball"

@export var speed: float = 300.0
@export var damage: int = 1
@export var max_bounces: int = 20
@export var lifetime: float = 10.0

var dir: Vector2 = Vector2.DOWN
var team: GlobalInfo.Team = GlobalInfo.Team.player
var exclude_body: PhysicsBody2D = null

var _bounce_count: int = 0
var _lifetime_timer: Timer


func _ready() -> void:
	if exclude_body != null and is_instance_valid(exclude_body):
		add_collision_exception_with(exclude_body)

	_lifetime_timer = Timer.new()
	_lifetime_timer.wait_time = lifetime
	_lifetime_timer.one_shot = true
	_lifetime_timer.timeout.connect(queue_free)
	add_child(_lifetime_timer)
	_lifetime_timer.start()

	velocity = dir.normalized() * speed


func _physics_process(delta: float) -> void:
	var collision := move_and_collide(velocity * delta)
	if collision:
		var collider := collision.get_collider()
		velocity = velocity.bounce(collision.get_normal())

		if collider is MiningBlock:
			collider.hit(damage)

		_bounce_count += 1
		if _bounce_count >= max_bounces:
			queue_free()


func set_team(_team: GlobalInfo.Team) -> void:
	team = _team
	var hit_attacker := get_node_or_null("HitAttacker") as HitAttacker
	if hit_attacker:
		hit_attacker.set_team(_team)
