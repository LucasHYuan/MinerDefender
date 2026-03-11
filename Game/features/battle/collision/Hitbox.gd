class_name Hitbox
extends Area2D
signal hit(hurtbox)

var hit_time: int = -1 # >0时允许碰撞，=0时禁用碰撞，<0时不限制

var hit_targets: Array = []
var timer = Timer.new() # 用于对接触目标持续造成伤害

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)

	add_child(timer)
	timer.one_shot = false
	timer.wait_time = 0.2
	timer.timeout.connect(_hit_all_targets)

func _hit_all_targets() -> void:
	for hurtbox in hit_targets:
		_hit_target(hurtbox)
	
func _hit_target(hurtbox: Hurtbox) -> void:
	if hit_time == 0:
		disable_mode = DISABLE_MODE_REMOVE
		return
	hit_time -= 1
	hit.emit(hurtbox)
	hurtbox.hurt.emit(self)
	
func _on_area_entered(hurtbox: Hurtbox) -> void:
	timer.start()
	_hit_target(hurtbox)
	hit_targets.append(hurtbox)

func _on_area_exited(hurtbox: Hurtbox) -> void:
	hit_targets.erase(hurtbox)
	if hit_targets.size() == 0:
		timer.stop()
