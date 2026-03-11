extends Buildings

@export var coin_earn: int = 1
@export var earn_interval: int = 2

@onready var upMoveLabel: UpMoveLabel = $UpMoveLabel

var index: int = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()

func _on_day_function() -> void:
	pass

func _on_one_second_function() -> void:
	if index == earn_interval:
		_earn_coin()
		index = 1
	else:
		index += 1

func _earn_coin() -> void:
	var player: Player = GlobalObjects.GetObject("player")
	player.data.coin += coin_earn
	upMoveLabel.play("+" + str(coin_earn))
	pass
