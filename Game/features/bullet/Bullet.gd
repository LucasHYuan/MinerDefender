extends HitAttacker

var instigator: Node = null
var dir = Vector2.ZERO
var speed = 1

@onready var timer_destroy = $TimerDestroy

# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()
	set_as_top_level(true)
	hit.connect(_on_hitbox_hit)

	timer_destroy.timeout.connect(_on_timer_destroy_timeout)
	timer_destroy.start()

	hit_time = 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position += (dir * speed) * delta

func _on_hitbox_hit(_hurtbox: Hurtbox) -> void:
	if instigator and _hurtbox.owner == instigator:
		return
	if hit_time == 0:
		queue_free()


func _on_timer_destroy_timeout():
	queue_free()
