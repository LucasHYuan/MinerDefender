extends HBoxContainer

@export var battle_unit: BattleUnit
@export var player_data: PlayerData

@onready var health_bar: TextureProgressBar = $Health_and_Exp/HealthBar
@onready var exp_bar: TextureProgressBar = $Health_and_Exp/ExpBar
@onready var coin_text: Label = $coin_text
@onready var level_text: Label = $VBoxContainer/level_text


func _ready() -> void:
	battle_unit.health_changed.connect(update_health)
	update_health()

	player_data.exp_changed.connect(update_exp)
	update_exp()

	player_data.coin_changed.connect(update_coin)
	update_coin()

	player_data.level_changed.connect(update_level)
	update_level()

	
func update_health() -> void:
	var health_percentage := battle_unit.health / float(battle_unit.max_health)
	health_bar.value = health_percentage
	
func update_exp() -> void:
	var exp_percentage := player_data.EXP / float(player_data.max_exp)
	exp_bar.value = exp_percentage
	
func update_coin() -> void:
	coin_text.text = str(player_data.coin)

func update_level() -> void:
	level_text.text = "Level " + str(player_data.level)
