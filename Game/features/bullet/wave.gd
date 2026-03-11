extends HitAttacker
class_name TauntWave

var speed = 1  # This will be set from the WaveEmitter script and control the wave's growth speed
var max_wave_size = 1  # Maximum size the wave can grow to
var current_wave_size = 0.01  # Initial wave size

@onready var hit_collision = $HitCollision
@onready var timer_destroy = $TimerDestroy
@onready var sprite = $Sprite2D

var initial_scale
var initial_collision_scale

func _ready():
	super._ready()
	set_as_top_level(true)
	hit.connect(_on_hitbox_hit)
	
	initial_scale = sprite.scale
	initial_collision_scale = hit_collision.scale
	
	sprite.scale *= current_wave_size
	hit_collision.scale *= current_wave_size

	# Start the destroy timer
	timer_destroy.start()

func _process(delta):
	if current_wave_size == max_wave_size: queue_free()
		
	# Grow the wave over time based on the speed
	current_wave_size += speed * delta
	current_wave_size = min(current_wave_size, max_wave_size)  # Ensure wave doesn't exceed max size
	
	# Scale the sprite and collision shape according to the wave size
	sprite.scale = initial_scale * current_wave_size
	hit_collision.scale = initial_collision_scale * current_wave_size

func _on_hitbox_hit(_hurtbox: Hurtbox) -> void:
	# Handle collision logic, e.g., applying damage, then destroy the wave
	pass
	

func _on_timer_destroy_timeout():
	# Destroy the wave after the timer ends
	queue_free()
