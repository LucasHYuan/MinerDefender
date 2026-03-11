extends Buildings
class_name BaseCamp

signal camp_built

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	GlobalObjects.SetObject("base_camp", self)

	GlobalSignal.add_emitter("camp_built", self)

#region 游戏逻辑
func _on_unit_die() -> void:
	super._on_unit_die()
	call_deferred("_reload_scene")

func _reload_scene() -> void:
	get_tree().reload_current_scene()

func _on_build() -> void:
	# 建造的同时发出通知
	super._on_build()
	camp_built.emit()
#endregion
